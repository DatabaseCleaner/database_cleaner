# Guidelines for contributing

## 1. Fork & Clone

Since you probably don't have rights to the main repo, you should Fork it (big
button up top). After that, clone your fork locally and optionally add an
upstream:

    git remote add upstream git@github.com:DatabaseCleaner/database_cleaner.git

## 2. Make sure the tests run fine

- `bundle install`
- Copy `db/sample.config.yml` to `db/config.yml` and edit it
- Make sure to create the databases specified in `db/config.yml`
- Run the tests with `bundle exec rspec`

Note that if you don't have all the supported databases installed and running,
some tests will fail.

## 3. Prepare your contribution

This is all up to you but a few points should be kept in mind:

- Please write tests for your contribution
- Make sure that previous tests still pass
- Push it to a branch of your fork
- Submit a pull request
