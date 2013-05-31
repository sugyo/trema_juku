require 'log'
require 'sinatra/base'
require 'webrick'
require 'json'

class ThreadServer
  def ThreadServer.start
    Thread.new do
      yield
      exit
    end
  end

end

class TestControllerWeb < Sinatra::Base
  logger = Log.instance
  use Rack::CommonLogger, logger
  set :server_settings, {
    :Logger => logger,
    :AccessLog => [
      [ logger, WEBrick::AccessLog::COMMON_LOG_FORMAT ],
      [ logger, WEBrick::AccessLog::REFERER_LOG_FORMAT ]
    ],
    :ServerType => ThreadServer
  }

  get '/foo' do
    foo = App[ 'TestController' ].foo
    content_type :json
    JSON.pretty_generate( foo ) + "\n"
  end

end
