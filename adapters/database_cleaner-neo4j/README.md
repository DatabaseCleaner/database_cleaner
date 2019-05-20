# DatabaseCleaner::Neo4j

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/database_cleaner/neo4j`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'database_cleaner-neo4j'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install database_cleaner-neo4j

## Usage

Truncation and Deletion strategies for Neo4j will just delete all nodes and relationships from the database.

### Configuration options

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

## Common Errors

### Model fails to load with Neo4j using transactions

When you are using [neo4j](https://github.com/neo4jrb/neo4j) gem it creates schema and reads indexes upon loading models. These operations can't be done during a transaction. You have to preload your models before DatabaseCleaner starts a transaction.

Add to your rails_helper or spec_helper after requiring database_cleaner:

```ruby
require 'database_cleaner-neo4j'
Dir["#{Rails.root}/app/models/**/*.rb"].each do |model|
  load model
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/database_cleaner-neo4j.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
