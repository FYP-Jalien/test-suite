#!/bin/bash

# Docker container name or ID
container_name=$(sudo docker ps --format "{{.Names}}" | grep "worker1")

sudo docker exec -it $container_name /bin/bash

cd /var/lib/condor/execute

ls -a