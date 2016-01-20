.PHONY: all re build migrations test up detach shell clean

compose := docker-compose -f docker-compose.yml

all: detach

re: clean build migrations all

build:
	$(compose) build web

migrations: build
	$(compose) run web bundle exec rake db:migrate
	$(compose) run web bundle exec rake db:seed

test: migrations
	$(compose) -f docker-compose.test.yml run test

up: migrations
	$(compose) up web

detach:
	$(compose) up -d web

shell: build
	$(compose) run --service-port shell

clean:
	$(compose) kill
	$(compose) rm --force
