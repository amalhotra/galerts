module Galerts
	# Class models a google alert
	class Alert

		include Galerts::GoogleDefaults

		attr_reader :email,:type,:frequency,:volume,:delivery,:s,:feed_url
		attr_accessor :query,:domain
		
		def initialize(email,query,search_query,type,frequency,volume,delivery,s,feed_url=nil)
			raise "Unknown alert type" unless ALERT_TYPES.has_key?(type)
			raise "Unknown frequency type" unless FREQS_TYPES.has_key?(frequency)
			raise "Unknown alert volume" unless VOLS_TYPES.has_key?(volume)
			raise "Unknown delivery method" unless DELIVERY_TYPES.has_key?(delivery)
			@email = email
			@query = query
			@type = type
			@frequency = frequency
			@volume = volume
			@delivery = delivery
			@s = s
			@feed_url = feed_url
			@search_query = search_query
			@domain = URI(search_query).host.split(".").last if search_query && !search_query.empty?
		end

		def frequency=(f)
			raise "Unknown frequency type" unless FREQS_TYPES.has_key?(f)
			@frequency = f
		end

		def type=(t)
			raise "Unknown alert type" unless ALERT_TYPES.has_key?(t)
			@type = t
		end

		def volume=(v)
			raise "Unknown alert volume" unless VOLS_TYPES.has_key?(v)
			@volume = v
		end

		def delivery=(d)
			raise "Unknown delivery method" unless DELIVERY_TYPES.has_key?(delivery)
			@delivery = d
		end

		# TODO Encode query as utf-8
		def to_s
			"<#{self.class.to_s} query=#{query} type=#{type} freq=#{frequency} delivery=#{delivery}>"
		end

	end
end
