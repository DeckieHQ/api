#!/bin/bash
set -e

cmd="$1"

build="ci-$CIRCLE_BUILD_NUM"

function provision() {
    bash ./scripts/heroku.sh init $build

    app=$(bash ./scripts/heroku.sh name $build)

    for addon in algoliasearch cloudinary
    do
        heroku addons:create $addon --app $app
    done
}

function configure() {
    bash scripts/heroku.sh env $build
}

function clean() {
    bash ./scripts/heroku.sh clean $build
}

for supported_cmd in provision configure clean
do
    if [ "$cmd" == $supported_cmd ]; then
        eval $cmd

        exit 0
    fi
done

echo "usage: bash scripts/ci.sh [provision|configure|clean]"

exit -1
