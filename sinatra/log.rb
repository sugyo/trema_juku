require 'syslog/logger'
require 'trema/path'

class Logger
  def write message
    self << message
  end

end

class Formatter < Logger::Formatter
  def call( severity, time, progname, msg )
    "[%s.%06d] %-5s %s\n" % [ time.strftime( '%Y-%m-%d %H:%M:%S' ), time.usec.to_s, severity, msg2str( msg ) ]
  end
end

class Syslog::Logger
  def write message
    self << message
  end

  def << message
    info message
  end

end

class Log
  class << self
    def instance
      if @logger.nil?
        #output = :syslog
        #output = STDOUT
        output = File.join( Trema.log, 'TestControllerWeb.log' )
        if output == :syslog
          program_name = 'TestControllerWeb'
          @logger = Syslog::Logger.new( program_name )
        else
          file = output
          shift_age = 0
          shift_size = 1048576
          @logger = Logger.new( file, shift_age, shift_size )
          @logger.formatter = Formatter.new
          @logger.formatter.datetime_format = "%Y-%m-%d %H:%M:%S"
        end
	@logger.level = Logger::INFO
      end
      @logger
    end

  end

end
