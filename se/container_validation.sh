#!/bin/bash

expected_image="xrootd-se"
expected_command="xrootd -c /etc/xrootd/xrootd-standalone.cfg"
expected_ports=("1094/tcp")
expected_volumes=("$SHARED_VOLUME_PATH:/jalien-dev")

id=$((id + 1))
name="SE Container Up Check"
description="SE container should be running."
level="Critical"
if sudo docker ps --format '{{.Names}}' | grep -qw "$CONTAINER_NAME_SE"; then
    status="PASSED"
    message="The $CONTAINER_NAME_SE is running."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_SE is not running."
    echo $status
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="SE Container Image Check"
description="SE container should be running with $expected_image."
level="Warning"
actual_image=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME_SE")
if [ "$actual_image" == "$expected_image" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_SE is running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_SE is expected to run with $expected_image but running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="SE Container Volume Check"
expected_volumes_string=$(convert_array_to_string "${expected_volumes[@]}")
description="SE container should be running with $expected_volumes_string mounted."
level="Warning"
actual_volumes=$(sudo docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Mode}} {{end}}' "$CONTAINER_NAME_SE")
status="PASSED"
for volume in "${expected_volumes[@]}"; do
    if [[ ! " ${actual_volumes[*]} " =~ $volume ]]; then
        status="FAILED"
        message="Error: Volume $volume is not mounted in the $CONTAINER_NAME_SE container's volumes."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_SE is running with $actual_volumes."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="SE Container Command Check"
description="SE container should be running with command $expected_command"
level="Warning"
actual_command=$(sudo docker inspect --format='{{.Config.Cmd}}' "$CONTAINER_NAME_SE")
if [ ${#actual_command[@]} -eq 1 ] && [ "${actual_command[0]}" = "$expected_command" ]; then
    status="FAILED"
    message="Error: Volume $volume is not mounted in the $CONTAINER_NAME_SE container's volumes."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="PASSED"
    message="The $CONTAINER_NAME_SE is running with $actual_volumes."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="SE Container Port Check"
expected_ports_string=$(convert_array_to_string "${expected_ports[@]}")
description="SE container should be running with having ports $expected_ports_string."
level="Warning"
actual_ports=$(sudo docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} {{end}}' "$CONTAINER_NAME_SE")
status="PASSED"
for port in "${expected_ports[@]}"; do
    if [[ ! " ${actual_ports[*]} " =~ $port ]]; then
        status="FAILED"
        message="Error: Port $port is not in the $CONTAINER_NAME_SE container's ports."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_SE is running with $actual_ports."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_hostname="JCentral-dev-SE"
id=$((id + 1))
name="SE Container Hostname Check"
description="SE container should have $expected_hostname"
level="Minor"
actual_hostname=$(sudo docker inspect --format='{{.Config.Hostname}}' "$CONTAINER_NAME_SE" )
if [ "$actual_hostname" != $expected_hostname ]; then
    status="FAILED"
    message="Error: $CONTAINER_NAME_SE container is expected to have hostname $expected_hostname but has hostname $actual_hostname."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="PASSED"
    message="$CONTAINER_NAME_SE hostname is $actual_hostname"
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi