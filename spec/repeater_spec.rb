describe Repeater do
  let(:session_path) { 'test/path/session.json' }
  let(:session_file_content_full) { '{ "params": {"udid": "0", "bundle_id": "0", "enable_simulator_keyboard": true}, "actions": [{ "type": "tap", "x": 0, "y": 0 }] }' }
  let(:session_file_content_without_params) { '{ "actions": [{ "type": "tap", "x": 0, "y": 0 }] }' }
  let(:session_file_content_with_empty_actions) { '{ "params": {"udid": "0", "bundle_id": "0", "enable_simulator_keyboard": true}, "actions": [] }' }
  let(:session_file_content_without_actions) { '{ "params": {"udid": "0", "bundle_id": "0", "enable_simulator_keyboard": true} }' }
  let(:session_file_content_without_bundle_id) { '{ "params": {"udid": "0", "enable_simulator_keyboard": true}, "actions": [{ "type": "tap", "x": 0, "y": 0 }] }' }
  let(:session_file_content_without_udid) { '{ "params": {"bundle_id": "0", "enable_simulator_keyboard": true}, "actions": [{ "type": "tap", "x": 0, "y": 0 }] }' }

  it 'verifies that session cannot be validated without params' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(session_file_content_without_params)
    expect(Logger).to receive(:error).with('Provided session is not valid: `params` should not be `nil`')
    described_class.new(session_path: session_path)
  end

  it 'verifies that session cannot be validated without actions' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(session_file_content_without_actions)
    expect(Logger).to receive(:error).with('Provided session is not valid: `actions` should not be `nil` or `empty`')
    described_class.new(session_path: session_path)
  end

  it 'verifies that session cannot be validated with empty actions' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(session_file_content_with_empty_actions)
    expect(Logger).to receive(:error).with('Provided session is not valid: `actions` should not be `nil` or `empty`')
    described_class.new(session_path: session_path)
  end

  it 'verifies that session cannot be validated without bundle id' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(session_file_content_without_bundle_id)
    expect(Logger).to receive(:error).with('Provided session is not valid: `bundle_id` should not be `nil`')
    described_class.new(session_path: session_path)
  end

  it 'verifies that session cannot be validated without udid' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(session_file_content_without_udid)
    expect(Logger).to receive(:error).with('Provided session is not valid: `udid` should not be `nil`')
    described_class.new(session_path: session_path)
  end

  it 'verifies that session validation can pass' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(session_file_content_full)
    expect(Logger).not_to receive(:error)
    described_class.new(session_path: session_path)
  end
end
