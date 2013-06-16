require 'json'
require 'sinatra/base'
require 'webrick'
require 'log'
require 'switches'

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
    :ServerType => WEBrick::SimpleServer
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
      ports = switch.ports.values.collect do | each |
        each[ :number ]
      end
      json_body ports
    end
  end

  get '/switches/:datapath_id/ports/:port_no/?' do | datapath_id, port_no |
    switch = Switches.instance[ datapath_id.hex ]
    if switch.nil?
      status 404
    else
      port = switch.ports[ port_no.to_i ]
      if port.nil?
        status 404
      else
        json_body port
      end
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
