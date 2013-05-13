Given /^I have setup database cleaner to clean multiple databases using redis$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/redis_models"
  #
  # DatabaseCleaner[:redis, {:connection => ENV['REDIS_URL_ONE']} ].strategy = :truncation
  # DatabaseCleaner[:redis, {:connection => ENV['REDIS_URL_TWO']} ].strategy = :truncation
end

When /^I create a widget using redis$/ do
  RedisWidget.create!
end

Then /^I should see ([\d]+) widget using redis$/ do |widget_count|
  RedisWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using redis$/ do
  RedisWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using redis$/ do
  RedisWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using redis$/ do |widget_count|
  RedisWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using redis$/ do |widget_count|
  RedisWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
