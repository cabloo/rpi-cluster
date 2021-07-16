# About
This repo provides a way to PXE boot Raspberry Pis with no SD cards - the Pis pull the OS from the network via PXE. The OS is built using Packer. This is currently a WIP. A lot of this is based on [this great guide](https://linuxhit.com/raspberry-pi-pxe-boot-netbooting-a-pi-4-without-an-sd-card/) but this is much less explanatory, more scripted.

## Requirements
At least 1 Raspberry Pi. I used [this one](https://www.pishop.us/product/raspberry-pi-4-model-b-8gb/) but this likely works on other versions. I recommend the [PoE hat](https://www.pishop.us/product/raspberry-pi-poe-hat/) (Power over Ethernet) so that the only cable you need to plug into the Pi is the ethernet cable. I have 4 Pis hooked up to a single [PoE switch](https://www.amazon.com/gp/product/B083WH142K/ref=ppx_yo_dt_b_asin_title_o06_s00?ie=UTF8&psc=1) using [these short cables](https://www.amazon.com/gp/product/B01IQWGKQ6/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&psc=1).

## Image Builder
Run `cd image-builder && ./build.sh` to build the docker container. The docker container is used by the cluster worker packer build.

## Cluster Manager 
The cluster manager can be a Raspberry Pi, if that Pi has persistent storage (e.g. an SD card). Run `cluster-mgr/install.sh` on the cluster manager.

## Cluster Workers
Each cluster worker will need PXE enabled in its firmware. To do this:

1. Take the SD card of the cluster manager and insert it into a cluster worker
2. Plug that cluster worker into power/ethernet
3. From your main computer: `ssh -t cluster-mgr bash -c './cluster-worker/install-rom.sh && sudo reboot -n'`
4. From your main computer: `ssh -t cluster-mgr sudo shutdown now` - this reboot & shutdown is required to install the new bootloader.
5. Repeat with the remaining cluster workers

To figure out the IPs of the cluster workers, run this on the cluster manager:

```
sudo cat /var/log/daemon.log | grep DHCPACK | cut -d ')' -f2 | cut -d ' ' -f2 | uniq
```

# To Do
- Make the network file system read only
- Load entire network image into memory instead of mounting it as an NFS share? This will slow boot time and eat up a significant chunk of memory but may be worth it for scalibility, performance, and availability in the event of cluster manager downtime
- Put the cluster manager daemons into docker containers (e.g. https://jacobrsnyder.com/2021/01/20/network-booting-a-raspberry-pi-with-docker-support/) 
- Load Kubernetes onto the cluster?
  - Have nodes automatically add themselves to the cluster on boot
  - Automatically distribute work between nodes