Given /^I have setup database cleaner to clean multiple databases using ohm$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/ohm_models"
  #
  # DatabaseCleaner[:ohm, {:connection => ENV['REDIS_URL_ONE']} ].strategy = :truncation
  # DatabaseCleaner[:ohm, {:connection => ENV['REDIS_URL_TWO']} ].strategy = :truncation
end

When /^I create a widget using ohm$/ do
  OhmWidget.create!
end

Then /^I should see ([\d]+) widget using ohm$/ do |widget_count|
  expect(OhmWidget.count).to eq widget_count.to_i
end

When /^I create a widget in one db using ohm$/ do
  OhmWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using ohm$/ do
  OhmWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using ohm$/ do |widget_count|
  expect(OhmWidgetUsingDatabaseOne.count).to eq widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using ohm$/ do |widget_count|
  expect(OhmWidgetUsingDatabaseTwo.count).to eq widget_count.to_i
end
