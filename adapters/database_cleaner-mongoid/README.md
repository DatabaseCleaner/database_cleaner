# Database Cleaner Adapter for Mongoid

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-mongoid.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-mongoid)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-mongoid/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-mongoid)

Clean your Mongoid databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-mongoid'
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
      <td> Mongoid</td>
      <td> <code>DatabaseCleaner[:mongoid]</code></td>
      <td> Multiple databases supported for Mongoid 3. Specify <code>DatabaseCleaner[:mongoid, {:connection =&gt; :db_name}]</code> </td>
    </tr>
  </tbody>
</table>

## COPYRIGHT

See [LICENSE] for details.
