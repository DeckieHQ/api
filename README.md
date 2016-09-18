# Deckie API

This is the code source of deckie's platform API. This API is written in
[Ruby](https://www.ruby-lang.org) with [Rails 5](http://rubyonrails.org/).

This API is following the [REST](https://en.wikipedia.org/wiki/Representational_state_transfer) architecture
and the [JSON API](http://jsonapi.org) specification.

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

## Run the job worker in production mode

    make worker

## Run the whole stack in production mode

    make detach

> This will run both the API and the job worker inside their own container.

To stop and clean everything after running the whole stack in background:

    make clean

## Open a shell in the development environment:

    make shell

> Files inside the container will be synchronised with local files.

You can now type commands like:

    bundle exec rake db:migrate

## Run the test suite

  Run the migrations once first:

    make migrations

  Then:

    make test

## Deploy the application

> Not yet implemented.

## License

Deckie API is licensed under the Apache License, Version 2.0. See
[LICENSE](LICENSE) for full license text.
