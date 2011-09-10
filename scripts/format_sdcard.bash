#!/bin/bash

#
#  Script for formatting SD Card for booting Linux.
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

function print_msg()
{
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo " $1"
  echo "--------------------------------------------------------------------------------"
}

device=$1;

# check command arguments
if [ "$#" -lt "1" ]; then
  echo "usage: sudo $0 <disk> [part1 size (MB)] [part2 size (MB)]"
  exit;
fi

if [ ! -b "${device}" ]; then
  print_msg "Error: device ${device} not found"
  exit
fi

# setup some constants
n_heads=255
n_sectors=63
sector_sz=512

# setup some defaults
part1_MB=120

if [ "$#" -gt "1" ]; then
  part1_MB=$2
fi

part1_n_cyl=`echo ${part1_MB}*1024*1024/${sector_sz}/${n_heads}/${n_sectors} | bc`
part2_n_cyl= 

# if the second partition size is specified, calculate n cylinders for it
if [ "$#" -gt "2" ]; then
  part2_MB=$3
  part2_n_cyl=`echo ${part2_MB}*1024*1024/${sector_sz}/${n_heads}/${n_sectors} | bc`
fi

# setup partition types
dos=0x0C
linux=L

# assign partition types to each partition
part1_type=${dos}
part2_type=${linux}

# assign partition labels to each partition
part1_label=boot
part2_label=root

# unmount any existing device partitions
print_msg "Unmounting any mounted partitions on ${device}"
devlist=`df | grep ${device}`
if [ "$devlist" != "" ]; then
  df | grep ${device} | awk '{print $1}' | xargs umount
fi

mbr_sz=532
mbr_file=sd.mbr.dd

# see man page for sfdisk for more info
print_msg "Clearing MBR (first ${mbr_sz} bytes) of ${device}"
dd of=${device} if=/dev/zero bs=${mbr_sz} count=1

# create partition table
print_msg "Creating partition table on ${device}"

# look for the MBR saved from a previous execution of this script
if [ -f "${mbr_file}" ]; then
  dd of=${device} if=${mbr_file} bs=${mbr_sz} count=1
else
  fdisk ${device} > /dev/null << EOF
w
EOF
  # save off the MBR so we can avoid running fdisk next time this script runs, because
  # fdisk always produces a warning message
  dd of=${mbr_file} if=${device} bs=${mbr_sz} count=1
fi

# calculate number of cylinders on disk
device_sz=`blockdev --getsize64 ${device}`
n_cylinders=`echo ${device_sz}*1024/${n_heads}/${n_sectors}/${sector_sz} | bc`

# create the partitions on the disk
print_msg "Creating boot and root partitions on ${device}"
sfdisk -D -H ${n_heads} -S ${n_sectors} -C ${n_cylinders} ${device} << EOF
,${part1_n_cyl},${part1_type},*
,${part2_n_cyl},${part2_type},-
EOF

# insure that the kernel is aware of the new partitions
partprobe ${device}

# format the partitions
print_msg "Formatting (FAT32) boot partition ${device}1"
mkfs.vfat -F 32 -n "${part1_label}" ${device}1

print_msg "Formatting (EXT3) root partition ${device}2"
mkfs.ext3 -L "${part2_label}" ${device}2

# list the partitions to verify success
sfdisk -l  ${device}
