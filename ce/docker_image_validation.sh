#!/bin/bash

# Specify the image name and tag
image_name="jalien-base"
image_tag="latest"

# Check if the image is present
if sudo docker images "$image_name:$image_tag" | awk 'NR>1 {print $1":"$2}' | grep -q "$image_name:$image_tag"; then
    echo "Docker image $image_name:$image_tag is present on the system."
else
    echo "Docker image $image_name:$image_tag is not found on the system."
fi
