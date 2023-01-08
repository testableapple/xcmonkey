describe Driver do
  let(:udid) { `xcrun simctl list | grep " iPhone 14 Pro Max"`.split("\n")[0].split('(')[1].split(')')[0] }
  let(:bundle_id) { 'com.apple.Maps' }
  let(:driver) { described_class.new(udid: udid, bundle_id: bundle_id) }

  it 'verifies that sumulator was booted' do
    error_message = "Failed to boot #{udid}"
    expect(Logger).not_to receive(:error).with(error_message, payload: nil)
    expect { driver.boot_simulator }.not_to raise_error
  end

  it 'verifies that there are booted simulators' do
    driver.boot_simulator
    booted_simulators = driver.list_booted_simulators
    expect(booted_simulators).not_to be_empty
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
    list_apps = driver.list_apps
    expect(list_apps).to include(bundle_id)
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
    error_message = "Can't find device #{udid}"
    payload = driver.list_targets.detect { |target| target.include?(udid) }
    expect(Logger).not_to receive(:error).with(error_message, payload: nil)
    expect(Logger).to receive(:info).with('Device info:', payload: payload)
    expect(driver).to receive(:boot_simulator)
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

  it 'verifies tap' do
    driver.boot_simulator
    coordinates = { x: 1, y: 1 }
    expect(Logger).to receive(:info).with('Tap:', payload: JSON.pretty_generate(coordinates))
    driver.tap(coordinates: coordinates)
  end

  it 'verifies press' do
    driver.boot_simulator
    duration = 0.5
    coordinates = { x: 1, y: 1 }
    expect(Logger).to receive(:info).with("Press (#{duration}s):", payload: JSON.pretty_generate(coordinates))
    driver.press(coordinates: coordinates, duration: duration)
  end

  it 'verifies swipe' do
    driver.boot_simulator
    duration = 0.5
    start_coordinates = { x: 1, y: 1 }
    end_coordinates = { x: 2, y: 2 }
    expect(Logger).to receive(:info).with("Swipe (#{duration}s):", payload: "#{JSON.pretty_generate(start_coordinates)} => #{JSON.pretty_generate(end_coordinates)}")
    driver.swipe(start_coordinates: start_coordinates, end_coordinates: end_coordinates, duration: duration)
  end

  it 'verifies that simulator was not booted' do
    driver.shutdown_simulator
    error_message = "Failed to boot #{udid}"
    allow(driver).to receive(:device_info).and_return({ 'state' => 'Unknown' })
    expect(Logger).to receive(:log).with(error_message, color: :light_red, payload: nil)
    expect { driver.boot_simulator }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
  end
end
