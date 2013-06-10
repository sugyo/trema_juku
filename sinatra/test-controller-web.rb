require 'json'
require 'sinatra/base'
require 'webrick'
require 'log'
require 'switches'

class ThreadServer
  def ThreadServer.start
    Thread.new do
      yield
      exit
    end
  end
end

class Time
  def to_s
    strftime( "%Y-%m-%d %H:%M:%S" )
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

  def json_body value = nil
    content_type :json
    body JSON.pretty_generate( value ) + "\n"
  end

  get '/switches/?' do
    switches = Switches.instance.list.collect do | datapath_id |
      datapath_id.to_hex
    end
    json_body switches
  end

  get '/switches/:datapath_id/?' do | datapath_id |
    switch = Switches.instance[ datapath_id.hex ]
    if switch.nil?
      status 404
    else
      json_body :registered_at => switch.registered_at
    end
  end

  get '/switches/:datapath_id/description/?' do | datapath_id |
    switch = Switches.instance[ datapath_id.hex ]
    if switch.nil?
      status 404
    else
      json_body switch.description
    end
  end

  get '/switches/:datapath_id/features/?' do | datapath_id |
    switch = Switches.instance[ datapath_id.hex ]
    if switch.nil?
      status 404
    else
      json_body switch.features
    end
  end

  get '/switches/:datapath_id/ports/?' do | datapath_id |
    switch = Switches.instance[ datapath_id.hex ]
    if switch.nil?
      status 404
    else
      json_body switch.ports.values
    end
  end

  get '/*' do
    status 404
  end
end

if Sinatra::VERSION == "1.2.6"
  class WEBrickWrapper < Rack::Handler::WEBrick
    def self.run( app, options = {} )
      options.merge! TestControllerWeb.settings.server_settings
      super( app, options )
    end
  end
  Rack::Handler.register 'webrick', 'WEBrickWrapper'
end
