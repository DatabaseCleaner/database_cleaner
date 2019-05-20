# Database Cleaner Adapter for Moped

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-moped.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-moped)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-moped/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-moped)

Clean your Moped databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-moped'
end
```

## Supported Strategies

<table>
  <tbody>
    <tr>
      <th>Truncation</th>
      <th>Transaction</th>
      <th>Deletion</th>
    </tr>
    <tr>
      <td> <b>Yes</b></td>
      <td> No</td>
      <td> No</td>
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
      <td> Moped</td>
      <td> <code>DatabaseCleaner[:moped]</code></td>
      <td> It is necessary to configure database name with <code>DatabaseCleaner[:moped].db = db_name</code> otherwise name `default` will be used.</td>
    </tr>
  </tbody>
</table>

## COPYRIGHT

See [LICENSE] for details.
