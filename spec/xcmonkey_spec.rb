describe Xcmonkey do
  describe Xcmonkey::Xcmonkey do
    let(:params) { { udid: '123', bundle_id: 'example.com.app', duration: 10, session_path: Dir.pwd } }
    let(:duration_error_msg) { 'Duration must be Integer and not less than 1 second' }

    it 'verifies gestures' do
      gestures = described_class.new(params).gestures
      taps = [:precise_tap, :blind_tap] * 10
      swipes = [:precise_swipe, :blind_swipe] * 5
      presses = [:precise_press, :blind_press]
      expect(gestures) =~ presses + taps + swipes
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

    it 'verifies `duration` param is required' do
      params[:duration] = nil
      expect(Logger).to receive(:error).with(duration_error_msg)
      described_class.new(params)
    end

    it 'verifies `duration` param cannot be equal to zero' do
      params[:duration] = 0
      expect(Logger).to receive(:error).with(duration_error_msg)
      described_class.new(params)
    end

    it 'verifies `duration` param cannot be negative' do
      params[:duration] = -1
      expect(Logger).to receive(:error).with(duration_error_msg)
      described_class.new(params)
    end

    it 'verifies version' do
      current_version = Gem::Version.new(Xcmonkey::VERSION)
      expect(current_version).to be > Gem::Version.new('0.1.0')
    end

    it 'verifies gem name' do
      expect(Xcmonkey::GEM_NAME).to eq('xcmonkey')
    end
  end
end
