# WORK IN PROGRESS - PLEASE DO NOT FOLLOW THESE INSTRUCTIONS UNTIL v2.0.0 FINAL IS RELEASED!

## How to add a new adapter

_Note the following tutorial is for database_cleaner version 2 and above_

Every adapter is a separate gem. So a creation of an adapter will follow the general rules of a gem making

### Naming
A convention for naming a gem extesions is with [dash](use-dashes-for-extensions).
For example, `database_cleaner-redis` or `database_cleaner-neo4j`

### Bootstrapping a gem
We will use `bundle` to bootstrap a gem. This will produce all the initial files needed for a gem creation

```
bundle gem database_cleaner-adapter
```
#### Modifying .gempspec
You need to add a couple of dependecies to `.gempspec`:
* `database_cleaner-core`
* Adapter you're creating this gem for

```
  spec.add_dependency "database_cleaner-core", "2.0.0"
  spec.add_dependency "adapter", "some version if required"
```

#### 

### File structure

Inside `lib/database_cleaner/adapter`. You will need to create a few files

* `base.rb`
* Separate files for each strategy you have

The file structure you end up with look something like this

```
\-lib
  \-database_cleaner
    \- adapter
      \- base.rb
      \- truncation.rb
      \- deletion.rb
      \- transaction.rb
      \- version.rb
    \- adapter.rb
```

#### base.rb

File `base.rb` **must** have following methods
  * class methods `.default_strategy` and `.available_strategies`
  * instance methods `#db=`, `#db`, `#cleaning`

`DatabaseCleaner::Generic::Base` will add some of those don't forget to include it.

So, in the end you may end up with the class that will look something like this

```ruby
require 'database_cleaner/generic/base'
module DatabaseCleaner
  module Adapter
    def self.available_strategies
      %w[transaction truncation deletion]
    end

    def self.default_strategy
      :truncation
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db
      end

      def db
        @db || :default
      end
    end
  end
end
```

### Strategy classes

Each strategy **must** have the following instance methods
  *  `#clean` -- where the cleaning happens
  *  `#start` -- added for compatability reasons, do nothing if you don't need to. This method might be included with `::DatabaseCleaner::Generic::Truncation` or `::DatabaseCleaner::Generic::Transaction`

Given that we a creating a strategy for truncation. You may end up with the following class

```ruby
module DatabaseCleaner
  module Adatper
    class Truncation
      include ::DatabaseCleaner::Adatper::Base
      include ::DatabaseCleaner::Generic::Truncation

      def clean
      end
    end
  end
end
```

Thats about it for the code needed to have your own adapter

### Testing

To make sure that custom adapter adheres to the Database Cleaner API database_cleaner provides an rspec shared example.

You need to create a file `database_cleaner/adapter/base.rb`

With the following content

```ruby
require 'database_cleaner/adapter'
require 'database_cleaner/spec'

module DatabaseCleaner
  RSpec.describe Adapter do
    it_should_behave_like "a database_cleaner strategy"
  end
end
```

### What's next
Now you should be well set up to create you own database_cleaner adatper.
Also don't forget to take a look at the already created adapters if you encounter any problems.

When you are done with the your adapter, only a few things left to do
  * Create a repository with your code
  * Push code to rubygems
  * Add your adapter to the [list](https://github.com/DatabaseCleaner/database_cleaner#list-of-adapters)


