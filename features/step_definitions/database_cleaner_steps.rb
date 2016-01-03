orms_pattern = /(ActiveRecord|DataMapper|Sequel|MongoMapper|Mongoid|CouchPotato|Redis|Ohm|Neo4j)/

Given /^All database servers are running locally$/ do
  # port forwarding from docker host to localhost
  system 'socat -lf /dev/null TCP-LISTEN:6379,reuseaddr,fork,su=nobody TCP:redis.local:6379 &> /dev/null &'
  system 'socat -lf /dev/null TCP-LISTEN:27017,reuseaddr,fork,su=nobody TCP:mongodb.local:27017 &> /dev/null &'
  system 'socat -lf /dev/null TCP-LISTEN:5432,reuseaddr,fork,su=nobody TCP:postgres.local:5432 &> /dev/null &'
  system 'socat -lf /dev/null TCP-LISTEN:3306,reuseaddr,fork,su=nobody TCP:mysql.local:3306 &> /dev/null &'
end

Given /^I am using #{orms_pattern}$/ do |orm|
  @feature_runner = FeatureRunner.new
  @feature_runner.orm = orm
end

Given /^I am using #{orms_pattern} and #{orms_pattern}$/ do |orm1,orm2|
  @feature_runner = FeatureRunner.new
  @feature_runner.orm         = orm1
  @feature_runner.another_orm = orm2
end

Given /^the (.+) cleaning strategy$/ do |strategy|
  @feature_runner.strategy = strategy
end

When "I run my scenarios that rely on a clean database" do
  @feature_runner.go 'example'
end

When "I run my scenarios that rely on clean databases" do
  @feature_runner.multiple_databases = true
  @feature_runner.go 'example_multiple_db'
end

When "I run my scenarios that rely on clean databases using multiple orms" do
  @feature_runner.go 'example_multiple_orm'
end

Then "I should see all green" do
  fail "Feature failed with :#{@feature_runner.output}" unless @feature_runner.exit_status == 0
end
