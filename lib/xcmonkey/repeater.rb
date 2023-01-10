class Repeater
	attr_accessor :udid, :bundle_id, :enable_simulator_keyboard, :actions

	def initialize(params)
		validate_session(params[:session_path])
	end

	def run
		params = {
			udid: udid,
			bundle_id: bundle_id,
			enable_simulator_keyboard: enable_simulator_keyboard,
			session_actions: actions
		}
		Driver.new(params).repeat_monkey_test
	end

	def validate_session(session_path)
		Logger.error("Provided session can't be found: #{session_path}") unless File.exist?(session_path)

		session = JSON.parse(File.read(session_path))

		if session['params'].nil?
			Logger.error('Provided session is not valid: `params` should not be `nil`')
			return
		end

		self.actions = session['actions']
		Logger.error('Provided session is not valid: `actions` should not be `nil` or `empty`') if actions.nil? || actions.empty?

		self.udid = session['params']['udid']
		Logger.error('Provided session is not valid: `udid` should not be `nil`') if udid.nil?

		self.bundle_id = session['params']['bundle_id']
		Logger.error('Provided session is not valid: `bundle_id` should not be `nil`') if bundle_id.nil?

		self.enable_simulator_keyboard = session['params']['enable_simulator_keyboard']
	end
end
