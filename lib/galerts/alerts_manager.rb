require 'mechanize'

module Galerts
	class AlertsManager
	
		include GoogleDefaults

		def initialize(email,password,domain='com')
			email+='@gmail.com' if email.index('@').nil?
			@email = email
			@domain = domain
			init_agent
			@alerts_page = login(password)
		end

		def alerts
			alerts_page = @agent.get(alerts_url)
			alert_rows = alerts_page.parser.css('tr.ACTIVE')
			alert_rows.each do |alert_row|
				#tds = alert_row.css('td')
				#s = tds[0]
			end	
		end

		private

		def login(password)
			login_page = @agent.get(login_url)			
			login_form = login_page.forms.first
			login_form.Email = @email
			login_form.Passwd = password
			login_resp = agent.submit(login_form)
		end

		def login_url
			"https://accounts.google.#{@domain}/ServiceLogin?service=alerts&continue=#{alerts_url}"
		end

		def alerts_url
			"https://www.google.#{@domain}/alerts/manage"
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
