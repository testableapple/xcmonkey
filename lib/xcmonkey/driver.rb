class Driver
  attr_accessor :udid, :bundle_id, :duration

  def initialize(params)
    self.udid = params[:udid]
    self.bundle_id = params[:bundle_id]
    self.duration = params[:duration]
    ensure_driver_installed
  end

  def monkey_test(gestures)
    app_elements = describe_ui.shuffle
    current_time = Time.now
    while Time.now < current_time + duration
      el1_coordinates = central_coordinates(app_elements.first)
      el2_coordinates = central_coordinates(app_elements.last)
      case gestures.sample
      when :precise_tap
        tap(coordinates: el1_coordinates)
      when :blind_tap
        x = (el1_coordinates[:x] - el2_coordinates[:x]).abs
        y = (el1_coordinates[:y] - el2_coordinates[:y]).abs
        tap(coordinates: { x: x, y: y })
      when :swipe
        swipe(start_coordinates: el1_coordinates, end_coordinates: el2_coordinates)
      else
        next
      end
      app_elements = describe_ui.shuffle
      Logger.error('App lost') if app_elements.include?(@home_tracker)
    end
  end

  def open_home_screen(return_tracker: false)
    `idb ui button --udid #{udid} HOME`
    detect_home_unique_element if return_tracker
  end

  def describe_ui
    JSON.parse(`idb ui describe-all --udid #{udid}`)
  end

  def describe_point(x, y)
    point_info = JSON.parse(`idb ui describe-point --udid #{udid} #{x} #{y}`)
    Logger.info("x:#{x} y:#{y} point info:", payload: JSON.pretty_generate(point_info))
    point_info
  end

  def launch_app
    `idb launch --udid #{udid} #{bundle_id}`
  end

  def terminate_app
    `idb terminate --udid #{udid} #{bundle_id} 2>/dev/null`
  end

  def boot_simulator
    `idb boot #{udid}`
    ensure_simulator_was_booted
  end

  def shutdown_simulator
    `idb shutdown #{udid}`
  end

  def list_targets
    @list_targets ||= `idb list-targets`.split("\n")
    @list_targets
  end

  def list_booted_simulators
    `idb list-targets`.split("\n").grep(/Booted/)
  end

  def ensure_app_installed
    Logger.error("App #{bundle_id} is not installed on device #{udid}") unless list_apps.include?(bundle_id)
  end

  def ensure_device_exists
    device = list_targets.detect { |target| target.include?(udid) }
    Logger.error("Can't find device #{udid}") if device.nil?
    Logger.info('Device info:', payload: device)
    boot_simulator if device.include?('simulator')
  end

  def ensure_simulator_was_booted
    sim = list_booted_simulators.detect { |target| target.include?(udid) }
    Logger.error("Failed to boot #{udid}") if sim.nil?
  end

  def list_apps
    `idb list-apps --udid #{udid}`
  end

  def tap(coordinates:)
    Logger.info('Tap:', payload: JSON.pretty_generate(coordinates))
    `idb ui tap --udid #{udid} #{coordinates[:x]} #{coordinates[:y]}`
  end

  def swipe(start_coordinates:, end_coordinates:)
    Logger.info('Swipe:', payload: "#{JSON.pretty_generate(start_coordinates)} => #{JSON.pretty_generate(end_coordinates)}")
    coordinates = "#{start_coordinates[:x]} #{start_coordinates[:y]} #{end_coordinates[:x]} #{end_coordinates[:y]}"
    `idb ui swipe --udid #{udid} --duration 0.5 #{coordinates}`
  end

  def central_coordinates(element)
    frame = element['frame']
    {
      x: (frame['x'] + (frame['width'] / 2)).to_i,
      y: (frame['y'] + (frame['height'] / 2)).to_i
    }
  end

  private

  def ensure_driver_installed
    Logger.error("'idb' doesn't seem to be installed") if `which idb`.strip.empty?
  end

  def detect_home_unique_element
    @home_tracker ||= describe_ui.reverse.detect do |el|
      sleep(1)
      !el['AXUniqueId'].nil? && !el['AXUniqueId'].empty? && el['type'] == 'Button'
    end
    @home_tracker
  end
end
