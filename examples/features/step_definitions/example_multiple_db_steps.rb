When /^I create a widget in one db$/ do
  Widget.create!
end

When /^I create a widget in another db$/ do
  TwinWidget.create!
end

Then /^I should see ([\d]+) widget in one db $/ do |widget_count|
  Widget.count.should == widget_count
end

Then /^I should see ([\d]+) widget in another db$/ do |widget_count|
  TwinWidget.count.should == widget_count
end