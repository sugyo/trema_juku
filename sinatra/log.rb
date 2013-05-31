require 'logger'
require 'singleton'

class Log < Logger
  include Singleton

  def initialize
    #file = STDOUT
    file = File.join( Trema.log, 'TestControllerWeb.log' )
    shift_age = 0
    shift_size = 1048576

    super( file, shift_age, shift_size )
    @level = INFO
    @formatter = Formatter.new
    @formatter.datetime_format = "%Y-%m-%d %H:%M:%S"
  end

  def write message
    self << message
  end

  private

  class Formatter < Logger::Formatter
    def call( severity, time, progname, msg )
      "[%s.%06d] %-5s %s\n" % [ time.strftime( '%Y-%m-%d %H:%M:%S' ), time.usec.to_s, severity, msg2str( msg ) ]
    end
  end

end
