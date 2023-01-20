describe Driver do
  let(:udid) { `xcrun simctl list | grep " iPhone 14 Pro Max"`.split("\n")[0].split('(')[1].split(')')[0] }
  let(:bundle_id) { 'com.apple.Maps' }
  let(:driver) { described_class.new(udid: udid, bundle_id: bundle_id, session_path: Dir.pwd) }
  let(:driver_with_session) { described_class.new(udid: udid, bundle_id: bundle_id, session_actions: [{ type: 'tap', x: 0, y: 0 }]) }

  it 'verifies that sumulator was booted' do
    error_message = "Failed to boot #{udid}"
    expect(Logger).not_to receive(:error).with(error_message, payload: nil)
    expect { driver.boot_simulator }.not_to raise_error
  end

  it 'verifies that ui can be described' do
    driver.boot_simulator
    ui = driver.describe_ui
    expect(ui).not_to be_empty
  end

  it 'verifies that home screen can be opened' do
    driver.boot_simulator
    home_tracker = driver.open_home_screen(with_tracker: true)
    expect(home_tracker).not_to be_empty
  end

  it 'verifies that home screen can be opened without tracker' do
    driver.boot_simulator
    home_tracker = driver.open_home_screen(with_tracker: false)
    expect(home_tracker).to be_nil
  end

  it 'verifies that list of targets can be showed' do
    list_targets = driver.list_targets
    expect(list_targets).not_to be_empty
  end

  it 'verifies that list of apps can be showed' do
    driver.boot_simulator
    app_exists = driver.list_apps.any? { |app| app['bundle_id'] == bundle_id }
    expect(app_exists).to be(true)
  end

  it 'verifies that app installed' do
    driver.boot_simulator
    error_message = "App #{bundle_id} is not installed on device #{udid}"
    expect(Logger).not_to receive(:error).with(error_message, payload: nil)
    expect { driver.ensure_app_installed }.not_to raise_error
  end

  it 'verifies that app is not installed' do
    driver.boot_simulator
    bundle_id = 'fake.app.bundle.id'
    error_message = "App #{bundle_id} is not installed on device #{udid}"
    driver = described_class.new(udid: udid, bundle_id: bundle_id)
    expect(Logger).to receive(:log).with(error_message, color: :light_red, payload: nil)
    expect { driver.ensure_app_installed }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
  end

  it 'verifies that device exists' do
    payload = driver.list_targets.detect { |target| target['udid'] == udid }
    expect(Logger).not_to receive(:error)
    expect(Logger).to receive(:info).with('Device info:', payload: JSON.pretty_generate(payload))
    expect(driver).to receive(:boot_simulator)
    expect(driver).to receive(:configure_simulator_keyboard)
    expect { driver.ensure_device_exists }.not_to raise_error
  end

  it 'verifies that device does not exist' do
    udid = '1234-5678'
    error_message = "Can't find device #{udid}"
    driver = described_class.new(udid: udid, bundle_id: bundle_id)
    expect(Logger).to receive(:log).with(error_message, color: :light_red, payload: nil)
    expect { driver.ensure_device_exists }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
  end

  it 'verifies that idb installed' do
    error_message = "'idb' doesn't seem to be installed"
    expect(Logger).not_to receive(:error).with(error_message, payload: nil)
    expect { driver.send(:ensure_driver_installed) }.not_to raise_error
  end

  it 'verifies that element central coordinates can be found' do
    element = JSON.parse('{ "frame": { "x": 0, "y": 0, "width": 100, "height": 100 } }')
    expected_coordinates = { 'x': 50, 'y': 50 }
    actual_coordinates = driver.central_coordinates(element)
    expect(actual_coordinates).to eq(expected_coordinates)
  end

  it 'verifies that device info can be for booted simulator' do
    driver.boot_simulator
    expect(driver.device_info).not_to be_empty
  end

  it 'verifies that device info can be for not booted simulator' do
    driver.shutdown_simulator
    expect(driver.device_info).not_to be_empty
  end

  it 'verifies that screen size can be found' do
    driver.boot_simulator
    screen_size = driver.screen_size
    expect(screen_size[:width]).to be > 0
    expect(screen_size[:height]).to be > 0
  end

  it 'verifies that random coordinates can be found' do
    driver.boot_simulator
    coordinates = driver.random_coordinates
    expect(coordinates[:x]).to be > 0
    expect(coordinates[:y]).to be > 0
  end

  it 'verifies swipe duration' do
    expect(driver.swipe_duration).to be_between(0.1, 0.7)
  end

  it 'verifies press duration' do
    expect(driver.press_duration).to be_between(0.5, 1.5)
  end

  it 'verifies that simulator keyboard can be enabled' do
    allow(driver).to receive(:is_simulator_keyboard_enabled?).and_return(false)
    driver = described_class.new(udid: udid, bundle_id: bundle_id, enable_simulator_keyboard: true)
    expect(driver).to receive(:shutdown_simulator)
    driver.configure_simulator_keyboard
    keyboard_state = `defaults read com.apple.iphonesimulator`.split("\n").grep(/ConnectHardwareKeyboard/)
    expect(keyboard_state).not_to be_empty
    expect(keyboard_state.first).to include('0')
  end

  it 'verifies that simulator keyboard can be disabled' do
    allow(driver).to receive(:is_simulator_keyboard_enabled?).and_return(true)
    driver = described_class.new(udid: udid, bundle_id: bundle_id, enable_simulator_keyboard: false)
    expect(driver).to receive(:shutdown_simulator)
    driver.configure_simulator_keyboard
    keyboard_state = `defaults read com.apple.iphonesimulator`.split("\n").grep(/ConnectHardwareKeyboard/)
    expect(keyboard_state).not_to be_empty
    expect(keyboard_state.first).to include('1')
  end

  it 'verifies that app can be launched' do
    expect(Logger).not_to receive(:error)
    expect(Logger).to receive(:info)
    driver.boot_simulator
    driver.terminate_app
    expect { driver.launch_app }.not_to raise_error
  end

  it 'verifies tap in new session' do
    driver.boot_simulator
    coordinates = { x: 1, y: 1 }
    expect(Logger).to receive(:info).with('Tap:', payload: JSON.pretty_generate(coordinates))
    driver.tap(coordinates: coordinates)
    expect(driver.instance_variable_get(:@session)[:actions]).not_to be_empty
  end

  it 'verifies tap in old session' do
    driver_with_session.boot_simulator
    coordinates = { x: 1, y: 1 }
    expect(Logger).to receive(:info).with('Tap:', payload: JSON.pretty_generate(coordinates))
    driver_with_session.tap(coordinates: coordinates)
    expect(driver_with_session.instance_variable_get(:@session)[:actions]).to be_empty
  end

  it 'verifies press in new session' do
    driver.boot_simulator
    duration = 0.5
    coordinates = { x: 1, y: 1 }
    expect(Logger).to receive(:info).with("Press (#{duration}s):", payload: JSON.pretty_generate(coordinates))
    driver.press(coordinates: coordinates, duration: duration)
    expect(driver.instance_variable_get(:@session)[:actions]).not_to be_empty
  end

  it 'verifies press in old session' do
    driver_with_session.boot_simulator
    duration = 0.5
    coordinates = { x: 1, y: 1 }
    expect(Logger).to receive(:info).with("Press (#{duration}s):", payload: JSON.pretty_generate(coordinates))
    driver_with_session.press(coordinates: coordinates, duration: duration)
    expect(driver_with_session.instance_variable_get(:@session)[:actions]).to be_empty
  end

  it 'verifies swipe in new session' do
    driver.boot_simulator
    duration = 0.5
    start_coordinates = { x: 1, y: 1 }
    end_coordinates = { x: 2, y: 2 }
    expect(Logger).to receive(:info).with("Swipe (#{duration}s):", payload: "#{JSON.pretty_generate(start_coordinates)} => #{JSON.pretty_generate(end_coordinates)}")
    driver.swipe(start_coordinates: start_coordinates, end_coordinates: end_coordinates, duration: duration)
    expect(driver.instance_variable_get(:@session)[:actions]).not_to be_empty
  end

  it 'verifies swipe in old session' do
    driver_with_session.boot_simulator
    duration = 0.5
    start_coordinates = { x: 1, y: 1 }
    end_coordinates = { x: 2, y: 2 }
    expect(Logger).to receive(:info).with("Swipe (#{duration}s):", payload: "#{JSON.pretty_generate(start_coordinates)} => #{JSON.pretty_generate(end_coordinates)}")
    driver_with_session.swipe(start_coordinates: start_coordinates, end_coordinates: end_coordinates, duration: duration)
    expect(driver_with_session.instance_variable_get(:@session)[:actions]).to be_empty
  end

  it 'verifies that session can be saved' do
    expect(File).to receive(:write)
    driver.instance_variable_set(:@session, { params: {}, actions: [] })
    driver.save_session
  end

  it 'verifies that monkey_test_precondition works fine' do
    driver.monkey_test_precondition
    app_info = driver.list_apps.detect { |app| app['bundle_id'] == bundle_id }
    app_is_running = app_info && app_info['process_state'] == 'Running'
    expect(app_is_running).to be(true)
  end

  it 'verifies that monkey_test works fine' do
    params = { udid: udid, bundle_id: bundle_id, duration: 1, session_path: Dir.pwd }
    driver = described_class.new(params)
    expect(driver).to receive(:monkey_test_precondition)
    driver.monkey_test(Xcmonkey.new(params).gestures)
    expect(driver.instance_variable_get(:@session)[:actions]).not_to be_empty
  end

  it 'verifies that repeat_monkey_test works fine' do
    session_actions = [
      { 'type' => 'tap', 'x' => 10, 'y' => 10 },
      { 'type' => 'press', 'x' => 11, 'y' => 11, 'duration' => 1.4 },
      { 'type' => 'swipe', 'x' => 12, 'y' => 12, 'endX' => 15, 'endY' => 15, 'duration' => 0.3 }
    ]
    driver = described_class.new(udid: udid, bundle_id: bundle_id, session_actions: session_actions)
    allow(Logger).to receive(:info).twice
    expect(driver).to receive(:monkey_test_precondition)
    expect(driver).to receive(:tap).with(coordinates: { x: 10, y: 10 })
    expect(driver).to receive(:press).with(coordinates: { x: 11, y: 11 }, duration: 1.4)
    expect(driver).to receive(:swipe).with(start_coordinates: { x: 12, y: 12 }, end_coordinates: { x: 15, y: 15 }, duration: 0.3)
    driver.repeat_monkey_test
    expect(driver.instance_variable_get(:@session)[:actions]).to be_empty
  end

  it 'verifies that unknown actions does not break repeat_monkey_test' do
    driver = described_class.new(udid: udid, bundle_id: bundle_id, session_actions: [{ 'type' => 'test', 'x' => 10, 'y' => 10 }])
    allow(Logger).to receive(:info).twice
    expect(driver).to receive(:monkey_test_precondition)
    expect(driver).not_to receive(:tap)
    expect(driver).not_to receive(:press)
    expect(driver).not_to receive(:swipe)
    driver.repeat_monkey_test
    expect(driver.instance_variable_get(:@session)[:actions]).to be_empty
  end

  it 'verifies that simulator was not booted' do
    driver.shutdown_simulator
    error_message = "Failed to boot #{udid}"
    allow(driver).to receive(:device_info).and_return({ 'state' => 'Unknown' })
    expect(Logger).to receive(:log).with(error_message, color: :light_red, payload: nil)
    expect { driver.boot_simulator }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
  end
end
