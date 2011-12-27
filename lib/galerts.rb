require "galerts/version"

module Galerts
	MAX_Q_LEN = 2048 # Maximum len of query

	EMAIL_DELIVERY = 'Email'
	FEED_DELIVERY = 'feed'
	DEFAULT_DELIVERY = '6'

	DELIVERY_TYPES = {
		EMAIL_DELIVERY => '0',
		FEED_DELIVERY => DEFAULT_DELIVERY
	}

	RT = 'As-it-happens'
	DAILY = 'Once a day'
	WEEKLY = 'Once a week'

	FREQS_TYPES = {
		RT => '0',
		DAILY => '1',
		WEEKLY => '6'
	}

	BEST_VOL = 'Only the best results'
	ALL_VOL = 'All results'

	VOLS_TYPES = {
		BEST_VOL => '0',
		ALL_VOL => '1'
	}

	EVERYTHING = 'Everything'
	NEWS = 'News' 
	BLOGS = 'Blogs'
	REALTIME = 'Realtime'
	VIDEO = 'Video'
	DISCUSSIONS = 'Discussions'

	ALERT_TYPES = {
		EVERYTHING => '7',
		NEWS => '1',
		BLOGS => '4',
		REALTIME => '20',
		VIDEO => '9',
		DISCUSSIONS => '9'
	}

	ACTIVE_ALERT_CLASS = "ACTIVE"
	UNVERIFIED_ALERT_CLASS = "UNVERIFIED"

end

require 'galerts/google_defaults'
require 'galerts/alert'
require 'galerts/alerts_manager'
