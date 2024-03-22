#!/bin/bash

id=$((id + 1))
name="CE Container Up Check"
description="CE container should be running."
level="Critical"
if sudo docker ps --format '{{.Names}}' | grep -qw "$CONTAINER_NAME_CE"; then
    status="PASSED"
    message="The $CONTAINER_NAME_CE is running."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_CE is not running."
    echo $status
    print_full_test "$id" "$name" $status "$description" $level "$message"    
fi

expected_image="jalien-ce"
id=$((id + 1))
name="CE Container Image Check"
description="CE container should be running with $expected_image."
level="Warning"
actual_image=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME_CE")
if [ "$actual_image" == "$expected_image" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_CE is running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_CE is expected to run with $expected_image but running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_volumes=("$SHARED_VOLUME_PATH:/jalien-dev" "$JALIEN_CETUP_PATH/ce-setup:/ce-setup:ro" "$JALIEN_CETUP_PATH/ce-setup/htcondor-conf/pool_password:/root/secrets/pool_password")
id=$((id + 1))
name="CE Container Volume Check"
expected_volumes_string=$(convert_array_to_string "${expected_volumes[@]}")
description="CE container should be running with $expected_volumes_string mounted."
level="Warning"
actual_volumes=$(sudo docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Mode}} {{end}}' "$CONTAINER_NAME_CE")
status="PASSED"
for volume in "${expected_volumes[@]}"; do
    if [[ ! " ${actual_volumes[*]} " =~ $volume ]]; then
        status="FAILED"
        message="Error: Volume $volume is not mounted in the $CONTAINER_NAME_CE container's volumes."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_CE is running with $actual_volumes."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_command="[bash /ce-setup/ce-entrypint.sh]"
id=$((id + 1))
name="CE Container Command Check"
description="CE container should be running with command $expected_command"
level="Warning"
actual_command=$(sudo docker inspect --format='{{.Config.Cmd}}' "$CONTAINER_NAME_CE")
if [ "$actual_command" != "$expected_command" ]; then
    status="FAILED"
    message="Error: $CONTAINER_NAME_CE is supposed to start with $expected_command but starting with $actual_command."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="PASSED"
    message="The $CONTAINER_NAME_CE is starting with $actual_command."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_environment=( "CONDOR_HOST=schedd" "USE_POOL_PASSWORD=yes" "LD_LIBRARY_PATH=/tmp" )
id=$((id + 1))
name="CE Container Env Check"
expected_environment_string=$(convert_array_to_string "${expected_environment[@]}")
description="CE container should be running with $expected_environment_string mounted."
level="Warning"
actual_environment=$(sudo docker inspect --format='{{range $key, $value := .Config.Env}}{{$value}} {{end}}' "$CONTAINER_NAME_CE")
status="PASSED"
for env in "${expected_environment[@]}"; do
    if [[ ! " ${actual_environment[*]} " =~ $env ]]; then
        status="FAILED"
        message="Error: Env $env is not set in the $CONTAINER_NAME_CE container's envs."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_CE is running with $actual_environment."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_hostname="localhost.localdomain"
id=$((id + 1))
name="CE Container Hostname Check"
description="CE container should have $expected_hostname"
level="Minor"
actual_hostname=$(sudo docker inspect --format='{{.Config.Hostname}}' "$CONTAINER_NAME_CE")
if [ "$actual_hostname" != $expected_hostname ]; then
    status="FAILED"
    message="Error: $CONTAINER_NAME_CE is expected to have hostname $expected_hostname but has hostname $actual_hostname."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="PASSED"
    message="The $CONTAINER_NAME_CE has hostname $actual_hostname"
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi