# Database Cleaner Adapter for Neo4j

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-neo4j.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-neo4j)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-neo4j/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-neo4j)

Clean your Neo4j databases with Database Cleaner.

See https://github.com/DatabaseCleaner/database_cleaner for more information.

## Installation

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-neo4j'
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
      <td>Neo4j</td>
      <td><code>DatabaseCleaner[:neo4j]</code></td>
      <td>Database type and path(URI) <code>DatabaseCleaner[:neo4j, connection: {type: :server_db, path: 'http://localhost:7475'}].</code></td>
    </tr>
  </tbody>
</table>

Note that Truncation and Deletion strategies for Neo4j will just delete all nodes and relationships from the database.

## Common Errors

### Model fails to load with Neo4j using transactions

When you are using [neo4j](https://github.com/neo4jrb/neo4j) gem it creates schema and reads indexes upon loading models. These operations can't be done during a transaction. You have to preload your models before DatabaseCleaner starts a transaction.

Add to your rails_helper or spec_helper after requiring database_cleaner-neo4j:

```ruby
require 'database_cleaner/neo4j'

Dir["#{Rails.root}/app/models/**/*.rb"].each do |model|
  load model
end
```

## COPYRIGHT

See [LICENSE] for details.
