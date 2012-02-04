Given /^I have setup database cleaner to clean multiple databases using activerecord$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/datamapper_models"
  #
  # DatabaseCleaner[:datamapper, {:connection => :one} ].strategy = :truncation
  # DatabaseCleaner[:datamapper, {:connection => :two} ].strategy = :truncation
end

When /^I create a widget using activerecord$/ do
  instance = ActiveRecordWidget.create!
  # removal strategy requires specific instances to be marked for removal.
  # this should have no effect on other strategies.
  DatabaseCleaner.mark_for_removal instance
end

Then /^I should see ([\d]+) widget using activerecord$/ do |widget_count|
  ActiveRecordWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using activerecord$/ do
  instance = ActiveRecordWidgetUsingDatabaseOne.create!
  DatabaseCleaner.mark_for_removal instance
end

When /^I create a widget in another db using activerecord$/ do
  instance = ActiveRecordWidgetUsingDatabaseTwo.create!
  DatabaseCleaner.mark_for_removal instance
end

Then /^I should see ([\d]+) widget in one db using activerecord$/ do |widget_count|
  ActiveRecordWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using activerecord$/ do |widget_count|
  ActiveRecordWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
