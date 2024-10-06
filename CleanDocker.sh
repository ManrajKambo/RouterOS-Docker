#!/bin/bash

# To delete all containers including its volumes use,
docker rm -vf $(docker ps -aq)

# To delete all the images,
docker rmi -f $(docker images -aq)

# List all images and containers to verify cleanup
docker image ls -a
docker ps -a

exit 0