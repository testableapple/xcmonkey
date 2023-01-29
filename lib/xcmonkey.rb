require 'json'
require 'colorize'
require_relative 'xcmonkey/describer'
require_relative 'xcmonkey/repeater'
require_relative 'xcmonkey/version'
require_relative 'xcmonkey/logger'
require_relative 'xcmonkey/driver'

class Xcmonkey
  attr_accessor :params, :driver

  def initialize(params)
    params[:event_count] = 60 if params[:event_count].nil?
    params[:ignore_crashes] = false if params[:ignore_crashes].nil?
    params[:disable_simulator_keyboard] = false if params[:disable_simulator_keyboard].nil?
    self.params = params
    self.driver = Driver.new(params)
    ensure_required_params
  end

  def run
    driver.monkey_test(gestures)
  end

  def gestures
    taps = params[:exclude_taps] ? [] : [:precise_tap, :blind_tap] * 10
    swipes = params[:exclude_swipes] ? [] : [:precise_swipe, :blind_swipe] * 5
    presses = params[:exclude_presses] ? [] : [:precise_press, :blind_press]
    taps + swipes + presses
  end

  def ensure_required_params
    Logger.error('UDID should be provided') if params[:udid].nil?

    Logger.error('Bundle identifier should be provided') if params[:bundle_id].nil?

    Logger.error('Session path should be a directory') if params[:session_path] && !File.directory?(params[:session_path])

    if params[:event_count].nil? || !params[:event_count].kind_of?(Integer) || !params[:event_count].positive?
      Logger.error('Event count must be Integer and not less than 1')
    end
  end
end
