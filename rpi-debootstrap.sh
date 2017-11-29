#!/bin/bash

# requires debootstrap, qemu-arm-static

rootfs=$1
dist="stretch"
mirror="http://archive.raspbian.org/raspbian"
include="net-tools,isc-dhcp-client,nano,openssh-server,rsync,wget"

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
echo -e $aptsources > $rootfs/etc/apt/sources.list

cat > $rootfs/etc/apt/apt.conf << EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

cat > $rootfs/etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

echo "RootFS installation into '$rootfs' completed."
