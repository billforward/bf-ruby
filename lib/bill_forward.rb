#require 'bill_forward/version'

require "rest-client"
require "json"
# requirer that negotiates dependency order, relative pathing
require 'require_all'
# methods from Rails core that add language features like 'blank?' method
require 'active_support/core_ext/string'

# require all ruby files in relative directory 'bill_forward' and all its subdirectories
require_rel "bill_forward"