require 'log'
require 'switches'
require 'test-controller-web'

module Trema
  class StatReply
    OFPSF_REPLY_MORE = 1
  end

  class DescStatsReply
    def more?
      ( flags & StatReply::OFPSF_REPLY_MORE ) == StatReply::OFPSF_REPLY_MORE
    end
  end
end

class TestController < Controller
  def start
    logger.info "start"
    Thread.new do
      TestControllerWeb.run!
      exit
    end
  end

  def switch_ready datapath_id
    logger.info "switch_ready"
    send_message datapath_id, FeaturesRequest.new
    send_message datapath_id, DescStatsRequest.new
    Switches.instance.add( datapath_id )
  end

  def switch_disconnected datapath_id
    logger.info "switch_disconnected"
    Switches.instance.delete( datapath_id )
  end

  def features_reply datapath_id, message
    logger.info "switch_features"
    switch = Switches.instance[ datapath_id ]
    return if switch.nil?
    message.ports.each do | each |
      switch.add each
    end
  end

  def port_status_add datapath_id, message
    logger.info "port_status_{add,modify}"
    switch = Switches.instance[ datapath_id ]
    return if switch.nil?
    switch.add message.phy_port
  end
  alias port_status_modify port_status_add

  def port_status_delete datapath_id, message
    logger.info "port_status_delete"
    switch = Switches.instance[ datapath_id ]
    return if switch.nil?
    switch.delete message.phy_port
  end

  def port_status datapath_id, message
    case message.reason
    when PortStatus::OFPPR_ADD
      port_status_add datapath_id, message
    when PortStatus::OFPPR_MODIFY
      port_status_modify datapath_id, message
    when PortStatus::OFPPR_DELETE
      port_status_delete datapath_id, message
    end
  end

  def desc_stats_reply datapath_id, message
    switch = Switches.instance[ datapath_id ]
    return if switch.nil? and message.stats.size == 0
    switch.description = message.stats.first
  end

  def stats_reply datapath_id, message
    case message.type
    when StatsReply::OFPST_DESC
      desc_stats_reply( datapath_id, message ) if respond_to? 'desc_stats_reply'
    end
  end

  private

  def logger
    Log.instance
  end
end
