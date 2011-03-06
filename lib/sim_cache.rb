require 'rubygems'
require 'redis'
require 'time'

%w(mock_cache replay_statistics_methods log_replayer).each {|f| require File.join(File.dirname(__FILE__), "sim_cache", f)}
