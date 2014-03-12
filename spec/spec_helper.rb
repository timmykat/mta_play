require 'data_mapper'
require_relative '../config'
require_relative '../mta_models'
require_relative '../db_init'

TRANSPORT_OPTS              = %w(bus subway commuter_rail)
TRANSPORT_OPTS_WITH_SPECIAL = TRANSPORT_OPTS + ['special_bus']
RIDER_OPTS                  = %w(regular student elderly employee)

# Redirect stdout to /dev/null.
def silence_output
  # @orig_stderr = $stderr
  @orig_stdout = $stdout
 
  # redirect stderr and stdout to /dev/null
  # $stderr = File.new('/dev/null', 'w')
  $stdout = File.new('/dev/null', 'w')
end
 
# Replace stdout and stderr so anything else is output correctly.
def enable_output
  # $stderr = @orig_stderr
  $stdout = @orig_stdout
  # @orig_stderr = nil
  @orig_stdout = nil
end




