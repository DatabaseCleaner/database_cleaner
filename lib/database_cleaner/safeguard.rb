require "uri"

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

      class UrlNotAllowed < Error
        def initialize
          super("ENV['DATABASE_URL'] is set to a URL that is not on the allowlist. Please refer to https://github.com/DatabaseCleaner/database_cleaner#safeguards")
        end
      end
    end

    # Base class for core-consumers to implement Safeguards
    #
    class Base
      def run
        raise NotImplementedError
      end

      def self.inherited(subclass)
        DatabaseCleaner::Safeguard.registry << subclass
        DatabaseCleaner::Safeguard.deprecated_registry.reject! do |const|
          subclass.name.split("::").last == const.name.split("::").last
        end
      end
    end

    # Just a marker class for Safeguards implemented by core that are kept for backwards compatibility.
    # Adapters should implement their own Safeguards using Safeguard::Base.
    #
    class Deprecated; end

    class AllowedUrl < Deprecated
      def run
        return if skip?
        raise Error::UrlNotAllowed if database_url_not_allowed?
      end

      private

        def database_url_not_allowed?
          !DatabaseCleaner.url_allowlist.any? {|allowed| allowed === ENV['DATABASE_URL'] }
        end

        def skip?
          !DatabaseCleaner.url_allowlist
        end
    end

    class RemoteDatabaseUrl < Deprecated
      LOCAL = %w(localhost 127.0.0.1)

      def run
        return if skip?
        raise Error::RemoteDatabaseUrl if given?
      end

      private

        def given?
          remote?(ENV['DATABASE_URL'])
        end

        def remote?(url)
          return false unless url
          parsed = URI.parse(url)
          return false if parsed.scheme == 'sqlite' || parsed.scheme == 'sqlite3'

          host = parsed.host
          return false if host.nil? || host.empty?
          return false if LOCAL.include?(host)
          return false if host.end_with? '.local'
          true
        end

        def skip?
          ENV['DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL'] ||
            DatabaseCleaner.allow_remote_database_url ||
            DatabaseCleaner.url_allowlist
        end
    end

    class Production < Deprecated
      KEYS = %w(ENV APP_ENV RACK_ENV RAILS_ENV)

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

    def run
      self.class.registry.each { |const| const.new.run }
      self.class.deprecated_registry.each { |const| const.new.run }
    end

    @registry = []
    @deprecated_registry = [
      RemoteDatabaseUrl,
      Production,
      AllowedUrl
    ]

    class << self
      attr_reader :registry
      attr_reader :deprecated_registry

      def reset_registry!
        @registry = []
        @deprecated_registry = [
          RemoteDatabaseUrl,
          Production,
          AllowedUrl
        ]
      end
    end
  end
end
