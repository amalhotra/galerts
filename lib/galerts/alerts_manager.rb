require 'mechanize'

module Galerts
	class AlertsManager
	
		#include Galerts::GoogleDefaults

		# Allowed to read auth_domains and email
		attr_reader :auth_domains,:email#,:agent

		def initialize(email,password)
			email+='@gmail.com' if email.index('@').nil?
			@email = email
			# Unfortunately we need to store this since we have to login to multiple google domains
			@password = password
			@auth_domains = []
			init_agent
			login("com")
		end

		def to_s
			"<#{self.class} email=#{@email} auth_domains=#{@auth_domains}>"
		end

		# Get all alerts as an array of Alert Objects
		# Note: We always get alerts from google.com/alerts/manage as all our mappings in GoogleDefaults are in English
		def alerts
			g_alerts = []
			alerts_page = @agent.get(alerts_url("/manage"))
			alert_rows = alerts_page.parser.css('table.alerts').css('tr')
			type = EVERYTHING
			alert_rows.each do |alert_row|
				tds = alert_row.css('td')

				# If this row has no columns, it must be a row for type definition
				if tds.empty?
					type = alert_row.css('th')[1].text
					next
				end

				# Here only if columns exist and if the length of the columns < 6, it means there are no alerts
				next if tds.size < 6

				# Alerts do exist: Build alert object
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
				state = alert_row.attributes["class"].value
				g_alerts << Alert.new(email,query,search_query,type,frequency,volume,delivery,s,state,feed_url)
			end	
			g_alerts
		end

		# Create a new alert
		def create(query,domain = "com",type = EVERYTHING,frequency = RT,volume = ALL_VOL,feed=false)
			# If we havent been authenticated for a domain, authenticate now
			authenticate!(domain)
			create_page = @agent.get(alerts_url("",domain))
			create_form = create_page.forms.first
			create_form.q = query
			create_form.e = feed ? FEED_DELIVERY : @email
			create_form.f = FREQS_TYPES[feed ? RT : frequency]
			create_form.t = ALERT_TYPES[type]
			create_form.l = VOLS_TYPES[volume]
			resp = @agent.submit(create_form)
			alerts = find_by_query(query)
			alert = alerts.first
			alert.nil? || alert.active? ? alert : verify!(alert)
			# TODO: Check for duplicate alert and return message
		end

		# Note: Google allows creating the same alert (same search query) if delivery is different
		# (email and rss feed) and/or domains are different

		# Update given alert by posting to update form
		# Does not work for some domains, use update instead
		# TODO: Check duplicate as above
		def update_post(alert)
			authenticate!(alert.domain)

			# Needs these to prevent xss
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
			true
		end

		# Delete the alert and then re-create it
		def update(alert)
			delete(alert) && create(alert.query,alert.domain,alert.type,alert.frequency,alert.volume,alert.feed_url.nil?)
		end

		# Delete an alert
		def delete(alert)
			params = {
				'da' => 'Delete',
				'e' => @email,
				's' => alert.s,
				'x' => scrape_galx
			}
			resp = @agent.post(alerts_url("/save"),params)
			true
		end
		
		# Verify an alert (Mainly a workaround till multiple domains issue can be solved)
		def verify!(alert)
			resp = @agent.get(alerts_url("/verify"),{'s' => alert.s}) unless alert.active?
			alert.state = ACTIVE_ALERT_CLASS
			alert
		end

		# Return all alerts that match a given query
		def find_by_query(query)
			self.alerts.select{|a| a.query == query}
		end

		def inspect
			to_s
		end

		private

		# If domain is in auth_domains, we have already authenticated with that google domain
		def authenticated?(domain)
			!@auth_domains.index(domain).nil?
		end

		# Authenticate unless we already have
		def authenticate!(domain)
			return if authenticated?(domain)
			login(domain)
		end

		# TODO: Better exception handling and messages
		def login(domain="com")
			login_page = @agent.get(login_url(domain))			
			login_form = login_page.forms.first
			login_form.Email = @email
			login_form.Passwd = @password
			login_resp = @agent.submit(login_form)
			@auth_domains << domain
		end

		# Helpers to scrape xss prevention params

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

		# Urls for Google Alerts
		def login_url(domain="com")
			"https://accounts.google.com/ServiceLogin?service=alerts&continue=#{alerts_url("",domain)}"
		end

		def alerts_url(path = "",domain="com")
			"http://www.google.#{domain}/alerts#{path}"
		end

		# Initialize Mechanize user agent
		def init_agent
			@agent = Mechanize.new
			@agent.user_agent_alias = 'Linux Mozilla'
			@agent.keep_alive = true
			@agent.redirect_ok = true	
			@agent.follow_meta_refresh = true
		end

	end
end
