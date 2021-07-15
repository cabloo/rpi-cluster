#!/usr/bin/env bash

SRC=/build/output-arm/image
DEST=root@cluster-mgr:/nfs/client1/
MNT=/build/output-arm/mnt
devs=$(kpartx -avs $SRC | cut -d ' ' -f3)
boot_dev=$(echo $devs | cut -d ' ' -f1)
root_dev=$(echo $devs | cut -d ' ' -f2)

mkdir -p $MNT || exit
mount /dev/mapper/$root_dev $MNT/ || exit
mount /dev/mapper/$boot_dev $MNT/boot || exit

rsync -xa --progress --delete --rsh="ssh -o StrictHostKeyChecking=no" $MNT/* $DEST || exit