require 'singleton'
require 'log'

class Switch
  attr_reader :datapath_id, :description, :features
  attr_accessor :ports
  attr_reader :registered_at

  def initialize datapath_id
    @datapath_id = datapath_id
    @features = {}
    @description = {}
    @ports = {}
    @registered_at = Time.now
  end

  def features= features
    @features = {
      :n_buffers => features.n_buffers,
      :n_tables => features.n_tables,
      :capabilities => features.capabilities,
      :actions => features.capabilities,
      :updated_at => Time.new
    }
  end

  def description= desc_stats
    @description = {
      :mfr_desc => desc_stats.mfr_desc,
      :hw_desc => desc_stats.hw_desc,
      :sw_desc => desc_stats.sw_desc,
      :serial_num => desc_stats.serial_num,
      :dp_desc => desc_stats.dp_desc,
      :updated_at => Time.new
    }
  end

  def add port
    @ports.each_value do | each |
      if each[ :name ] == port.name
        @ports.delete each[ :number ]
        break
      end
    end
    @ports[ port.number ] = {
      :number => port.number,
      :hw_addr => port.hw_addr,
      :name => port.name,
      :config => port.config,
      :state => port.state,
      :curr => port.curr,
      :curr => port.curr,
      :advertised => port.advertised,
      :supported => port.supported,
      :peer => port.peer,
      :updated_at => Time.now
    }
  end

  def delete port
    @ports.delete port.number
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
