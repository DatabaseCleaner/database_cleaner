Given /^I have setup database cleaner to clean multiple databases using datamapper$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/datamapper_models"
  #
  # DatabaseCleaner[:datamapper, {:connection => :one} ].strategy = :truncation
  # DatabaseCleaner[:datamapper, {:connection => :two} ].strategy = :truncation
end

When /^I create a widget using datamapper$/ do
  instance = DataMapperWidget.create!
  # removal strategy requires specific instances to be marked for removal.
  # this should have no effect on other strategies.
  DatabaseCleaner.mark_for_removal instance
end

Then /^I should see ([\d]+) widget using datamapper$/ do |widget_count|
  DataMapperWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using datamapper$/ do
  begin
    instance = DataMapperWidgetUsingDatabaseOne.create!
    DatabaseCleaner.mark_for_removal instance
  rescue StandardError => e
    BREAK = e.backtrace
    debugger
    DataMapperWidgetUsingDatabaseOne.create!
  end
end

When /^I create a widget in another db using datamapper$/ do
  instance = DataMapperWidgetUsingDatabaseTwo.create!
  DatabaseCleaner.mark_for_removal instance
end

Then /^I should see ([\d]+) widget in one db using datamapper$/ do |widget_count|
  DataMapperWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using datamapper$/ do |widget_count|
  DataMapperWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
