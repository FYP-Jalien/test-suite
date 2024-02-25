#!/bin/bash

set -e

expected_image="htcondor/cm:10.0.0-el7"
expected_volumes=("$JALIEN_SETUP_PATH"/ce-setup/htcondor-conf/pool_password)
expected_environment="USE_POOL_PASSWORD=yes "

id=$((id + 1))
name="Schedd Container Up Check"
description="Schedd container should be running."
level="Critical"
if sudo docker ps --format '{{.Names}}' | grep -qw "$CONTAINER_NAME_SCHEDD"; then
    status="PASSED"
    message="The $CONTAINER_NAME_SCHEDD is running."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_SCHEDD is not running."
    echo $status
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="Schedd Container Image Check"
description="Schedd container should be running with $expected_image."
level="Warning"
actual_image=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME_SCHEDD")
if [ "$actual_image" == "$expected_image" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_SCHEDD is running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_SCHEDD is expected to run with $expected_image but running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="Schedd Container Volume Check"
expected_volumes_string=$(convert_array_to_string "${expected_volumes[@]}")
description="Schedd container should be running with $expected_volumes_string mounted."
level="Warning"
actual_volumes=$(sudo docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Mode}} {{end}}' "$CONTAINER_NAME_SCHEDD")
for volume in "${expected_volumes[@]}"; do
    if [[ ! " ${actual_volumes[*]} " =~ $volume ]]; then
        status="FAILED"
        message="Error: Volume $volume is not mounted in the $CONTAINER_NAME_SCHEDD container's volumes."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_SCHEDD is running with $actual_volumes."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="Schedd Container Env Check"
expected_environment_string=$(convert_array_to_string "${expected_environment[@]}")
description="Schedd container should be running with $expected_environment_string mounted."
level="Warning"
actual_environment=$(sudo docker inspect --format='{{range $key, $value := .Config.Env}}{{$value}} {{end}}' "$CONTAINER_NAME_SCHEDD")
for env in "${expected_environment[@]}"; do
    if [[ ! " ${actual_environment[*]} " =~ $env ]]; then
        status="FAILED"
        message="Error: Env $env is not set in the $CONTAINER_NAME_SCHEDD container's envs."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_SCHEDD is running with $actual_environment."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

