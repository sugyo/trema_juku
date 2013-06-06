require 'log'
require 'switches'
require 'test-controller-web'

class TestController < Controller
  def start
    logger.info "start"
    TestControllerWeb.run!
  end

  def switch_ready datapath_id
    logger.info "switch_ready"
    send_message datapath_id, DescStatsRequest.new
    Switches.instance.add( datapath_id )
  end

  def switch_disconnected datapath_id
    Switches.instance.delete( datapath_id )
  end

  def stats_reply datapath_id, message
    switch = Switches.instance[ datapath_id ]
    return if switch.nil?
    message.stats.each do | stats |
      if stats.is_a?( DescStatsReply )
        switch.description = stats
      end
    end
  end

  private

  def logger
    Log.instance
  end
end
