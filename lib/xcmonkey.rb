require 'json'
require 'colorize'
require_relative 'xcmonkey/describer'
require_relative 'xcmonkey/version'
require_relative 'xcmonkey/logger'
require_relative 'xcmonkey/driver'

module Xcmonkey
	class Xcmonkey
	  attr_accessor :udid, :bundle_id, :duration, :driver

	  def initialize(params)
			ensure_required_params(params)
	    self.udid = params[:udid]
	    self.bundle_id = params[:bundle_id]
	    self.duration = params[:duration]
			self.driver = Driver.new(params)
	  end

    def run
			driver.ensure_device_exists
			driver.ensure_app_installed
			driver.terminate_app
			driver.open_home_screen(return_tracker: true)
			driver.launch_app
			driver.monkey_test(gestures)
    end

		def gestures
			[:precise_tap, :blind_tap, :swipe]
		end

		def ensure_required_params(params)
			Logger.error('UDID should be provided') if params[:udid].nil?
			Logger.error('Bundle identifier should be provided') if params[:bundle_id].nil?
			if params[:duration].nil? || !params[:duration].kind_of?(Integer) || !params[:duration].positive?
				Logger.error('Duration must be Integer and not less than 1 second')
			end
		end
	end
end
