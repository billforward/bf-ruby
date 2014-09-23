require 'rest-client'
require 'json'
# used for escaping query parameters
require 'erb'

# Rails extensions
# 'indifferent hashes' are used to enable string access to entities unserialized with symbol keys
require 'active_support/core_ext/hash/indifferent_access'
# we need ordered hashes because API requires '@type' to be first key in object
require 'active_support/ordered_hash'
# provides 'blank?' function
require 'active_support/core_ext/string'

# requirer that negotiates dependency order, relative pathing
require 'require_all'

# require all ruby files in relative directory 'bill_forward' and all its subdirectories
require_rel 'bill_forward'