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
        tap(coordinates: random_coordinates)
      when :precise_press
        press(coordinates: el1_coordinates, duration: press_duration)
      when :blind_press
        press(coordinates: random_coordinates, duration: press_duration)
      when :precise_swipe
        swipe(
          start_coordinates: el1_coordinates,
          end_coordinates: el2_coordinates,
          duration: swipe_duration
        )
      when :blind_swipe
        swipe(
          start_coordinates: random_coordinates,
          end_coordinates: random_coordinates,
          duration: swipe_duration
        )
      else
        next
      end
      app_elements = describe_ui.shuffle
      Logger.error('App lost') if app_elements.include?(@home_tracker)
    end
  end

  def open_home_screen(with_tracker: false)
    `idb ui button --udid #{udid} HOME`
    detect_home_unique_element if with_tracker
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
    wait_until_app_launched
  end

  def terminate_app
    `idb terminate --udid #{udid} #{bundle_id} 2>/dev/null`
  end

  def boot_simulator
    `idb boot #{udid}`
    Logger.error("Failed to boot #{udid}") if device_info['state'] != 'Booted'
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

  def list_apps
    `idb list-apps --udid #{udid}`
  end

  def tap(coordinates:)
    Logger.info('Tap:', payload: JSON.pretty_generate(coordinates))
    `idb ui tap --udid #{udid} #{coordinates[:x]} #{coordinates[:y]}`
  end

  def press(coordinates:, duration:)
    Logger.info("Press (#{duration}s):", payload: JSON.pretty_generate(coordinates))
    `idb ui tap --udid #{udid} --duration #{duration} #{coordinates[:x]} #{coordinates[:y]}`
  end

  def swipe(start_coordinates:, end_coordinates:, duration:)
    Logger.info(
      "Swipe (#{duration}s):",
      payload: "#{JSON.pretty_generate(start_coordinates)} => #{JSON.pretty_generate(end_coordinates)}"
    )
    coordinates = "#{start_coordinates[:x]} #{start_coordinates[:y]} #{end_coordinates[:x]} #{end_coordinates[:y]}"
    `idb ui swipe --udid #{udid} --duration #{duration} #{coordinates}`
  end

  def central_coordinates(element)
    frame = element['frame']
    x = (frame['x'] + (frame['width'] / 2)).abs.to_i
    y = (frame['y'] + (frame['height'] / 2)).abs.to_i
    {
      x: x > screen_size[:width].to_i ? rand(0..screen_size[:width].to_i) : x,
      y: y > screen_size[:height].to_i ? rand(0..screen_size[:height].to_i) : y
    }
  end

  def random_coordinates
    {
      x: rand(0..screen_size[:width].to_i),
      y: rand(0..screen_size[:height].to_i)
    }
  end

  def device_info
    @device_info ||= JSON.parse(`idb describe --udid #{udid} --json`)
    @device_info
  end

  def screen_size
    screen_dimensions = device_info['screen_dimensions']
    {
      width: screen_dimensions['width_points'],
      height: screen_dimensions['height_points']
    }
  end

  def swipe_duration
    rand(0.1..0.7).ceil(1)
  end

  def press_duration
    rand(0.5..1.5).ceil(1)
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

  def wait_until_app_launched
    app_info = nil
    current_time = Time.now
    while app_info.nil? && Time.now < current_time + 5
      app_info = list_apps.split("\n").detect do |app|
        app =~ /#{bundle_id}.*Running/
      end
    end
    Logger.error("Can't run the app #{bundle_id}") if app_info.nil?
    Logger.info('App info:', payload: app_info)
  end
end
