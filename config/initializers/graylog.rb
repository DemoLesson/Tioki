require 'gelf'

class MultiLogger
  def initialize(*objects)
    @objects = objects
  end

  def method_missing(*args)
    @objects.each {|o| o.send(*args) }
  end
end

glconfig = Hash.new
glconfig["server"] = "50.112.232.249"
glconfig["port"] = 12201
glconfig["host"] = `hostname`

test = RestClient.get('http://' + glconfig["server"]) rescue false

if test != false
  gelf_logger = GELF::Logger.new(glconfig["server"],
    glconfig["port"],
    'LAN',
    'facility' => 'rails',
    'host' => glconfig["host"]
  )
  Rails.logger = MultiLogger.new(Rails.logger, gelf_logger)

  # Notify is more detailed the Rails Logger
  NOTIFY = GELF::Notifier.new(glconfig["server"],
    glconfig["port"],
    'LAN',
    'facility' => 'rails',
    'host' => glconfig["host"]
  )
  NOTIFY.collect_file_and_line = false

  # See https://github.com/Graylog2/graylog2_exceptions/wiki
  Rails.application.config.middleware.use "Graylog2Exceptions",
    {
      :hostname => glconfig["server"],
      :port => glconfig["port"],
      :facility => "rails_exceptions",
      :local_app_name => glconfig["host"],
      :level => GELF::FATAL,
      :max_chunk_size => 'LAN'
    }

  # Setup logging unhandled resque exceptions to graylog
  Graylog2::Resque::FailureHandler.configure do |config|
    config.gelf_server = glconfig["server"]
    config.gelf_port = glconfig["port"]
    config.host = glconfig["host"]
    config.facility = "resque_exceptions"
    config.level = GELF::FATAL
    config.max_chunk_size = 'LAN'
  end

  require 'resque/failure/multiple'
  require 'resque/failure/redis'
  Resque::Failure::Multiple.classes = [
      Graylog2::Resque::FailureHandler,
      Resque::Failure::Redis
  ]
  Resque::Failure.backend = Resque::Failure::Multiple
end