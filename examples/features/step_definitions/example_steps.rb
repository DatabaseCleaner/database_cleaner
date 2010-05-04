When /^I create a widget$/ do
  Widget.create!
end

Then /^I should see 1 widget$/ do
  Widget.count.should == 1
end

When /^I create a sneaky widget$/ do
  SneakyWidget.create!
end

Then /^I should see 1 sneaky widget$/ do
  SneakyWidget.count.should == 1
end

