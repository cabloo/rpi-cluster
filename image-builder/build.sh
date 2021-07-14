#!/usr/bin/env sh

if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "Please create an SSH RSA key at ${HOME}/.ssh/id_rsa.pub using ssh-keygen"
    exit 1
fi

sudo docker run \
  --rm \
  --privileged \
  -v ~/.ssh/id_rsa.pub:/build/id_rsa.pub:ro \
  -v ${PWD}/raspbian.json:/build/config.json:ro \
  -v ${PWD}/.packer_cache:/build/packer_cache \
  -v ${PWD}/out:/build/output-arm-image \
  quay.io/solo-io/packer-builder-arm-image:v0.1.6 build config.json || exit 1

echo
echo
echo "====="
echo "Build finished successfully - build image stored at ${PWD}/out/image"