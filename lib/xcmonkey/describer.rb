class Describer
	attr_accessor :udid, :x, :y, :driver

	def initialize(params)
		ensure_required_params(params)
		self.udid = params[:udid]
		self.x = params[:x]
		self.y = params[:y]
		self.driver = Driver.new(params)
	end

	def run
		driver.ensure_device_exists
		driver.describe_point(x, y)
	end

	def ensure_required_params(params)
		Logger.error('UDID should be provided') if params[:udid].nil?
		Logger.error('`x` point coordinate should be provided') if params[:x].nil? || params[:x].to_i.to_s != params[:x].to_s
		Logger.error('`y` point coordinate should be provided') if params[:y].nil? || params[:y].to_i.to_s != params[:y].to_s
	end
end
