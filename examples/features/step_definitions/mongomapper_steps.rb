Given /^I have setup database cleaner to clean multiple databases using mongomapper$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/datamapper_models"
  #
  # DatabaseCleaner[:datamapper, {:connection => :one} ].strategy = :truncation
  # DatabaseCleaner[:datamapper, {:connection => :two} ].strategy = :truncation
end

When /^I create a widget using mongomapper$/ do
  MongoMapperWidget.create!
end

Then /^I should see ([\d]+) widget using mongomapper$/ do |widget_count|
  expect(MongoMapperWidget.count).to eq widget_count.to_i
end

When /^I create a widget in one db using mongomapper$/ do
  MongoMapperWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using mongomapper$/ do
  MongoMapperWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using mongomapper$/ do |widget_count|
  expect(MongoMapperWidgetUsingDatabaseOne.count).to eq widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using mongomapper$/ do |widget_count|
  expect(MongoMapperWidgetUsingDatabaseTwo.count).to eq widget_count.to_i
end
