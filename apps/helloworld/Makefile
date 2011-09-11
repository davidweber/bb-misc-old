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
