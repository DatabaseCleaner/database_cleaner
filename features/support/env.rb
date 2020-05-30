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
    @strategy ||= "default"
  end

  def go(feature)
    command = ""
    command << "ORM=#{orm} " if orm
    command << "STRATEGY=#{strategy} " if strategy
    command << "ANOTHER_ORM=#{another_orm} " if another_orm
    command << "MULTIPLE_DBS=#{true} " if multiple_databases
    command << "cucumber --strict examples/features/#{feature}.feature --require examples/features/support --require examples/features/step_definitions"
    # puts command

    self.output = `#{command}`

    self.exit_status = $?.exitstatus
  end
end
