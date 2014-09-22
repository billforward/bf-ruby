#require 'bill_forward/version'

require "rest-client"
require "json"
# used for things like 'blank?' and 'indifferent hashes'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/ordered_hash'
require 'active_support/core_ext/string'
# requirer that negotiates dependency order, relative pathing
require 'require_all'

# require all ruby files in relative directory 'bill_forward' and all its subdirectories
require_rel "bill_forward"