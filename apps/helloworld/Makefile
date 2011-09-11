#
# Makefile for building helloworld application
#
# Author: David Weber
# Copyright (C) 2011 Avnet Electronics Marketing
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

SRCS = helloworld.c
OUTNAME = helloworld
OBJS = $(SRCS:.c*=.o)

TOOLCHAIN = /home/beagle/beagleboard/sdk/linux-devkit
CROSS_COMPILE = $(TOOLCHAIN)/bin/arm-arago-linux-gnueabi-
CC = $(CROSS_COMPILE)gcc

CFLAGS = -I.
LDFLAGS =

all: $(OUTNAME)

$(OUTNAME) : $(OBJS) Makefile
	$(CC) $(CFLAGS) $(OBJS) -o $(OUTNAME) $(LDFLAGS)

.PHONY : clean

clean:
	@rm -f $(OUTNAME)
