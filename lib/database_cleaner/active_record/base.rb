require 'database_cleaner/generic/base'
require 'active_record'
require 'erb'

module DatabaseCleaner
  module ActiveRecord

    def self.available_strategies
      %w[truncation transaction deletion]
    end
    
    def self.config_file_location=(path)
      @config_file_location = path
    end

    def self.config_file_location
      @config_file_location ||= "#{DatabaseCleaner.app_root}/config/database.yml"
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      attr_accessor :connection_hash

      def db=(desired_db)
        @db = desired_db
        load_config
      end

      def db
        @db || super
      end

      def load_config
        if File.file?(ActiveRecord.config_file_location)
          connection_details   = YAML::load(db_config_file)
          self.connection_hash = connection_details[self.db.to_s]
        end
      end

      def db_config_file
        ERB.new(IO.read(db_config_file_path)).result
      end

      def db_config_file_path
        DatabaseCleaner::ActiveRecord.config_file_location || ActiveRecord.config_file_location
      end

      def create_connection_klass
        Class.new(::ActiveRecord::Base)
      end

      def connection_klass
        return ::ActiveRecord::Base if connection_hash.nil?
        klass = create_connection_klass
        klass.send :establish_connection, connection_hash
        klass
      end

      def connection
        connection_klass.connection
      end
    end
  end
end
