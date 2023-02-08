class Driver
  attr_accessor :udid, :bundle_id, :disable_simulator_keyboard, :event_count, :session_path, :session_actions, :ignore_crashes, :throttle

  def initialize(params)
    self.udid = params[:udid]
    self.throttle = params[:throttle]
    self.bundle_id = params[:bundle_id]
    self.event_count = params[:event_count]
    self.session_path = params[:session_path]
    self.ignore_crashes = params[:ignore_crashes]
    self.disable_simulator_keyboard = params[:disable_simulator_keyboard]
    self.session_actions = params[:session_actions]
    @session = { params: params, actions: [] }
    ensure_driver_installed
  end

  def monkey_test_precondition
    puts
    ensure_device_exists
    ensure_app_installed
    terminate_app(bundle_id)
    launch_app(target_bundle_id: bundle_id, wait_for_state_update: true)
    @running_apps = list_running_apps
  end

  def monkey_test(gestures)
    monkey_test_precondition
    event_count.times do |counter|
      app_elements = describe_ui.shuffle
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
      checkup(counter)
    end
    save_session
    terminate_app(bundle_id)
  end

  def repeat_monkey_test
    monkey_test_precondition
    session_actions.each_with_index do |action, counter|
      case action['type']
      when 'tap'
        tap(coordinates: { x: action['x'], y: action['y'] })
      when 'press'
        press(coordinates: { x: action['x'], y: action['y'] }, duration: action['duration'])
      when 'swipe'
        swipe(
          start_coordinates: { x: action['x'], y: action['y'] },
          end_coordinates: { x: action['endX'], y: action['endY'] },
          duration: action['duration']
        )
      else
        next
      end
      checkup(counter)
    end
    terminate_app(bundle_id)
  end

  def checkup(counter)
    detect_app_state_change
    if counter % 5 == 0 || throttle.to_i > 0 # Track running apps after every 5th action
      track_running_apps                     # (unless `throttle` was provided) to speed up the test
    end
    check_speed_limit
  end

  def describe_ui
    JSON.parse(`idb ui describe-all --udid #{udid}`)
  end

  def describe_point(x, y)
    point_info = JSON.parse(`idb ui describe-point --udid #{udid} #{x} #{y}`)
    Logger.info("x:#{x} y:#{y} point info:", payload: JSON.pretty_generate(point_info))
    point_info
  end

  def launch_app(target_bundle_id:, wait_for_state_update: false)
    `idb launch --udid #{udid} #{target_bundle_id}`
    wait_until_app_launched(target_bundle_id) if wait_for_state_update
  end

  def terminate_app(target_bundle_id)
    `idb terminate --udid #{udid} #{target_bundle_id} 2>/dev/null`
  end

  def boot_simulator
    `idb boot #{udid}`
    Logger.error("Failed to boot #{udid}") if device_info['state'] != 'Booted'
  end

  def shutdown_simulator
    `idb shutdown #{udid}`
  end

  def configure_simulator_keyboard
    shutdown_simulator
    keyboard_status = disable_simulator_keyboard ? 1 : 0
    `defaults write com.apple.iphonesimulator ConnectHardwareKeyboard #{keyboard_status}`
  end

  def list_targets
    @targets ||= `idb list-targets --json`.split("\n").map! { |target| JSON.parse(target) }
    @targets
  end

  def list_apps
    `idb list-apps --udid #{udid} --json`.split("\n").map! { |app| JSON.parse(app) }
  end

  def list_running_apps
    list_apps.select { |app| app['process_state'] == 'Running' }
  end

  def ensure_app_installed
    return if list_apps.any? { |app| app['bundle_id'] == bundle_id }

    Logger.error("App #{bundle_id} is not installed on device #{udid}")
  end

  def ensure_device_exists
    device = list_targets.detect { |target| target['udid'] == udid }
    Logger.error("Can't find device #{udid}") if device.nil?

    Logger.info('Device info:', payload: JSON.pretty_generate(device))
    if device['type'] == 'simulator'
      configure_simulator_keyboard
      boot_simulator
    else
      Logger.error('xcmonkey does not support real devices yet. ' \
                   'For more information see https://github.com/alteral/xcmonkey/issues/7')
    end
  end

  def tap(coordinates:)
    Logger.info('Tap:', payload: JSON.pretty_generate(coordinates))
    @session[:actions] << { type: :tap, x: coordinates[:x], y: coordinates[:y] } unless session_actions
    `idb ui tap --udid #{udid} #{coordinates[:x]} #{coordinates[:y]}`
  end

  def press(coordinates:, duration:)
    Logger.info("Press (#{duration}s):", payload: JSON.pretty_generate(coordinates))
    @session[:actions] << { type: :press, x: coordinates[:x], y: coordinates[:y], duration: duration } unless session_actions
    `idb ui tap --udid #{udid} --duration #{duration} #{coordinates[:x]} #{coordinates[:y]}`
  end

  def swipe(start_coordinates:, end_coordinates:, duration:)
    payload = "#{JSON.pretty_generate(start_coordinates)} => #{JSON.pretty_generate(end_coordinates)}"
    Logger.info("Swipe (#{duration}s):", payload: payload)
    unless session_actions
      @session[:actions] << {
        type: :swipe,
        x: start_coordinates[:x],
        y: start_coordinates[:y],
        endX: end_coordinates[:x],
        endY: end_coordinates[:y],
        duration: duration
      }
    end
    coordinates = "#{start_coordinates[:x]} #{start_coordinates[:y]} #{end_coordinates[:x]} #{end_coordinates[:y]}"
    `idb ui swipe --udid #{udid} --duration #{duration} #{coordinates}`
  end

  def central_coordinates(element)
    frame = element['frame']
    x = (frame['x'] + (frame['width'] / 2)).abs.to_i
    y = (frame['y'] + (frame['height'] / 2)).abs.to_i
    {
      x: x > screen_size[:width].to_i ? random_coordinates[:x] : x,
      y: y > screen_size[:height].to_i ? random_coordinates[:y] : y
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

  def save_session
    return if session_path.nil?

    File.write("#{session_path}/xcmonkey-session.json", JSON.pretty_generate(@session))
  end

  # This function takes ≈200ms
  def track_running_apps
    current_list_of_running_apps = list_running_apps
    if @running_apps != current_list_of_running_apps
      currently_running_bundle_ids = current_list_of_running_apps.map { |app| app['bundle_id'] }
      previously_running_bundle_ids = @running_apps.map { |app| app['bundle_id'] }
      new_apps = currently_running_bundle_ids - previously_running_bundle_ids

      return if new_apps.empty?

      launch_app(target_bundle_id: bundle_id)

      new_apps.each do |id|
        Logger.warn("Shutting down: #{id}")
        terminate_app(id)
      end
    end
  end

  # This function takes ≈300ms
  def detect_app_state_change
    return unless detect_app_in_background

    target_app_is_running = list_running_apps.any? { |app| app['bundle_id'] == bundle_id }

    if target_app_is_running || ignore_crashes
      launch_app(target_bundle_id: bundle_id)
    else
      save_session
      Logger.error("Target app has crashed or been terminated")
    end
  end

  def detect_app_in_background
    current_app_label = describe_ui.detect { |el| el['type'] == 'Application' }['AXLabel']
    current_app_label.nil? || current_app_label.strip.empty?
  end

  def check_speed_limit
    sleep(throttle / 1000.0) if throttle.to_i > 0
  end

  private

  def ensure_driver_installed
    Logger.error("'idb' doesn't seem to be installed") if `which idb`.strip.empty?
  end

  def wait_until_app_launched(target_bundle_id)
    app_is_running = false
    current_time = Time.now
    while !app_is_running && Time.now < current_time + 5
      app_info = list_apps.detect { |app| app['bundle_id'] == target_bundle_id }
      app_is_running = app_info && app_info['process_state'] == 'Running'
    end
    Logger.error("Can't run the app #{target_bundle_id}") unless app_is_running
    Logger.info('App info:', payload: JSON.pretty_generate(app_info))
  end
end
