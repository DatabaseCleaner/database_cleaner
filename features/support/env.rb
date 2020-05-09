require 'rspec/expectations'

if ENV['COVERAGE'] == 'true'
  require "simplecov"

  if ENV['CI'] == 'true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
    puts "required codecov"
  end

  SimpleCov.start
  puts "required simplecov"
end

class FeatureRunner
  attr_accessor :orm
  attr_accessor :another_orm
  attr_accessor :multiple_databases
  attr_accessor :strategy
  attr_accessor :exit_status
  attr_accessor :output

  def strategy
    @strategy || 'truncation'
  end

  def go(feature)
    ENV['ORM']          = orm
    ENV['STRATEGY']     = strategy

    if another_orm
     ENV['ANOTHER_ORM']  = another_orm
    else
      ENV['ANOTHER_ORM'] = nil
    end

    if multiple_databases
      ENV['MULTIPLE_DBS'] = "true"
    else
      ENV['MULTIPLE_DBS'] = nil
    end

    self.output = `cucumber --strict examples/features/#{feature}.feature --require examples/features/support --require examples/features/step_definitions`

    self.exit_status = $?.exitstatus
  end
end
