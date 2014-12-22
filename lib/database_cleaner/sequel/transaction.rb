require 'database_cleaner/sequel/base'
module DatabaseCleaner
  module Sequel
    class Transaction
      include ::DatabaseCleaner::Sequel::Base

      def self.check_fiber_brokenness
        if !@checked_fiber_brokenness && Fiber.new { Thread.current }.resume != Thread.current
          raise RuntimeError, "This ruby engine's Fibers are not compatible with Sequel's connection pool. " +
            "To work around this, please use DatabaseCleaner.cleaning with a block instead of " +
            "DatabaseCleaner.start and DatabaseCleaner.clean"
        end
        @checked_fiber_brokenness = true
      end

      def start
        self.class.check_fiber_brokenness

        @fibers ||= []
        db = self.db
        f = Fiber.new do
          db.transaction(:rollback => :always, :savepoint => true) do
            Fiber.yield
          end
        end
        f.resume
        @fibers << f
      end

      def clean
        f = @fibers.pop
        f.resume
      end

      def cleaning
        self.db.transaction(:rollback => :always, :savepoint => true) { yield }
      end
    end
  end
end
