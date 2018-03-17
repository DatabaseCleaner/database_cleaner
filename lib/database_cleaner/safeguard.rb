module DatabaseCleaner
  DatabaseUrlSpecified = Class.new(Exception)

  class Safeguard
    def run
      return if skip?
      raise DatabaseUrlSpecified if env_db_url?
    end

    private

      def env_db_url?
        url = ENV['DATABASE_URL']
        url && !url.include?('localhost')
      end

      def skip?
        !!ENV['DATABASE_CLEANER_SKIP_SAFEGUARD']
      end
  end
end
