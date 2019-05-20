# Database Cleaner Adapter for DataMapper

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-data_mapper.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-data_mapper)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-data_mapper/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-data_mapper)

Clean your DataMapper databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-data_mapper'
end
```

## Configuration options

<table>
  <tbody>
    <tr>
      <th>ORM</th>
      <th>How to access</th>
      <th>Notes</th>
    </tr>
    <tr>
      <td> Data Mapper</td>
      <td> <code>DatabaseCleaner[:data_mapper]</code></td>
      <td> Connection specified as <code>:symbol</code> keys, loaded via Datamapper repositories </td>
    </tr>
  </tbody>
</table>

## COPYRIGHT

See [LICENSE] for details.
