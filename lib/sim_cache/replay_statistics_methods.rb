module SimCache
  module ReplayStatisticsMethods
    
    def increment_minute_counters(log_item)
      index = round_time(log_item[:time]).to_i

      unless @minute_counter[index]
        @minute_counter[index] = {:hits => 0, :misses => 0, :cache_total_keys => 0, :cache_utilization => 0, :cache_hit_rate => 0}
        @minute_counter[index][:cache_total_keys]  = @mock_cache.num_keys
        @minute_counter[index][:cache_utilization] = @mock_cache.percent_utilization
        @minute_counter[index][:cache_hit_rate]    = @mock_cache.hit_rate
      end

      if log_item[:cache_hit]
        @minute_counter[index][:hits] += 1
      else
        @minute_counter[index][:misses] += 1
      end      
    end

    def round_time(time)
      Time.at(time.to_i - time.to_i%60)
    end

    def misses_per_second(index)
      @minute_counter[index][:misses].to_f / 60
    end
    
    def hits_per_second(index)
      @minute_counter[index][:hits].to_f / 60
    end
    
    def requests_per_second(index)
      misses_per_second(index) + hits_per_second(index)
    end    
    
    def total_requests(index)
      @minute_counter[index][:hits] + @minute_counter[index][:misses]
    end    
    
    def hit_percentage(index)
      @minute_counter[index][:hits].to_f / total_requests(index)
    end
    
    def miss_percentage(index)
      @minute_counter[ndex][:misses].to_f / total_requests(index)
    end
    
    def total_keys_stored(index)
      @minute_counter[index][:cache_total_keys]
    end
    
    def total_cache_utilization(index)
      @minute_counter[index][:cache_utilization]
    end
    
    def total_cache_hit_rate(index)
      @minute_counter[index][:cache_hit_rate]  
    end
    
    def reset_minute_counters!
      @minute_counter = {}
    end
  end  
end