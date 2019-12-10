# Database Cleaner Adapter for Ohm

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-ohm.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-ohm)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-ohm/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-ohm)

Clean your Ohm databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-ohm'
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

`:only` and `:except` take a list of strings to be passed to [`keys`](https://redis.io/commands/keys)).

<table>
  <tbody>
    <tr>
      <th>ORM</th>
      <th>How to access</th>
      <th>Notes</th>
    </tr>
    <tr>
      <td>Ohm</td>
      <td><code>DatabaseCleaner[:ohm]</code></td>
      <td>Connection specified as Redis URI</td>
    </tr>
  </tbody>
</table>

## COPYRIGHT

See [LICENSE] for details.
