#!/bin/bash

function convert_array_to_string(){
    local string_array=("$@")
    local result=""
    for element in "${string_array[@]}"; do
        result+=", $element"
    done
    result="${result:2}"
    echo "$result"

}