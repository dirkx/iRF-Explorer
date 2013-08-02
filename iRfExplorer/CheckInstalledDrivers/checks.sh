#!/bin/sh

#  checks.sh
#  iRFExplorer
#
#  Created by Dirk-Willem van Gulik on 01-02-12.
#  Copyright (c) 2012 WebWeaving. All rights reserved.

# Do we have any evidence of the drivers installed on this machine.
#
kextfind -case-insensitive  -bundle-id -substring 'com.silabs.driver.CP210' | grep -q SiLabsUSBDriver || exit 1

# Are they in the kernel running right now (they ougth to be if the device
# is plugged in).
#
kextstat  | grep -q com.silabs.driver.CP210 || exit 2

# Do we see a device in /dev which looks like ours. This is actually
# a fairly crappy test. We ought to perhaps use ioreg or something
# to avoid mis-interpreting dangling chaff.
#
ls /dev/cu.* | grep SLAB | grep -q UART || exit 3

# And report an all-well.
#
exit 0
