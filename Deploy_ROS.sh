#!/bin/bash

version="7.16"

docker stop routeros-$version
docker rm routeros-$version
docker rmi routeros-$version-final

docker load -i ./routeros-$version-final.tar

# ADD/REMOVE PORTS WHERE NEEDED - ipv4-all.nics.on.host:host_port:docker_port / [ipv6-all.nics.on.host]:host_port:docker_port
# NOTE: SSH port is mapped to 222
docker run -d \
	--network=ros-bridge-net \
	--ip=192.168.200.2 \
	--privileged \
	-p 0.0.0.0:21:21 -p [::]:21:21 \
	-p 0.0.0.0:222:22 -p [::]:222:22 \
	-p 0.0.0.0:23:23 -p [::]:23:23 \
	-p 0.0.0.0:80:80 -p [::]:80:80 \
	-p 0.0.0.0:179:179 -p [::]:179:179 \
	-p 0.0.0.0:8728:8728 -p [::]:8728:8728 \
	-p 0.0.0.0:8729:8729 -p [::]:8729:8729 \
	-p 0.0.0.0:8291:8291 -p [::]:8291:8291 \
	-p 0.0.0.0:13231:13231/udp -p [::]:13231:13231/udp \
	--restart unless-stopped \
	--name routeros-$version \
	routeros:$version-final

exit 0