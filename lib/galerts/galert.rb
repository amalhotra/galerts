module Galerts
	class Galert
	# Class models a google alert

		#include Galerts::GoogleDefaults

		# Only have readers as setters are explicitly defined to sanity check values against GoogleDefaults
		attr_reader :email,:type,:frequency,:volume,:delivery,:s,:feed_url,:search_query

		# Dont have to check these against defaults
		# TODO: Check domain against google list
		attr_accessor :query,:domain,:state
		
		def initialize(email,query,search_query,type,frequency,volume,delivery,s,state,feed_url=nil)
			raise "Unknown alert type" unless ALERT_TYPES.has_key?(type)
			raise "Unknown frequency type" unless FREQS_TYPES.has_key?(frequency)
			raise "Unknown alert volume" unless VOLS_TYPES.has_key?(volume)
			raise "Unknown delivery method" unless DELIVERY_TYPES.has_key?(delivery)
			raise "Unknown state" unless state == ACTIVE_ALERT_CLASS || state == UNVERIFIED_ALERT_CLASS
			@email = email
			@query = query
			@type = type
			@frequency = frequency
			@volume = volume
			@delivery = delivery
			@s = s
			@state = state
			@feed_url = feed_url
			@search_query = search_query

			# Get domain from search query
			# e.g. http://www.google.fr/search?hl=fr&gl=fr&q=%22nicholas+sarkozy%22&lr=lang_fr
			# Host : www.google.fr or www.google.co.uk
			@domain = URI(search_query).host.split(".google.").last if search_query && !search_query.empty?
		end

		# Setters to sanity check against Google Defaults

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

		def active?
			state == ACTIVE_ALERT_CLASS
		end

		def feed
			!@feed_url.nil?
		end

		# TODO Encode query as utf-8
		def to_s
			"<#{self.class.to_s} query=#{query} type=#{type} freq=#{frequency} delivery=#{delivery} domain=#{domain} search_query=#{search_query}>"
		end

	end
end
