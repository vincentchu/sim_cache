require 'spec_helper'

describe SimCache::MockCache do
  
  before(:all)  { @mock_cache = SimCache::MockCache.new(:max_keys => 5) }
  before(:each) do 
    @mock_cache.redis.flushdb
    @mock_cache.send(:init_counters!)
  end
  
  it "should have a method for getting" do
    @mock_cache.should respond_to(:get)
  end
  
  it "should instantiate a redis connection" do
    @mock_cache.redis.class.should == Redis
  end
  
  it "should raise an error if a key isn't found" do
    lambda { @mock_cache.get("unknown_key") }.should raise_error(SimCache::MockCache::KeyNotFound)
  end
  
  it "should act as an LRU-cache (i.e., more recent items have a higher rank)" do
    %w(key1 key2).each {|k| @mock_cache.get(k) rescue nil}
    %w(key1 key2).each_with_index {|k, i| @mock_cache.rank_for_key(k).should == 1-i}
  end
  
  it "should evict keys if the limit of the cache is exceeded" do
    (1..5).each {|i| @mock_cache.get("key_#{i}") rescue nil}    
    @mock_cache.get("key_1")
    @mock_cache.get("key_6") rescue nil
    
    @mock_cache.rank_for_key("key_6").should == 0
    @mock_cache.rank_for_key("key_1").should == 1
    @mock_cache.rank_for_key("key_2").should be_nil
    @mock_cache.num_keys.should == 5
  end  
  
  it "should tell you how many keys are in the cache" do
    (1..5).each do |i|
      @mock_cache.get("key_#{i}") rescue nil
      @mock_cache.num_keys.should == i
    end
  end
  
  it "should have basic methods for cache statistics" do
    @mock_cache.send(:init_counters!)
    4.times { @mock_cache.get("rand_key") rescue nil }

    @mock_cache.misses.should == 1
    @mock_cache.hits.should == 3
    @mock_cache.hit_rate.should == 0.75
    @mock_cache.miss_rate.should == 0.25
    @mock_cache.num_keys.should == 1
    @mock_cache.percent_utilization.should == 0.2
  end
end