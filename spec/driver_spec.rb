describe Driver do
  let(:udid) { `xcrun simctl list | grep " iPhone 14 Pro Max"`.split("\n")[0].split('(')[1].split(')')[0] }
  let(:bundle_id) { 'com.apple.Maps' }
  let(:driver) { described_class.new(udid: udid, bundle_id: bundle_id) }

  it 'verifies that sumulator was booted' do
    error_message = "Failed to boot #{udid}"
    expect(Logger).not_to receive(:error).with(error_message, payload: nil)
    expect(driver).to receive(:ensure_simulator_was_booted)
    driver.boot_simulator
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
    home_tracker = driver.open_home_screen(return_tracker: true)
    expect(home_tracker).not_to be_empty
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

  it 'verifies that simulator was not booted' do
    driver.shutdown_simulator
    error_message = "Failed to boot #{udid}"
    expect(Logger).to receive(:log).with(error_message, color: :light_red, payload: nil)
    expect { driver.ensure_simulator_was_booted }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
  end
end
