#!/bin/bash
set -e

if [[ -z "$1" ]]
then
    echo "No image specified, doing garbage collect."
else
    # E.g. $1                     'foo/bar'     'foo/bar:v1.2.3.4/b'
    image="${1%:*}"             # 'foo/bar'     'foo/bar'
    tag="${1:((${#image}+1))}"  # 'v1.2.3.4/b'  ''
    tag="${tag:-latest}"        # 'v1.2.3.4/b'  'latest'

    IMAGE_DIR="/vagrant/registry/docker/registry/v2/repositories/$image/_manifests/tags/$tag"

    if ! [[ -d "$IMAGE_DIR" ]]
    then
        echo "ERROR: Image '$image' with tag '$tag' not found. Aborting." >&2
        exit 1
    fi
fi

docker-compose stop registry
[[ -z "$1" ]] || rm -rv $IMAGE_DIR
docker-compose run --rm --no-deps registry \
    registry garbage-collect \
        --delete-untagged=true \
        /etc/docker/registry/config.yml
docker-compose start registry