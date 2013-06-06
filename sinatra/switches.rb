require 'singleton'
require 'log'

class Switch
  attr_reader :datapath_id, :registered_at
  attr_accessor :description

  def initialize datapath_id
    @datapath_id = datapath_id
    @description = nil
    @registered_at = Time.now
  end

  def description
    desc = { :registered_at => @registered_at.strftime( "%Y-%m-%d %H:%M:%S" ) }
    unless @description.nil?
      desc.merge(
        :mfr_desc => @description.mfr_desc,
        :hw_desc => @description.hw_desc,
        :sw_desc => @description.sw_desc,
        :serial_num => @description.serial_num,
        :dp_desc => @description.dp_desc
      )
    end
  end
end

class Switches
  include Singleton

  def initialize
    @switches = {}
  end

  def list
    @switches.keys
  end

  def add datapath_id
    @switches[ datapath_id.to_i ] = Switch.new( datapath_id.to_i )
  end

  def delete datapath_id
    @switches.delete( datapath_id.to_i )
  end

  def [] datapath_id
    @switches[ datapath_id.to_i ]
  end
end
