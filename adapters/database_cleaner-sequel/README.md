# DatabaseCleaner::Sequel

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/database_cleaner/sequel`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'database_cleaner-sequel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install database_cleaner-sequel

## Usage

### Configuration options

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/database_cleaner-sequel.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
