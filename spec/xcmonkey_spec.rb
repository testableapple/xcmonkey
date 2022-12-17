describe Xcmonkey do
  describe Xcmonkey::Xcmonkey do
    let(:params) { { udid: '123', bundle_id: 'example.com.app', duration: 10 } }
    let(:duration_error_msg) { 'Duration must be Integer and not less than 1 second' }

    it 'verifies gestures' do
      gestures = described_class.new(params).gestures
      expect(gestures) =~ [:swipe, :precise_tap, :blind_tap]
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
  end
end
