#!/usr/bin/env sh

sudo apt-get update || exit
sudo apt-get full-upgrade || exit
sudo apt-get install -y rpi-eeprom || exit

cd /lib/firmware/raspberrypi/bootloader/default/ || exit
recent=$(ls pieeprom-* | tail -n 1)
cp $recent /tmp/pieeprom-pxe.bin || exit
rpi-eeprom-config /tmp/pieeprom-pxe.bin > /tmp/bootconf.txt || exit
echo "BOOT_ORDER=0xf21\n" >> /tmp/bootconf.txt || exit
rpi-eeprom-config --out /tmp/netboot-pieeprom.bin --config /tmp/bootconf.txt /tmp/pieeprom-pxe.bin || exit
sudo rpi-eeprom-update -d -f /tmp/netboot-pieeprom.bin || exit
