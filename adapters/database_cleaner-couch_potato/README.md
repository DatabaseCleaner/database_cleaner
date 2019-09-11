# Database Cleaner Adapter for CouchPotato

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-couch_potato.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-couch_potato)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-couch_potato/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-couch_potato)

Clean your CouchPotato databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-couch_potato'
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
      <td> Couch Potato</td>
      <td> <code>DatabaseCleaner[:couch_potato]</code></td>
      <td> Multiple connections not yet supported</td>
    </tr>
  </tbody>
</table>

## COPYRIGHT

See [LICENSE] for details.
