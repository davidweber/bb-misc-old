#!/bin/bash

#
#  Script for setting up Beagleboard SDK from TI.
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

echo "
#
# Beagleboard-xM Setup Script
#
"

MY_DIR=$PWD

SDK_DIR_URL=http://software-dl.ti.com/dsps/dsps_public_sw/am_bu/sdk/BeagleBoardSDK/latest/exports

SDK_INSTALLER=ti-sdk-beagleboard-05.02.00.00-Linux-x86-Install

INSTALL_DIR=${HOME}/beagleboard

SDK_VER=ti-sdk-beagleboard-05.02.00.00

SDK_DIR=${INSTALL_DIR}/${SDK_VER}

SDK_SOFTLINK_DIR=${INSTALL_DIR}/sdk

if [ ! -d "${INSTALL_DIR}" ]; then
  mkdir -p ${INSTALL_DIR}
fi
cd ${INSTALL_DIR}

if [ ! -f "${INSTALL_DIR}/${SDK_INSTALLER}" ]; then
  wget -nc ${SDK_DIR_URL}/${SDK_INSTALLER}
fi

if [ ! -d "${SDK_DIR}" ]; then
  chmod 755 ${SDK_INSTALLER}
  ./${SDK_INSTALLER} --prefix ${SDK_DIR}
fi

if [ -h ${SDK_SOFTLINK_DIR} ]; then
  rm -f ${SDK_SOFTLINK_DIR}
fi

ln -s ${SDK_DIR} sdk

cd ${SDK_DIR}

./setup.sh

echo "
The Arago project can be used to create custom root filesystem images for the 
Beagleboard-xM. Installing the Arago project is optional, because the SDK 
provides a prebuilt root filesystem image that can be used to start working
with the Beagleboard-xM immediately after installing the SDK.  If a custom root
filesystem is required, then the Arago project must be installed.

Do you wish to install the Arago project? (y/n)"

read -p "[ n ] " INSTALL_ARAGO

INSTALL_ARAGO=`echo ${INSTALL_ARAGO} | tr '[:upper:]' ' [:lower:]'`

if [ "${INSTALL_ARAGO}" != "y" ]; then
  exit
fi

echo "
Installing Arago project...
"
if [ ! -d "${INSTALL_DIR}/oe" ]; then
  mkdir -p ${INSTALL_DIR}/oe
fi

cd ${INSTALL_DIR}/oe

if [ ! -d "${INSTALL_DIR}/oe/arago" ]; then
  git clone git://arago-project.org/git/projects/arago-amsdk.git arago
else
  echo "Skipping download of arago.git"
fi

if [ ! -d "${INSTALL_DIR}/oe/arago-oe-dev" ]; then
  git clone git://arago-project.org/git/projects/arago-oe-amsdk.git arago-oe-dev
else
  echo "Skipping download of arago-oe-amsdk.git"
fi

if [ ! -d "${INSTALL_DIR}/oe/arago-bitbake" ]; then
  git clone git://arago-project.org/git/arago-bitbake.git
else
  echo "Skipping download of arago-bitbake.git"
fi

if [ ! -d "${INSTALL_DIR}/oe/arago-utils" ]; then
  git clone git://arago-project.org/git/arago-utils.git
else
  echo "Skipping download of arago-utils.git"
fi

echo "
Installing additional packages...
"

sudo apt-get install diffstat texi2html texinfo cvs subversion chrpath python-dev

echo "
The Arago project has been downloaded, but a root filesystem based on the Arago 
project has not been built.  Building the root filessystem from scratch requires 
a lot of storage space and time. 

Do you wish to build a root filesystem, based on the Arago project? (y/n)"

read -p "[ n ] " BUILD_ARAGO

BUILD_ARAGO=`echo ${BUILD_ARAGO} | tr '[:upper:]' ' [:lower:]'`

if [ "${BUILD_ARAGO}" != "y" ]; then
  exit
fi

echo "
Building Arago root filesystem...
"

cp ${MY_DIR}/setenv arago/

cp ${MY_DIR}/local.conf arago/conf/

source arago/setenv

bitbake libsamplerate0

bitbake arago-base-image
 
echo "
Done
"
