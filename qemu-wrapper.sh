#!/bin/bash

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

NIC=$(ip route show default | awk '/default/ {print $5}' | head -n1)

if [ -z "$NIC" ]; then
	echo "No network interface found. Exiting..."
	exit 1
fi

ip addr flush dev "$NIC"

if ip link show br0 > /dev/null 2>&1; then
	echo "Bridge br0 already exists. Skipping creation."
else
	ip link add name br0 type bridge
	ip link set "$NIC" master br0
	ip link set br0 up
	ip link set "$NIC" up
fi

ip tuntap add dev tap0 mode tap
ip link set tap0 master br0
ip link set tap0 up

# For .img
qemu-system-x86_64 \
	-nographic \
	-drive file=chr.img,format=raw,if=virtio \
	-m 1024 \
	-netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
	-device e1000,netdev=net0 \
	-serial mon:stdio