require 'singleton'
require 'syslog/logger'

class Log < Syslog::Logger
  include Singleton

  def initialize
    program_name = 'TestControllerWeb.log'

    super( program_name )
    @level = Logger::INFO
  end

  def write message
    self << message
  end

  def << message
    info message
  end

end
