When /^I create a widget in one orm$/ do
  Widget.create!
end

When /^I create a widget in another orm$/ do
  AnotherWidget.create!
end

Then /^I should see ([\d]+) widget in one orm$/ do |widget_count|
  Widget.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another orm$/ do |widget_count|
  AnotherWidget.count.should == widget_count.to_i
end