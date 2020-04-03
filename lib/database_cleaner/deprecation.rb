module DatabaseCleaner
  def deprecate message
    method = caller.first[/\d+:in `(.*)'$/, 1].to_sym
    @@deprecator ||= Deprecator.new
    @@deprecator.deprecate method, message
  end
  module_function :deprecate

  def called_externally?(file, caller)
    file != caller.first[/^(.+\.rb):\d+/, 1]
  end
  module_function :called_externally?

  class Deprecator
    def initialize
      @methods_already_warned = {}
    end

    def deprecate method, message
      return if @methods_already_warned.key?(method)
      $stderr.puts message
      @methods_already_warned[method] = true
    end
  end
end

