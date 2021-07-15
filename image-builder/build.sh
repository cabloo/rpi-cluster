#!/usr/bin/env bash

if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "Please create an SSH RSA key at ${HOME}/.ssh/id_rsa.pub using ssh-keygen"
    exit 1
fi

function retry {
    retries=$1
    command=$2

    for i in `seq 1 $retries`; do
        $command
        ret_value=$?
        [ $ret_value -eq 0 ] && break
    done

    return $ret_value
}

function build_image {
    docker run \
        --rm \
        --privileged \
        -v /dev:/dev \
        -v ~/.ssh/id_rsa.pub:/build/id_rsa.pub:ro \
        -v ${PWD}/raspbian.json:/build/config.json:ro \
        -v ${PWD}/.packer_cache:/build/packer_cache \
        -v ${PWD}/out:/build/output-arm \
        packer-builder-arm build config.json
    return $?
}

function push_image {
    docker run \
        --rm \
        --privileged \
        --network=host \
        -v /dev:/dev \
        -v ${HOME}/.ssh/id_rsa:/root/.ssh/id_rsa \
        -v ${PWD}/out:/build/output-arm \
        --entrypoint /extract.sh \
        packer-builder-arm
    return $?
}

docker build container -t packer-builder-arm || exit
retry 3 build_image || exit
retry 3 push_image || exit
