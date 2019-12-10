# Database Cleaner Adapter for ActiveRecord

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-active_record.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-active_record)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-active_record/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-active_record)

Clean your ActiveRecord databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-active_record'
end
```

## Supported Strategies

Here is an overview of the supported strategies:

<table>
  <tbody>
    <tr>
      <th>Truncation</th>
      <th>Transaction</th>
      <th>Deletion</th>
    </tr>
    <tr>
      <td> Yes</td>
      <td> <b>Yes</b></td>
      <td> Yes</td>
    </tr>
  </tbody>
</table>

(Default strategy is denoted in bold)

For support or to discuss development please use the [Google Group](https://groups.google.com/group/database_cleaner).

## What strategy is fastest?

For the SQL libraries the fastest option will be to use `:transaction` as transactions are simply rolled back. If you can use this strategy you should. However, if you wind up needing to use multiple database connections in your tests (i.e. your tests run in a different process than your application) then using this strategy becomes a bit more difficult. You can get around the problem a number of ways.

One common approach is to force all processes to use the same database connection ([common ActiveRecord hack](http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite/)) however this approach has been reported to result in non-deterministic failures.

Another approach is to have the transactions rolled back in the application's process and relax the isolation level of the database (so the tests can read the uncommitted transactions).

An easier, but slower, solution is to use the `:truncation` or `:deletion` strategy.

So what is fastest out of `:deletion` and `:truncation`? Well, it depends on your table structure and what percentage of tables you populate in an average test. The reasoning is out of the scope of this README but here is a [good SO answer on this topic for Postgres](https://stackoverflow.com/questions/11419536/postgresql-truncation-speed/11423886#11423886).

Some people report much faster speeds with `:deletion` while others say `:truncation` is faster for them. The best approach therefore is it try all options on your test suite and see what is faster.

If you are using ActiveRecord then take a look at the [additional options](#additional-activerecord-options-for-truncation) available for `:truncation`.

## Configuration options

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
  </tbody>
</table>

### Additional ActiveRecord options for Truncation

The following options are available for ActiveRecord's `:truncation` strategy _only_ for MySQL and Postgres.

* `:pre_count` - When set to `true` this will check each table for existing rows before truncating it.  This can speed up test suites when many of the tables to be truncated are never populated. Defaults to `:false`. (Also, see the section on [What strategy is fastest?](#what-strategy-is-fastest))
* `:reset_ids` - This only matters when `:pre_count` is used, and it will make sure that a tables auto-incrementing id is reset even if there are no rows in the table (e.g. records were created in the test but also removed before DatabaseCleaner gets to it). Defaults to `true`.

The following option is available for ActiveRecord's `:truncation` and `:deletion` strategy for any DB.

* `:cache_tables` - When set to `true` the list of tables to truncate or delete from will only be read from the DB once, otherwise it will be read before each cleanup run. Set this to `false` if (1) you create and drop tables in your tests, or (2) you change Postgres schemas (`ActiveRecord::Base.connection.schema_search_path`) in your tests (for example, in a multitenancy setup with each tenant in a different Postgres schema). Defaults to `true`.


## Common Errors

### STDERR is being flooded when using Postgres

If you are using Postgres and have foreign key constraints, the truncation strategy will cause a lot of extra noise to appear on STDERR (in the form of "NOTICE truncate cascades" messages).

To silence these warnings set the following log level in your `postgresql.conf` file:

```ruby
client_min_messages = warning
```

For ActiveRecord, you add the following parameter in your database.yml file:

<pre>
test:
  adapter: postgresql
  # ...
  min_messages: WARNING  
</pre>

## COPYRIGHT

See [LICENSE] for details.
