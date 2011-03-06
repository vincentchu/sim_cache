module SimCache
  class MockCache
    
    DEFAULT_MAX_KEYS = 100_000
    DEFAULT_CACHE_NAME = "cache"
    attr_reader :redis, :cache_name, :max_keys, :hits, :misses
    
    KeyNotFound = Class.new(StandardError)
    
    def initialize(opts = {})
      @max_keys = (opts[:max_keys] || DEFAULT_MAX_KEYS)
      @cache_name = (opts[:cache_name] || DEFAULT_CACHE_NAME)
      init_redis!(opts)
      init_counters!
    end
    
    def get(key)
      retval = @redis.client.call(:zadd, cache_name, -(Time.now.to_f*1000000).to_i, key)
      prune_cache!
      
      @total_keys += 1
      if (retval == 1)
        @misses += 1 
        raise KeyNotFound 
      else
        @hits += 1
      end      
    end

    def rank_for_key( key )
      @redis.zrank(cache_name, key)
    end
    
    def num_keys
      @tot
      @redis.zcard(cache_name)
    end
    
    def percent_utilization
      self.num_keys.to_f / self.max_keys
    end
    
    def hit_rate
      hits.to_f / (hits + misses)
    end
    
    def miss_rate
      misses.to_f / (hits + misses)
    end
    
    private
    
    def init_counters!
      @misses     = 0
      @hits       = 0
      @total_keys = 0
    end
    
    def init_redis!(opts)
      ## Just use default for redis
      @redis_host = opts[:redis_host] || "localhost"
      @redis_port = opts[:redis_port] || 6379
      
      @redis = Redis.new(:host => @redis_host, :port => @redis_port)  
    end
    
    def prune_cache!
      redis.zremrangebyrank(cache_name, max_keys, 2*max_keys) if (num_keys > max_keys)
    end
  end  
end