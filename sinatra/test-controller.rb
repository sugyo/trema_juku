require 'log'
require 'test-controller-web'


class TestController < Controller
  def start
    TestControllerWeb.run!
    logger.info "start"
    @variable = "start"
  end

  def foo
    logger.info "foo"
    { :a => 1, :b => 2, :v => @variable }
  end

  def switch_ready datapath_id
    logger.info "switch_ready"
    @variable = datapath_id.to_s
  end

  private

  def logger
    Log.instance
  end

end
