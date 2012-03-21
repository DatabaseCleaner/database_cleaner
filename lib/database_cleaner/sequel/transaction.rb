require 'database_cleaner/sequel/base'
module DatabaseCleaner
  module Sequel
    class Transaction
      include ::DatabaseCleaner::Sequel::Base

      def start
        @fibers||= []
        db= self.db
        f= Fiber.new do
          db.transaction(:rollback => :always, :savepoint => true) do
            Fiber.yield
          end
        end
        f.resume
        @fibers<< f
      end

      def clean
        f= @fibers.pop
        f.resume
      end
    end
  end
end
