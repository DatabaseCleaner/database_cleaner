# Database Cleaner

Database Cleaner is a set of strategies for cleaning your database in Ruby.

The original use case was to ensure a clean state during tests.
Each strategy is a small amount of code but is code that is usually needed in any ruby app that is testing with a database.

ActiveRecord, DataMapper, Sequel, MongoMapper, Mongoid, CouchPotato, Ohm and Redis are supported.

[![Build Status](https://secure.travis-ci.org/bmabey/database_cleaner.png)](http://travis-ci.org/bmabey/database_cleaner)

Here is an overview of the strategies supported for each library:

<table>
  <tbody>
    <tr>
      <th>ORM</th>
      <th>Truncation</th>
      <th>Transaction</th>
      <th>Deletion</th>
    </tr>
    <tr>
      <td> ActiveRecord </td>
      <td> Yes</td>
      <td> <b>Yes</b></td>
      <td> Yes</td>
    </tr>
    <tr>
      <td> DataMapper</td>
      <td> Yes</td>
      <td> <b>Yes</b></td>
      <td> No</td>
    </tr>
    <tr>
      <td> CouchPotato</td>
      <td> <b>Yes</b></td>
      <td> No</td>
      <td> No</td>
    </tr>
    <tr>
      <td> MongoMapper</td>
      <td> <b>Yes</b></td>
      <td> No</td>
      <td> No</td>
    </tr>
    <tr>
      <td> Mongoid</td>
      <td> <b>Yes</b></td>
      <td> No</td>
      <td> No</td>
    </tr>
    <tr>
      <td> Sequel</td>
      <td> <b>Yes</b></td>
      <td> Yes</td>
      <td> No</td>
    </tr>
    <tr>
      <td>Redis</td>
      <td><b>Yes</b></td>
      <td>No</td>
      <td>No</td>
    </tr>
    <tr>
      <td>Ohm</td>
      <td><b>Yes</b></td>
      <td>No</td>
      <td>No</td>
    </tr>
  </tbody>
</table>

<table>
  <tbody>
    <tr>
      <th>Driver</th>
      <th>Truncation</th>
      <th>Transaction</th>
      <th>Deletion</th>
    </tr>
    <tr>
      <td> Mongo</td>
      <td> Yes</td>
      <td> No</td>
      <td> No</td>
    </tr>
    <tr>
      <td> Moped</td>
      <td> Yes</td>
      <td> No</td>
      <td> No</td>
    </tr>
  </tbody>
</table>

(Default strategy for each library is denoted in bold)

Database Cleaner also includes a `null` strategy (that does no cleaning at all) which can be used with any ORM library.
You can also explicitly use it by setting your strategy to `nil`.

For support or to discuss development please use the [Google Group](http://groups.google.com/group/database_cleaner).

## What strategy is fastest?

For the SQL libraries the fastest option will be to use `:transaction` as transactions are simply rolled back. If you can use this strategy you should. However, if you wind up needing to use multiple database connections in your tests (i.e. your tests run in a different process than your application) then using this strategy becomes a bit more difficult. You can get around the problem a number of ways.

One common approach is to force all processes to use the same database connection ([common ActiveRecord hack](http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite/)) however this approach has been reported to result in non-deterministic failures.

Another approach is to have the transactions rolled back in the application's process and relax the isolation level of the database (so the tests can read the uncommitted transactions).

An easier, but slower, solution is to use the `:truncation` or `:deletion` strategy.

So what is fastest out of `:deletion` and `:truncation`? Well, it depends on your table structure and what percentage of tables you populate in an average test. The reasoning is out of the scope of this README but here is a [good SO answer on this topic for Postgres](http://stackoverflow.com/questions/11419536/postgresql-truncation-speed/11423886#11423886).

Some people report much faster speeds with `:deletion` while others say `:truncation` is faster for them. The best approach therefore is it try all options on your test suite and see what is faster.

If you are using ActiveRecord then take a look at the [additional options](#additional-activerecord-options-for-truncation) available for `:truncation`.

## Dependencies

Because database_cleaner supports multiple ORMs, it doesn't make sense to include all the dependencies for each one in the gemspec. However, the DataMapper adapter does depend on dm-transactions. Therefore, if you use DataMapper, you must include dm-transactions in your Gemfile/bundle/gemset manually.

## How to use

```ruby
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

# then, whenever you need to clean the DB
DatabaseCleaner.clean
```

With the `:truncation` strategy you can also pass in options, for example:

```ruby
DatabaseCleaner.strategy = :truncation, {:only => %w[widgets dogs some_other_table]}
```

```ruby
DatabaseCleaner.strategy = :truncation, {:except => %w[widgets]}
```

With Ohm and Redis, `:only` and `:except` take a list of strings to be
passed to [`keys`](http://redis.io/commands/keys)).

(I should point out the truncation strategy will never truncate your schema_migrations table.)

Some strategies require that you call `DatabaseCleaner.start` before calling `clean` (for example the `:transaction` one needs to know to open up a transaction). So you would have:

```ruby
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction

DatabaseCleaner.start # usually this is called in setup of a test

dirty_the_db

DatabaseCleaner.clean # cleanup of the test
```

At times you may want to do a single clean with one strategy.

For example, you may want to start the process by truncating all the tables, but then use the faster transaction strategy the remaining time. To accomplish this you can say:

```ruby
require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

DatabaseCleaner.strategy = :transaction

# then make the DatabaseCleaner.start and DatabaseCleaner.clean calls appropriately
```

### Additional ActiveRecord options for Truncation

The following options are available for ActiveRecord's `:truncation` strategy _only_ for MySQL and Postgres.

* `:pre_count` - When set to `true` this will check each table for existing rows before truncating it.  This can speed up test suites when many of the tables to be truncated are never populated. Defaults to `:false`. (Also, see the section on [What strategy is fastest?](#what-strategy-is-fastest))
* `:reset_ids` - This only matters when `:pre_count` is used, and it will make sure that a tables auto-incrementing id is reset even if there are no rows in the table (e.g. records were created in the test but also removed before DatabaseCleaner gets to it). Defaults to `true`.

The following option is available for ActiveRecord's `:truncation` and `:deletion` strategy for any DB.

* `:cache_tables` - When set to `true` the list of tables to truncate or delete from will only be read from the DB once, otherwise it will be read before each cleanup run. Set this to `false` if you create and drop tables in your tests. Defaults to `true`.


### RSpec Example

```ruby
RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
```

### Minitest Example

```ruby
DatabaseCleaner.strategy = :transaction

class MiniTest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end
```

### Cucumber Example

If you're using Cucumber with Rails, just use the generator that ships with cucumber-rails, and that will create all the code you need to integrate DatabaseCleaner into your Rails project.

Otherwise, to add DatabaseCleaner to your project by hand, create a file `features/support/database_cleaner.rb` that looks like this:

```ruby
begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  DatabaseCleaner.start
end

After do |scenario|
  DatabaseCleaner.clean
end
```

This should cover the basics of tear down between scenarios and keeping your database clean.

For more examples see the section ["Why?"](#why).

## How to use with multiple ORM's

Sometimes you need to use multiple ORMs in your application.

You can use DatabaseCleaner to clean multiple ORMs, and multiple connections for those ORMs.

```ruby
#How to specify particular orms
DatabaseCleaner[:active_record].strategy = :transaction
DatabaseCleaner[:mongo_mapper].strategy = :truncation

#How to specify particular connections
DatabaseCleaner[:active_record,{:connection => :two}]

# You may also pass in the model directly:
DatabaseCleaner[:active_record,{:model => ModelWithDifferentConnection}]
```

Usage beyond that remains the same with `DatabaseCleaner.start` calling any setup on the different configured connections, and `DatabaseCleaner.clean` executing afterwards.

### Configuration options

<table>
  <tbody>
    <tr>
      <th>ORM</th>
      <th>How to access</th>
      <th>Notes</th>
    </tr>
    <tr>
      <td> Active Record </td>
      <td> <code>DatabaseCleaner[:active_record]</code></td>
      <td> Connection specified as <code>:symbol</code> keys, loaded from <code>config/database.yml</code>. You may also pass in the ActiveRecord model under the <code>:model</code> key.</td>
    </tr>
    <tr>
      <td> Data Mapper</td>
      <td> <code>DatabaseCleaner[:data_mapper]</code></td>
      <td> Connection specified as <code>:symbol</code> keys, loaded via Datamapper repositories </td>
    </tr>
    <tr>
      <td> Mongo Mapper</td>
      <td> <code>DatabaseCleaner[:mongo_mapper]</code></td>
      <td> Multiple connections not yet supported</td>
    </tr>
    <tr>
      <td> Mongoid</td>
      <td> <code>DatabaseCleaner[:mongoid]</code></td>
      <td> Multiple databases supported for Mongoid 3. Specify <code>DatabaseCleaner[:mongoid, {:connection =&gt; :db_name}]</code> </td>
    </tr>
    <tr>
      <td> Moped</td>
      <td> <code>DatabaseCleaner[:moped]</code></td>
      <td> It is necessary to configure database name with <code>DatabaseCleaner[:moped].db = db_name</code> otherwise name `default` will be used.</td>
    </tr>
    <tr>
      <td> Couch Potato</td>
      <td> <code>DatabaseCleaner[:couch_potato]</code></td>
      <td> Multiple connections not yet supported</td>
    </tr>
    <tr>
      <td> Sequel</td>
      <td> <code>DatabaseCleaner[:sequel]</code></td>
      <td> Multiple databases supported; specify <code>Databasecleaner[:sequel, {:connection =&gt; Sequel.connect(uri)}]</code></td>
    </tr>
    <tr>
      <td>Redis</td>
      <td><code>DatabaseCleaner[:redis]</code></td>
      <td>Connection specified as Redis URI</td>
    </tr>
    <tr>
      <td>Ohm</td>
      <td><code>DatabaseCleaner[:ohm]</code></td>
      <td>Connection specified as Redis URI</td>
    </tr>
  </tbody>
</table>

## Why?

One of my motivations for writing this library was to have an easy way to turn on what Rails calls "transactional_fixtures" in my non-rails ActiveRecord projects.

After copying and pasting code to do this several times I decided to package it up as a gem and save everyone a bit of time.

## Common Errors

#### DatabaseCleaner is trying to use the wrong ORM

DatabaseCleaner has an autodetect mechanism where if you do not explicitly define your ORM it will use the first ORM it can detect that is loaded.

Since ActiveRecord is the most common ORM used that is the first one checked for.

Sometimes other libraries (e.g. ActiveAdmin) will load other ORMs (e.g. ActiveRecord) even though you are using a different ORM.  This will result in DatabaseCleaner trying to use the wrong ORM (e.g. ActiveRecord) unless you explicitly define your ORM like so:

```ruby
# How to setup your ORM explicitly
DatabaseCleaner[:mongoid].strategy = :truncation
```

### STDERR is being flooded when using Postgres

If you are using Postgres and have foreign key constraints, the truncation strategy will cause a lot of extra noise to appear on STDERR (in the form of "NOTICE truncate cascades" messages). To silence these warnings set the following log level in your `postgresql.conf` file:

```ruby
client_min_messages = warning
```


## Debugging

In rare cases DatabaseCleaner will encounter errors that it will log.  By default it uses STDOUT set to the ERROR level but you can configure this to use whatever Logger you desire.

Here's an example of using the `Rails.logger` in `env.rb`:

```ruby
DatabaseCleaner.logger = Rails.logger
```


## COPYRIGHT

Copyright (c) 2009 Ben Mabey. See LICENSE for details.
