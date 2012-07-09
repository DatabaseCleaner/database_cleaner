require 'spec_helper'

generic_specs = Dir[
  'spec/base_spec.rb', 
  'spec/configuration_spec.rb', 
  'spec/database_cleaner/generic/**/*_spec.rb'
]

active_record_specs = Dir[
  'spec/database_cleaner/active_record/**/*_spec.rb'
]

(generic_specs + active_record_specs).each {|s| require s}
