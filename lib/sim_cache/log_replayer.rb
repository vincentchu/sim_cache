module SimCache
  class LogReplayer
    
    include ReplayStatisticsMethods

    attr_reader :log_file, :report_file, :mock_cache

    def initialize(opts)      
      @log_file    = opts[:log_file]
      @report_file = opts[:report_file]
      @mock_cache  = MockCache.new( opts[:cache_options] )
    end

    def replay!
      open_files!
      replay_logs!
    ensure
      close_files!
    end

    private

    def replay_logs!
      reset_minute_counters!
      output_report_header
      
      n_lines = 0
      while(log_item = read_next_logline)
        next if log_item.nil?        
        process_log_item( log_item )
        
        puts "[#{Time.now}] Processed #{n_lines} lines" if (n_lines%10000 == 0)
        n_lines += 1         
      end
      output_report
      
      true
    end
    
    def process_log_item( log_item )
      log_item[:cache_hit] = begin
        !!@mock_cache.get( log_item[:key] )
      rescue MockCache::KeyNotFound => ex
        false
      end
      
      increment_minute_counters(log_item)
    end

    def output_report_header
      vals = [
        "Time", 
        "Unix Time",
        "req/s",
        "hits/s",
        "misses/sec",
        "% hit",
        "TotKeys",
        "%Cache",
        "%Hits"
      ]
      @report_file_handle.puts sprintf("[%12s] %11s  %14s %14s %14s %6s - %8s %6s %6s", *vals)
      @report_file_handle.puts "-" * 113
    end

    def output_report
      @minute_counter.keys.sort.each do |index|
        output_report_line(index)
      end
    end
    
    def output_report_line(index)
      
      vals = [
        Time.at(index).strftime("%m-%d %H:%M"), 
        index,
        requests_per_second(index),
        hits_per_second(index),
        misses_per_second(index),
        hit_percentage(index),
        total_keys_stored(index),
        100 * total_cache_utilization(index),
        100 * total_cache_hit_rate(index)
      ]
      
      @report_file_handle.puts sprintf("[%12s] %11d  %14.4f %14.4f %14.4f %6.2f - %8.2e %6.2f %6.2f", *vals)      
    end

    def read_next_logline
      line = begin
        @log_file_handle.readline
      rescue EOFError => ex
        nil
      end
      
      (line =~ /\[(.*?)\] (.*?)$/) ? {:time => Time.parse($1), :key => $2} : nil
    end
    
    def open_files!
      @log_file_handle = File.open(@log_file, "r")
      @report_file_handle = File.open(@report_file, "w")
    end
    
    def close_files!
      @log_file_handle.close
      @report_file_handle.close      
    end
    
  end
end