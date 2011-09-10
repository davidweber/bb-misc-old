#! /bin/bash

#
#  Creates SD Card for booting Linux on Beagleboard.
#
#  Author: David Weber
#  Copyright (C) 2011 Avnet Electronics Marketing
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

echo "Creating SDCard ..."

if [ "$#" -lt "1" ]; then
  echo "usage: $0 <device name> [boot partition size (MB)] [image file dir] [rootfs tarball]"
  exit
fi

device=$1

# validate device
if [ ! -b "${device}" ]; then
  echo "error: invalid device name (${device})"
  exit
fi

if [ "/dev/sda" == "${device}" ]; then
  echo "error: forbidden device name (${device})"
  exit
fi

# setup some defaults
boot_partition_MB=150
img_dir=${HOME}/beagleboard/sdk/psp/prebuilt-images
rootfs_tarball=${HOME}/beagleboard/sdk/filesystem/tisdk-rootfs-beagleboard.tar.gz

# check for command line arguments to override defaults
if [ "$#" -gt "1" ]; then
  boot_partition_MB=$2
fi

if [ "$#" -gt "2" ]; then
  img_dir=$3
fi

if [ "$#" -gt "3" ]; then
  rootfs_tarball=$4
fi

echo "Using boot files from ${img_dir}"
echo "Using rootfs tarball (${rootfs_tarball})"

sudo umount /tmp/sdboot 2> /dev/null
sudo umount /tmp/sdrootfs 2> /dev/null

sudo ./format_sdcard.bash ${device} ${dos_partition_MB}

sudo mkdir -p /tmp/sdboot
sudo mount ${device}1 /tmp/sdboot

sudo mkdir -p /tmp/sdrootfs
sudo mount ${device}2 /tmp/sdrootfs

echo "${img_dir}/MLO-beagleboard"

sudo cp ${img_dir}/MLO-beagleboard /tmp/sdboot/MLO
sync
sudo cp ${img_dir}/u-boot-beagleboard.bin /tmp/sdboot/u-boot.bin
sync
ls -al /tmp/sdboot
sudo umount /tmp/sdboot

#sudo cp ${rootfs_tarball} /tmp/sdrootfs/
start_dir=`pwd`
cd /tmp/sdrootfs
sudo tar -pxzf ${rootfs_tarball}
sync
#rm -f ${rootfs_tarball}
sync
ls -al /tmp/sdrootfs
cd ${start_dir}
sudo umount /tmp/sdrootfs

echo Done
