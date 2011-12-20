require 'mechanize'

module Galerts
	class AlertsManager
	
		include Galerts::GoogleDefaults

		attr_reader :auth_domains,:email

		def initialize(email,password)
			email+='@gmail.com' if email.index('@').nil?
			@email = email
			domain = "com"
			@password = password
			init_agent
			login(domain)
			@auth_domains = ["com"]
		end

		def to_s
			"<#{self.class} email=#{@email} auth_domains=#{@auth_domains}>"
		end

		def alerts
			g_alerts = []
			alerts_page = @agent.get(alerts_url("/manage"))
			alert_rows = alerts_page.parser.css('table.alerts').css('tr')
			type = EVERYTHING
			alert_rows.each do |alert_row|
				tds = alert_row.css('td')
				if tds.empty?
					type = alert_row.css('th')[1].text
					next
				end
				s = tds[0].css('input[name=s]').first["value"]
				query = tds[1].text
				search_query = tds[1].css('a').first["href"]
				volume = tds[2].text
				frequency = tds[3].text
				if tds[4].css('a').empty?
					feed_url = nil
					delivery = EMAIL_DELIVERY
				else
					feed_url = tds[4].css('a')[1]["href"]
					delivery = FEED_DELIVERY
				end
				email = @email # TODO: Could be one of many email addresses associated with account
				g_alerts << Alert.new(email,query,search_query,type,frequency,volume,delivery,s,feed_url)
			end	
			g_alerts
		end

		def create(query,domain = "com",type = EVERYTHING,frequency = RT,volume = ALL_VOL,feed=false)
			authenticate!(domain)
			create_page = @agent.get(alerts_url("/create",domain))
			create_form = create_page.forms.first
			create_form.q = query
			create_form.e = feed ? FEED_DELIVERY : @email
			create_form.f = FREQS_TYPES[feed ? RT : frequency]
			create_form.t = ALERT_TYPES[type]
			create_form.l = VOLS_TYPES[volume]
			resp = @agent.submit(create_form)
			# TODO: Return alert as GAlerts::Alert object just created
		end

		def update(alert)
			authenticate!(alert.domain)
			x,es,hps = scrape_x_es_hps(alert)
			params = {
				'd' => DELIVERY_TYPES[alert.delivery] || DEFAULT_DELIVERY,
				'e' => @email,
				'es' => es,
				'hps' => hps,
				'q' => alert.query,
				'se' => 'Save',
				'x' => x,
				't' => ALERT_TYPES[alert.type],
				'l' => VOLS_TYPES[alert.volume],
			}	
			params['f'] = FREQS_TYPES[alert.frequency] if alert.delivery == EMAIL_DELIVERY
			resp = @agent.post(alerts_url("/save",alert.domain),params)
		end

		def delete(alert)
			params = {
				'da' => 'Delete',
				'e' => @email,
				's' => alert.s,
				'x' => scrape_galx
			}
			resp = @agent.post(alerts_url("/save"),params)
		end

		private

		def authenticated?(domain)
			!@auth_domains.index(domain).nil?
		end

		def authenticate!(domain)
			return if authenticated?(domain)
			login(domain)
		end

		def login(domain="com")
			login_page = @agent.get(login_url(domain))			
			login_form = login_page.forms.first
			login_form.Email = @email
			login_form.Passwd = @password
			login_resp = @agent.submit(login_form)
		end

		def scrape_galx
			resp = @agent.get(alerts_url("/manage"))
			resp.parser.css('input[name=x]').first["value"]
		end

		def scrape_x_es_hps(alert)
			resp = @agent.get(alerts_url("/edit",alert.domain),{'s' => alert.s})
			x = resp.parser.css('input[name=x]').first["value"]
			es = resp.parser.css('input[name=es]').first["value"]
			hps = resp.parser.css('input[name=hps]').first["value"]
			[x,es,hps]
		end

		def login_url(domain="com")
			"https://accounts.google.#{domain}/ServiceLogin?service=alerts&continue=#{alerts_url("",domain)}"
		end

		def alerts_url(path = "",domain="com")
			"http://www.google.#{domain}/alerts#{path}"
		end

		def init_agent
			@agent = Mechanize.new
			@agent.user_agent_alias = 'Linux Mozilla'
			@agent.keep_alive = true
			@agent.redirect_ok = true	
			@agent.follow_meta_refresh = true
		end

	end
end
