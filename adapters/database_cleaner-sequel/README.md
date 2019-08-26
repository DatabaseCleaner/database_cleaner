# Database Cleaner Adapter for Sequel

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-sequel.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-sequel)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-sequel/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-sequel)

Clean your Sequel databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-sequel'
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

## Configuration options

<table>
  <tbody>
    <tr>
      <th>ORM</th>
      <th>How to access</th>
      <th>Notes</th>
    </tr>
    <tr>
      <td> Sequel</td>
      <td> <code>DatabaseCleaner[:sequel]</code></td>
      <td> Multiple databases supported; specify <code>DatabaseCleaner[:sequel, {:connection =&gt; Sequel.connect(uri)}]</code></td>
    </tr>
  </tbody>
</table>

## Common Errors

### Nothing happens in JRuby with Sequel using transactions

Due to an inconsistency in JRuby's implementation of Fibers, Sequel gives a different connection to `DatabaseCleaner.start` than is used for tests run between `.start` and `.clean`. This can be worked around by running your tests in a block like `DatabaseCleaner.cleaning { run_my_tests }` instead, which does not use Fibers.

## COPYRIGHT

See [LICENSE] for details.
