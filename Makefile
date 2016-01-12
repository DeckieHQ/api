.PHONY: all re build migrations test up detach shell clean

compose := docker-compose

all: detach

re: clean build migrations all

build:
	$(compose) build web

migrations: build
	$(compose) run web bundle exec rake db:migrate

test: migrations
	$(compose) run web bundle exec rake test

up: migrations
	$(compose) up web

detach:
	$(compose) up -d web

shell: build
	$(compose) run shell

clean:
	$(compose) kill
	$(compose) rm --force
