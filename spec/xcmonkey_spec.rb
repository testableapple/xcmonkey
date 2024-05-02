describe Xcmonkey do
  let(:params) { { udid: '123', bundle_id: 'example.com.app', event_count: 10, session_path: Dir.pwd } }
  let(:event_count_error_msg) { 'Event count must be Integer and not less than 1' }

  before do
    allow(Logger).to receive(:info)
  end

  it 'verifies gestures' do
    gestures = described_class.new(params).gestures
    taps = [:precise_tap, :blind_tap] * 10
    swipes = [:precise_swipe, :blind_swipe] * 5
    presses = [:precise_press, :blind_press]
    expect(gestures).to match_array(presses + taps + swipes)
  end

  it 'verifies gestures without taps' do
    params[:exclude_taps] = true
    gestures = described_class.new(params).gestures
    swipes = [:precise_swipe, :blind_swipe] * 5
    presses = [:precise_press, :blind_press]
    expect(gestures).to match_array(presses + swipes)
  end

  it 'verifies gestures without swipes' do
    params[:exclude_swipes] = true
    gestures = described_class.new(params).gestures
    taps = [:precise_tap, :blind_tap] * 10
    presses = [:precise_press, :blind_press]
    expect(gestures).to match_array(presses + taps)
  end

  it 'verifies gestures without presses' do
    params[:exclude_presses] = true
    gestures = described_class.new(params).gestures
    taps = [:precise_tap, :blind_tap] * 10
    swipes = [:precise_swipe, :blind_swipe] * 5
    expect(gestures).to match_array(swipes + taps)
  end

  it 'verifies required params' do
    expect(Logger).not_to receive(:error)
    described_class.new(params)
  end

  it 'verifies `udid` param is required' do
    params[:udid] = nil
    expect(Logger).to receive(:error).with('UDID should be provided')
    described_class.new(params)
  end

  it 'verifies `bundle_id` param is required' do
    params[:bundle_id] = nil
    expect(Logger).to receive(:error).with('Bundle identifier should be provided')
    described_class.new(params)
  end

  it 'verifies `event_count` param is optional' do
    params[:event_count] = nil
    expect(Logger).not_to receive(:error)
    described_class.new(params)
  end

  it 'verifies `event_count` param cannot be equal to zero' do
    params[:event_count] = 0
    expect(Logger).to receive(:error).with(event_count_error_msg)
    described_class.new(params)
  end

  it 'verifies `event_count` param cannot be negative' do
    params[:event_count] = -1
    expect(Logger).to receive(:error).with(event_count_error_msg)
    described_class.new(params)
  end

  it 'verifies version' do
    current_version = Gem::Version.new(Xcmonkey::VERSION)
    expect(current_version).to be > Gem::Version.new('0.1.0')
  end
end
