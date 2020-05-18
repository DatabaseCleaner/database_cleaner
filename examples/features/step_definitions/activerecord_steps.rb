Given /^I have setup database cleaner to clean multiple databases using activerecord$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/datamapper_models"
  #
  # DatabaseCleaner[:active_record, db: :one].strategy = :truncation
  # DatabaseCleaner[:active_record, db: :two].strategy = :truncation
end

When /^I create a widget using activerecord$/ do
  ActiveRecordWidget.create!
end

Then /^I should see ([\d]+) widget using activerecord$/ do |widget_count|
  expect(ActiveRecordWidget.count).to eq widget_count.to_i
end

When /^I create a widget in one db using activerecord$/ do
  ActiveRecordWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using activerecord$/ do
  ActiveRecordWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using activerecord$/ do |widget_count|
  expect(ActiveRecordWidgetUsingDatabaseOne.count).to eq widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using activerecord$/ do |widget_count|
  expect(ActiveRecordWidgetUsingDatabaseTwo.count).to eq widget_count.to_i
end
