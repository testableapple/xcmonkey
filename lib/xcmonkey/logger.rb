class Logger
  def self.info(message, payload: nil)
    log(message, color: :light_cyan, payload: payload)
  end

  def self.warn(message, payload: nil)
    log(message, color: :light_yellow, payload: payload)
  end

  def self.error(message, payload: nil)
    log(message, color: :light_red, payload: payload)
    Process.exit(1)
  end

  def self.log(message, color:, payload:)
    message = "#{Time.now.strftime('%k:%M:%S.%L')}: #{message}".colorize(color)
    if payload
      print(message, ' ', payload.colorize(:light_green), "\n\n")
    else
      puts("#{message}\n\n")
    end
  end
end
