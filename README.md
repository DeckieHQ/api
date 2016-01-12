# Deckie API
[![Circle CI](https://circleci.com/gh/foliea/deckie-api.svg?style=svg)](https://circleci.com/gh/foliea/deckie-api)
[![Code Climate](https://codeclimate.com/repos/56952273300abe0069003150/badges/eaf4748164208d70e374/gpa.svg)](https://codeclimate.com/repos/56952273300abe0069003150/feed)
[![Test Coverage](https://codeclimate.com/repos/56952273300abe0069003150/badges/eaf4748164208d70e374/coverage.svg)](https://codeclimate.com/repos/56952273300abe0069003150/coverage)
[![Issue Count](https://codeclimate.com/repos/56952273300abe0069003150/badges/eaf4748164208d70e374/issue_count.svg)](https://codeclimate.com/repos/56952273300abe0069003150/feed)

This is the code source of deckie's platform API. This API is written in
[Ruby](https://www.ruby-lang.org) with [Rails 5](http://rubyonrails.org/).

This API is following the [REST](https://en.wikipedia.org/wiki/Representational_state_transfer) architecture.

## Prerequisite

To run, test and deploy this project, please install before
[Docker 1.8+](https://www.docker.com/) and
[Docker Compose 1.5+](https://docs.docker.com/compose/) and
[Make](https://www.gnu.org/software/make/).

> N.B. Ruby is not required, the development environment and the API will be
run inside linux containers including the proper ruby version.

## Run the API in production mode

In foreground:

    make up

In background:

    make detach

To stop and clean everything after running the API in foreground:

  make clean

## Open a shell in the development environment:

    make shell

> Files inside the container will be synchronised with local files.

You can now type commands like:

    bundle exec rake db:migrate

## Run the test suite

    make test

## Deploy the application

> Not yet implemented.

## License

Deckie API is licensed under the Apache License, Version 2.0. See
[LICENSE](LICENSE) for full license text.
