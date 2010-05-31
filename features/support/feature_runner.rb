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
    full_dir ||= File.expand_path(File.dirname(__FILE__) + "/../../examples/")
    Dir.chdir(full_dir) do

      ENV['ORM']          = orm#.downcase
      ENV['ANOTHER_ORM']  = another_orm if another_orm#.downcase if another_orm
      ENV['MULTIPLE_DBS'] = "true" if multiple_databases
      ENV['STRATEGY']     = strategy

      self.output = `#{"jruby -S " if defined?(JRUBY_VERSION)}cucumber features/#{feature}.feature`

      self.exit_status = $?.exitstatus
    end
  end

end
