#!/bin/bash

version="7.16"

apt-get update
apt-get -y install docker.io wget unzip
apt-get clean

# Stop and remove the existing container if it's running
docker stop routeros-$version || true
docker rm routeros-$version || true

# Remove the existing image to ensure a clean build
docker rmi routeros:$version || true

# List all images and containers to verify cleanup
docker image ls -a
docker ps -a

# Build the new Docker image
echo "Building the routeros:"$version" image..."
[ -e "./chr-"$version".img" ] || wget "https://download.mikrotik.com/routeros/"$version"/chr-"$version".img.zip" && unzip "chr-"$version".img.zip"  && rm "chr-"$version".img.zip"
docker build -t routeros:$version .

# Run the container interactively to make modifications
echo "Running routeros-"$version" container interactively for modification..."
docker run -it --network=ros-bridge-net --privileged --name routeros-$version routeros:$version

# After the user modifies and shuts down the container, commit the changes
echo "Committing the modified container to a new image: routeros:"$version"-final"
docker commit routeros-$version routeros:$version-final

# Remove the modified container now that it's committed
docker rm routeros-$version

# Export the final image for backup or deployment
echo "Exporting the final routeros image to routeros-"$version"-final.tar"
docker save -o routeros-$version-final.tar routeros:$version-final

# List the images to verify the export
docker image ls

# Run the exported image in the background with necessary port bindings
echo "Running the final exported routeros-"$version" image in the background..."
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

# List running containers to verify the final container is up
docker ps