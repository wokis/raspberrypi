#!/bin/bash

rootfs=$1
dist="wheezy"
mirror="http://archive.raspbian.org/raspbian"
include="net-tools,isc-dhcp-client,nano,openssh-server,rsync"

aptsources="deb http://archive.raspbian.org/raspbian wheezy main contrib non-free\ndeb-src http://archive.raspbian.org/raspbian wheezy main contrib non-free"

if [ "$rootfs" == "" ]; then
	echo "No directory to install to given."
	exit 1
fi

if [ $EUID -ne 0 ]; then
	echo "This tool must be run as root."
	exit 1
fi

echo "Executing debootstrap..."
debootstrap --arch armhf --foreign --variant minbase --include $include $dist $rootfs $mirror

echo "Preparing for ARM emulation..."
cp /usr/bin/qemu-arm-static $rootfs/usr/bin

echo "Executing second stage debootstrap..."
chroot $rootfs /debootstrap/debootstrap --second-stage

echo "Configuring RootFS..."
chroot $rootfs echo -e $aptsources > /etc/apt/sources.list

echo "RootFS installation into '$rootfs' completed."
