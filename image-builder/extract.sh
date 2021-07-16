#!/usr/bin/env bash

SRC=$1
DEST=$2
MNT=/tmp/mnt
devs=$(kpartx -avs $SRC | cut -d ' ' -f3)
boot_dev=$(echo $devs | cut -d ' ' -f1)
root_dev=$(echo $devs | cut -d ' ' -f2)

mkdir -p $MNT || exit
mount /dev/mapper/$root_dev $MNT/ || exit
mount /dev/mapper/$boot_dev $MNT/boot || exit

rsync -xa --progress --delete --rsh="ssh -o StrictHostKeyChecking=no" $MNT/* $DEST || exit

umount /dev/mapper/$boot_dev || exit
umount /dev/mapper/$root_dev || exit

kpartx -dvs $SRC || exit