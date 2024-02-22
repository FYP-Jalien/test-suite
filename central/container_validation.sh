#!/bin/bash

id=$((id + 1))
name="CENTRAL Container Up Check"
description="CENTRAL container should be running."
level="Critical"
if sudo docker ps --format '{{.Names}}' | grep -qw "$CONTAINER_NAME_CENTRAL"; then
    status="PASSED"
    message="The $CONTAINER_NAME_CENTRAL is running."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_CENTRAL is not running."
    echo $status
    print_full_test "$id" "$name" $status "$description" $level "$message"    
fi

expected_image="jalien-base-18"
id=$((id + 1))
name="CENTRAL Container Image Check"
description="CENTRAL container should be running with $expected_image."
level="Warning"
actual_image=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME_CENTRAL")
if [ "$actual_image" == "$expected_image" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_CENTRAL is running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="FAILED"
    message="The $CONTAINER_NAME_CENTRAL is expected to run with $expected_image but running with $actual_image."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_volumes=("$SHARED_VOLUME_PATH:/jalien-dev:rw" "$JALIEN_SETUP_PATH:/jalien-setup:ro")
id=$((id + 1))
name="CENTRAL Container Volume Check"
expected_volumes_string=$(convert_array_to_string "${expected_volumes[@]}")
description="CENTRAL container should be running with $expected_volumes_string mounted."
level="Warning"
actual_volumes=$(sudo docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Mode}} {{end}}' "$CONTAINER_NAME_CENTRAL" )
status="PASSED"
for volume in "${expected_volumes[@]}"; do
    if [[ ! " ${actual_volumes[*]} " =~ $volume ]]; then
        status="FAILED"
        message="Error: Volume $volume is not mounted in the $CONTAINER_NAME_CENTRAL container's volumes."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_CENTRAL is running with $actual_volumes."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_command="[/jalien-setup/bash-setup/entrypoint.sh]"
id=$((id + 1))
name="CENTRAL Container Command Check"
description="CENTRAL container should be running with command $expected_command"
level="Warning"
actual_command=$(sudo docker inspect --format='{{.Config.Cmd}}' "$CONTAINER_NAME_CENTRAL" )
if [ "$actual_command" != "$expected_command" ]; then
    status="FAILED"
    message="Error: $CONTAINER_NAME_CENTRAL is supposed to start with $expected_command but starting with $actual_command."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="PASSED"
    message="The $CONTAINER_NAME_CENTRAL is starting with $actual_command."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_environment=("SE_HOST=JCentral-dev-SE")
id=$((id + 1))
name="CENTRAL Container Env Check"
expected_environment_string=$(convert_array_to_string "${expected_environment[@]}")
description="CENTRAL container should be running with $expected_environment_string mounted."
level="Warning"
actual_environment=$(sudo docker inspect --format='{{range $key, $value := .Config.Env}}{{$value}} {{end}}' "$CONTAINER_NAME_CENTRAL" )
status="PASSED"
for env in "${expected_environment[@]}"; do
    if [[ ! " ${actual_environment[*]} " =~ $env ]]; then
        status="FAILED"
        message="Error: Env $env is not set in the $CONTAINER_NAME_CENTRAL container's envs."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_CENTRAL is running with $actual_environment."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

expected_hostname="JCentral-dev"
id=$((id + 1))
name="CENTRAL Container Hostname Check"
description="CENTRAL container should have $expected_hostname"
level="Minor"
actual_hostname=$(sudo docker inspect --format='{{.Config.Hostname}}' "$CONTAINER_NAME_CENTRAL" )
if [ "$actual_hostname" != $expected_hostname ]; then
    status="FAILED"
    message="Error: Volume $volume is not running with $expected_hostname but running with $actual_hostname."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    status="PASSED"
    message="The $CONTAINER_NAME_CENTRAL is running with $actual_hostname."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

id=$((id + 1))
name="CENTRAL Container Port Check"
expected_ports=("8098/tcp" "8097/tcp" "3307/tcp" "8389/tcp")
expected_ports_string=$(convert_array_to_string "${expected_ports[@]}")
description="CENTRAL container should be running with having ports $expected_ports_string."
level="Critical"
actual_ports=$(sudo docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} {{end}}' "$CONTAINER_NAME_CENTRAL")
status="PASSED"
for port in "${expected_ports[@]}"; do
    if [[ ! " ${actual_ports[*]} " =~ $port ]]; then
        status="FAILED"
        message="Error: Port $port is not in the $CONTAINER_NAME_CENTRAL container's ports."
    fi
done
if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="The $CONTAINER_NAME_CENTRAL is running with $actual_ports."
    print_full_test "$id" "$name" $status "$description" $level "$message"
else
    print_full_test "$id" "$name" $status "$description" $level "$message"
  fi
