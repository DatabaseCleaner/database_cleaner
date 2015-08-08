# Guidelines for contributing

## 1. Fork & Clone

Since you probably don't have rights to the main repo, you should Fork it (big
button up top). After that, clone your fork locally and optionally add an
upstream:

    git remote add upstream git@github.com:DatabaseCleaner/database_cleaner.git

## 2. Make sure the tests run fine with docker containers
- `docker-compose run --rm gem` (Start containers and run all tests)

## 3. Prepare your contribution

This is all up to you but a few points should be kept in mind:

- Please write tests for your contribution
- Make sure that previous tests still pass
- Make sure that tests are passing using docker
- Push it to a branch of your fork
- Submit a pull request
