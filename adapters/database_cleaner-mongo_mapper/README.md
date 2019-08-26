# Database Cleaner Adapter for MongoMapper

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-mongo_mapper.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-mongo_mapper)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-mongo_mapper/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-mongo_mapper)

Clean your MongoMapper databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-mongo_mapper'
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
      <td> Mongo Mapper</td>
      <td> <code>DatabaseCleaner[:mongo_mapper]</code></td>
      <td> Multiple connections not yet supported</td>
    </tr>
  </tbody>
</table>

## COPYRIGHT

See [LICENSE] for details.
