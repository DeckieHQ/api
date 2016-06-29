#!/bin/bash
set -e

cmd="$1"

build="$2"

app="$build-deckie-api"

function init() {
    echo "Creating heroku app $app..."

    heroku apps:create $app --region eu
}
function configure() {
    ssl_prefix="http"

    if [ "$CUSTOM_DOMAIN" ]; then

        if [ $build == "staging" ]; then
            ssl_prefix="https"
        fi

        if [ $build == "production" ]; then
            api_domain_name="api.$CUSTOM_DOMAIN"
            front_domain_name="www.$CUSTOM_DOMAIN"
            email_signature="contact@$CUSTOM_DOMAIN"

            ssl_prefix="https"

            heroku config:set --app $app CORS_ORIGINS="$ssl_prefix://$CUSTOM_DOMAIN,$ssl_prefix://www.$CUSTOM_DOMAIN"
        else
            api_domain_name="$build-api.$CUSTOM_DOMAIN"
            front_domain_name="$build.$CUSTOM_DOMAIN"
            email_signature="$build@$CUSTOM_DOMAIN"
        fi
        heroku domains:clear --app $app

        heroku domains:add --app $app $api_domain_name
    else
        api_domain_name="$app.herokuapp.com"

        front_domain_name=${api_domain_name/api/front}

        if [ -z "$EMAIL_DOMAIN" ]; then
            EMAIL_DOMAIN="deckie.fr"
        fi

        email_signature="$build@$EMAIL_DOMAIN"
    fi

    heroku config:set --app $app API_URL="$ssl_prefix://$api_domain_name" \
                                 FRONT_URL="$ssl_prefix://$front_domain_name" \
                                 EMAIL_SIGNATURE=$email_signature
}

function deploy() {
    echo "Deploying heroku app $app..."

    maintenance-on

    heroku docker:release --app $app

    heroku run --app $app bundle exec rake db:migrate

    maintenance-off
}

function post-install() {
    email_signature=$(heroku config:get --app $app EMAIL_SIGNATURE)

    echo "Please add and confirm the following sender signature in postmark:"

    echo -e "\n\t$email_signature\n"

    heroku addons:open --app $app POSTMARK
}

function env() {
    echo "Copying heroku app $app environment variables..."

    heroku config --app $app -s > .env
}

function upgrade() {
    echo "Upgrading dynos..."

    heroku dyno:type hobby --app $app

    echo "Upgrading addons to production..."

    maintenance-on

    for addon in blowerio:starter heroku-redis:premium-0
    do
        heroku addons:upgrade $addon --app $app || true
    done

    echo "Waiting for redis upgrade..."

    heroku redis:wait --app $app

    maintenance-off
}

function clean() {
    heroku apps:destroy --app $app --confirm $app
}

function name() {
    echo $app
}

function maintenance-on() {
    heroku maintenance:on --app $app

    heroku ps:scale web=0 --app $app

    heroku ps:scale worker=0 --app $app
}

function maintenance-off() {
    heroku ps:scale web=1 --app $app

    heroku ps:scale worker=1 --app $app

    heroku maintenance:off --app $app
}

for supported_cmd in init configure deploy post-install env upgrade clean name
do
    if [ "$cmd" == $supported_cmd ]; then
        if [ ! $build ]; then
            echo "Please specify a build type."

            exit -1
        fi

        eval $cmd

        exit 0
    fi
done

echo "usage: bash scripts/heroku.sh [init|configure|deploy|post-install|env|upgrade|clean|name] build"

exit -1
