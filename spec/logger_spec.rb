describe Logger do
  let(:message) { 'test' }
  let(:payload) { '{"test": true}' }

  it 'verifies info log without payload' do
    expect(described_class).to receive(:log).with(message, color: :light_cyan, payload: nil)
    described_class.info(message)
  end

  it 'verifies info log with payload' do
    expect(described_class).to receive(:log).with(message, color: :light_cyan, payload: payload)
    described_class.info(message, payload: payload)
  end

  it 'verifies warning log without payload' do
    expect(described_class).to receive(:log).with(message, color: :light_yellow, payload: nil)
    described_class.warn(message)
  end

  it 'verifies warning log with payload' do
    expect(described_class).to receive(:log).with(message, color: :light_yellow, payload: payload)
    described_class.warn(message, payload: payload)
  end

  it 'verifies error log without payload' do
    expect(described_class).to receive(:log).with(message, color: :light_red, payload: nil)
    expect { described_class.error(message) }
      .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
  end

  it 'verifies error log with payload' do
    expect(described_class).to receive(:log).with(message, color: :light_red, payload: payload)
    expect { described_class.error(message, payload: payload) }
      .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
  end

  it 'verifies custom log without payload' do
    color = :blue
    time = Time.now
    allow(Time).to receive(:now).and_return(time)
    expected_output = "#{time.strftime('%k:%M:%S.%L')}: #{message}".colorize(color)
    expect do
      described_class.log(message, color: color, payload: nil)
    end.to output("#{expected_output}\n\n").to_stdout
  end

  it 'verifies custom log with payload' do
    color = :blue
    time = Time.now
    allow(Time).to receive(:now).and_return(time)
    expected_output = "#{time.strftime('%k:%M:%S.%L')}: #{message}".colorize(color)
    expect do
      described_class.log(message, color: color, payload: payload)
    end.to output("#{expected_output} #{payload.colorize(:light_green)}\n\n").to_stdout
  end
end
