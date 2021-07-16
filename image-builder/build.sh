#!/usr/bin/env sh

docker build . -t packer-builder-arm || exit
