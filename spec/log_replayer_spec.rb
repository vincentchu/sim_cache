require 'spec_helper'

describe SimCache::LogReplayer do
  
  before(:all) do
    @log_replayer = SimCache::LogReplayer.new(
      :log_file => test_log,
      :report_file => report_log,
      :cache_options => {:max_keys => 10}
    )
  end
  
  before(:each) { @log_replayer.mock_cache.redis.flushdb }
    
  it "should relay the log" do
    @log_replayer.replay!
  end  
end