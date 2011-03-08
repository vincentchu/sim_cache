# SimCache - A tool for investigating cache performance given observed log data

Modern web applications depend heavily on caching strategies to reduce load on primary databases and to boost performance of slow-running or heavily-utilized features or queries. 

When evaluating different caching strategies (e.g., Memcache vs. Redis vs. something else), it is often important to understand the expected load that the cache will be expected to bear. During this planning, several key questions must often be answered:

 * What read and write throughput must the cache sustain? 
 * How large should our cache be to deliver a given level of performance? 
 * How will cache performance degrade with increased traffic? 
 * How long does it take to saturate the cache? 
 * What will be the steady-state performance of our cache?
 
Answering such questions may help inform decisions about which caching strategy is appropriate, and how costly such a strategy would be. 

## Why SimCache? 

SimCache is a simple tool replays a log file against an idealized LRU cache of a fixed size (specified by the user). Using this log data, SimCache will create a timeseries report with the following metrics:

  1. Requests / second 
  2. Cache Hits / second
  3. Cache Misses / second
  4. Hit Percentage
  5. Total keys stored in cache
  6. Percentage of cache used
  7. Aggregate percentage of hits

# Usage

SimCache consists of two parts: a simulated LRU cache with a user-specified size, and a replay script that plays a log file against the idealized cache. 

Please note that most LRU caches (e.g., Memcache) do not behave as a perfect LRU cache. Therefore, the results obtained from SimCache will not perfectly match reality perfectly. However, the results are accurate enough to provide key characteristics about cache performance. 

## The Log File

The log file must be in the following format. The bracketed time stamp designates when an object was accessed; the second column is any string that uniquely identifies the object requested from the cache. For an example, see `spec/fixtures/test.log` (excerpted here): 

      [Feb 28 01:34:31] post_44164631_js
    [Feb 28 01:34:59] post_44164631_js
    [Feb 28 01:52:36] post_11080788_html
    [Feb 28 02:09:28] post_44427139_html
    [Feb 28 02:26:08] post_19142226_js
    [Feb 28 02:45:01] post_29425455_js
    [Feb 28 03:01:27] post_20254178_js
    [Feb 28 03:20:21] post_44359317_js

## Replaying Log Files

To start a replay, simply do the following: 

    require 'sim_cache'
    SimCache::LogReplayer.new(
      :log_file => "/path/to/logfile.log",
      :report_file => "/path/to/report.log,
      :cache_options => {:max_keys => 6_000_000}
    ).replay!

## Report Output

The report that is generated is in the following format (excerpted from `spec/fixtures/sample_out.log`): 

    [        Time]   Unix Time           req/s         hits/s     misses/sec  % hit -  TotKeys %Cache  %Hits
    --------------------------------------------------------------------------------------------------------
    [ 02-28 01:34]  1298885640          0.0333         0.0167         0.0167   0.50 - 1.00e+00  10.00   0.00
    [ 02-28 01:52]  1298886720          0.0167         0.0000         0.0167   0.00 - 2.00e+00  20.00  33.33
    [ 02-28 02:09]  1298887740          0.0167         0.0000         0.0167   0.00 - 3.00e+00  30.00  25.00
    [ 02-28 02:26]  1298888760          0.0167         0.0000         0.0167   0.00 - 4.00e+00  40.00  20.00
    [ 02-28 02:45]  1298889900          0.0167         0.0000         0.0167   0.00 - 5.00e+00  50.00  16.67

## Plotting Results

Gnuplot may be used to plot the data in the report file immediately. As an example, the following Gnuplot command will plot the miss percentage for four different sizes of cache:

    plot 'log_0' u 4:(100*($7/$5)) w l, 'log_1' u 4:(100*($7/$5)) w l, 'log_2' u 4:(100*($7/$5)) w l, 'log_3' u 4:(100*($7/$5)) w l

Graph of results: 

![Cache Miss Percentage](spec/fixtures/miss_percentage.png)

Similarly, the following: 

    plot 'log_0' u 4:($11) w l, 'log_1' u 4:($11) w l, 'log_2' u 4:($11) w l, 'log_3' u 4:($11) w l
    
will plot the cache utilization percentage over time: 

![Cache Utilization](spec/fixtures/cache_util.png)

# Requirements

SimCache uses Redis as a backing store and uses the redis gem (v2.0.5). So you'll have to install that. 
    
# Speed

Informally, SimCache is pretty fast. On my 2.4 GHz Macbook Pro with 8 GB RAM I was able to replay ~1 million log entries in just over 4 minutes while doing normal activities (e.g., browsing the web, watching YouTube). Your mileage may vary. If you have a large sample of data (e.g., tens of millions of rows or more), it might be best to take a subsample.

However, be careful how you choose the subsample; instead of randomly selecting log entries, it's probably better to take *all* log entries for a given sample of keys. Doing so will ensure that the hit / miss rates are representative of the entire sample.   

# Contact

SimCache was created by Vincent Chu (vince [at] posterous.com) and is used at Posterous. 