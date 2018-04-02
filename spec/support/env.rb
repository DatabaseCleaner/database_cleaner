module Support
  module Env
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def env(vars)
        before { define_env(vars) }
        after  { undefine_env(vars) }
      end
    end

    def define_env(vars)
      vars.each { |key, value| ENV[key.to_s.upcase] = value.to_s }
    end

    def undefine_env(vars)
      vars.each { |key, _| ENV.delete(key.to_s) }
    end
  end
end
