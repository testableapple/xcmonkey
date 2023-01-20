require 'json'
require 'colorize'
require_relative 'xcmonkey/describer'
require_relative 'xcmonkey/repeater'
require_relative 'xcmonkey/version'
require_relative 'xcmonkey/logger'
require_relative 'xcmonkey/driver'

class Xcmonkey
  attr_accessor :driver

  def initialize(params)
    params[:session_path] = Dir.pwd if params[:session_path].nil?
    params[:duration] = 60 if params[:duration].nil?
    params[:enable_simulator_keyboard] = true if params[:enable_simulator_keyboard].nil?
    ensure_required_params(params)
    self.driver = Driver.new(params)
  end

  def run
    driver.monkey_test(gestures)
  end

  def gestures
    taps = [:precise_tap, :blind_tap] * 10
    swipes = [:precise_swipe, :blind_swipe] * 5
    presses = [:precise_press, :blind_press]
    taps + swipes + presses
  end

  def ensure_required_params(params)
    Logger.error('UDID should be provided') if params[:udid].nil?

    Logger.error('Bundle identifier should be provided') if params[:bundle_id].nil?

    Logger.error('Session path should be a directory') if params[:session_path].nil? || !File.directory?(params[:session_path])

    if params[:duration].nil? || !params[:duration].kind_of?(Integer) || !params[:duration].positive?
      Logger.error('Duration must be Integer and not less than 1 second')
    end
  end
end
