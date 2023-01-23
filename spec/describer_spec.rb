describe Describer do
  let(:udid) { `xcrun simctl list | grep " iPhone 14 Pro Max"`.split("\n")[0].split('(')[1].split(')')[0] }
  let(:driver) { Driver.new(udid: udid) }

  before do
    allow(Logger).to receive(:info)
  end

  it 'verifies that point can be described (integer)' do
    driver.boot_simulator
    point_info = described_class.new(udid: udid, x: 10, y: 10).run
    expect(point_info).not_to be_empty
  end

  it 'verifies that point can be described (string)' do
    driver.boot_simulator
    point_info = described_class.new(udid: udid, x: '10', y: '10').run
    expect(point_info).not_to be_empty
  end

  it 'verifies `udid` param is required' do
    expect(Logger).to receive(:error).with('UDID should be provided')
    described_class.new(x: 10, y: 10)
  end

  it 'verifies `x` param is required' do
    expect(Logger).to receive(:error).with('`x` point coordinate should be provided')
    described_class.new(udid: udid, y: '10')
  end

  it 'verifies `y` param is required' do
    expect(Logger).to receive(:error).with('`y` point coordinate should be provided')
    described_class.new(udid: udid, x: '10')
  end

  it 'verifies `x` param is integer' do
    expect(Logger).to receive(:error).with('`x` point coordinate should be provided')
    described_class.new(udid: udid, x: 'test', y: '10')
  end

  it 'verifies `y` param is integer' do
    expect(Logger).to receive(:error).with('`y` point coordinate should be provided')
    described_class.new(udid: udid, x: '10', y: 'test')
  end
end
