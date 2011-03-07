# SimCache - A tool for investigating cache performance given observed log data

Modern websites often depend heavily on caching strategies to reduce load on their primary databases and to boost performance of slow-running or heavily-utilized portions of their site. 

When evaluating different caching strategies (Memcache vs. Redis vs. something else), it is often important to understand the expected load that the cache will be expected to bear. During this planning, several key questions must often be answered:

 * What read and write throughput is the cache required to sustain? 
 * How large should our cache be to deliver a given level of performance? 
 * How will cache performance degrade with increased traffic? 
 
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

SimCache consists of two parts: a simulated LRU cache with a size you designate, and a replay script that plays a log file against the idealized cache. 

Please not that most LRU caches (e.g., Memcache) do not behave as a perfect LRU cache. Therefore, the results you obtain from SimCache 

## The Log File

The log file must be in the following format. The bracketed time stamp designates when an object is accessed; the second column is any string that uniquely identifies the object requested from the cache. For an example, see spec/fixtures/test.log (excerpted here): 

    [Feb 28 01:34:31] post_44164631_js
    [Feb 28 01:34:59] post_44164631_js
    [Feb 28 01:52:36] post_11080788_html
    [Feb 28 02:09:28] post_44427139_html
    [Feb 28 02:26:08] post_19142226_js
    [Feb 28 02:45:01] post_29425455_js
    [Feb 28 03:01:27] post_20254178_js
    [Feb 28 03:20:21] post_44359317_js

## Writing code

To start a replay, simply do the following: 

    require 'sim_cache'
    SimCache::LogReplayer.new(
      :log_file => "/path/to/logfile.log",
      :report_file => "/path/to/report.log,
      :cache_options => {:max_keys => 6_000_000}
    ).replay!

## Report Output

The report that is generated is in the following format (excerpted from spec/fixtures/sample_out.log): 

    [        Time]   Unix Time           req/s         hits/s     misses/sec  % hit -  TotKeys %Cache  %Hits
    --------------------------------------------------------------------------------------------------------
    [ 02-28 01:34]  1298885640          0.0333         0.0167         0.0167   0.50 - 1.00e+00  10.00   0.00
    [ 02-28 01:52]  1298886720          0.0167         0.0000         0.0167   0.00 - 2.00e+00  20.00  33.33
    [ 02-28 02:09]  1298887740          0.0167         0.0000         0.0167   0.00 - 3.00e+00  30.00  25.00
    [ 02-28 02:26]  1298888760          0.0167         0.0000         0.0167   0.00 - 4.00e+00  40.00  20.00
    [ 02-28 02:45]  1298889900          0.0167         0.0000         0.0167   0.00 - 5.00e+00  50.00  16.67

## Plotting Results


# Speed

Informally, SimCache is pretty fast. On my 2.4 GHz Macbook Pro with 8 GB RAM I was able to replay ~40 million log entries in around an hour while doing normal activities (e.g., browsing the web, watching YouTube). Your mileage may vary. 

# Contact

SimCache was created by Vincent Chu (vince [at] posterous.com). 