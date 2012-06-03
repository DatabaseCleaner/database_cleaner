module DatabaseCleaner
  module Moped
    module Truncation

      def clean
        if @only
          collections.each { |c| session[c].drop if @only.include?(c.name) }
        else
          collections.each { |c| session[c].drop unless @tables_to_exclude.include?(c) }
        end
        true
      end

      private

      def collections
        session['system.namespaces'].find(:name => { '$not' => /system|\$/ }).to_a.map do |collection|
          _, name = collection['name'].split('.', 2)
          name
        end
      end

    end
  end
end
