#!/bin/bash
source ../.env

sudo docker exec -it $CONTAINER_NAME_WORKER /bin/bash

cd /var/lib/condor/execute

ls -a