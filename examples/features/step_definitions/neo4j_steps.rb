When /^I create a widget using neo4j$/ do
  Neo4jWidget.create!
end

Then /^I should see ([\d]+) widget using neo4j$/ do |widget_count|
  Neo4jWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using neo4j$/ do
  Neo4jWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using neo4j$/ do
  Neo4jWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using neo4j$/ do |widget_count|
  Neo4jWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using neo4j$/ do |widget_count|
  Neo4jWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
