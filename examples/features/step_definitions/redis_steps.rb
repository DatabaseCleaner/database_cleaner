Given /^I have setup database cleaner to clean multiple databases using redis$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/redis_models"
  #
  # DatabaseCleaner[:redis, db: ENV['REDIS_URL_ONE']].strategy = :truncation
  # DatabaseCleaner[:redis, db: ENV['REDIS_URL_TWO']].strategy = :truncation
end

When /^I create a widget using redis$/ do
  RedisWidget.create!
end

Then /^I should see ([\d]+) widget using redis$/ do |widget_count|
  expect(RedisWidget.count).to eq widget_count.to_i
end

When /^I create a widget in one db using redis$/ do
  RedisWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using redis$/ do
  RedisWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using redis$/ do |widget_count|
  expect(RedisWidgetUsingDatabaseOne.count).to eq widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using redis$/ do |widget_count|
  expect(RedisWidgetUsingDatabaseTwo.count).to eq widget_count.to_i
end
