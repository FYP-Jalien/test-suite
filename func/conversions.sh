#!/bin/bash

function convert_array_to_string() {
    local string_array=("$@")
    local result=""
    for element in "${string_array[@]}"; do
        result+=", $element"
    done
    result="${result:2}"
    echo "$result"

}

function convert_to_ce_time() {
    docker exec "$CONTAINER_NAME_CE" date +"%Y-%m-%d"
}
