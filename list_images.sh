#!/bin/bash
set -e
cd /vagrant/registry/docker/registry/v2/repositories
for image in $(find . -name _layers | sed -e 's@^./@@' -e 's@/_layers@@')
do
    if ! [[ -d "$image/_manifests/tags" ]]
    then
        continue
    fi

    pushd "$image/_manifests/tags" >/dev/null
    for tag in *
    do
        echo $image:$tag
    done
    popd >/dev/null
done