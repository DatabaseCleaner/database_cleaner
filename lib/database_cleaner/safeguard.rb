module DatabaseCleaner
  class Safeguard
    class Error < Exception
      class RemoteDatabaseUrl < Error
        def initialize
          super("ENV['DATABASE_URL'] is set to a remote URL. Please refer to https://github.com/DatabaseCleaner/database_cleaner#safeguards")
        end
      end

      class ProductionEnv < Error
        def initialize(env)
          super("ENV['#{env}'] is set to production. Please refer to https://github.com/DatabaseCleaner/database_cleaner#safeguards")
        end
      end
    end

    class RemoteDatabaseUrl
      LOCAL = %w(localhost 127.0.0.1)

      def run
        raise Error::RemoteDatabaseUrl if !skip? && given?
      end

      private

        def given?
          remote?(ENV['DATABASE_URL'])
        end

        def remote?(url)
          url && !LOCAL.any? { |str| url.include?(str) }
        end

        def skip?
          ENV['DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL'] ||
            DatabaseCleaner.allow_remote_database_url
        end
    end

    class Production
      KEYS = %w(ENV RACK_ENV RAILS_ENV)

      def run
        raise Error::ProductionEnv.new(key) if !skip? && given?
      end

      private

        def given?
          !!key
        end

        def key
          @key ||= KEYS.detect { |key| ENV[key] == 'production' }
        end

        def skip?
          ENV['DATABASE_CLEANER_ALLOW_PRODUCTION'] ||
            DatabaseCleaner.allow_production
        end
    end

    CHECKS = [
      RemoteDatabaseUrl,
      Production
    ]

    def run
      CHECKS.each { |const| const.new.run }
    end
  end
end
