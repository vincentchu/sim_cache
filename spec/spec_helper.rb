$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sim_cache'

def test_log
  File.join(File.dirname(__FILE__), "fixtures/test.log")  
end

def report_log
  File.join(File.dirname(__FILE__), "fixtures/sample_out.log")
end

# awk '{print $1, $2, $3, "p_"$16"_"$10}' test_log | awk -F: '{print $2":"$3":"$4}' | awk '{print "["$1, $2, $3"]", $4}'