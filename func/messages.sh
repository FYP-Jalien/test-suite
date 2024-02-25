#!/bin/bash

success_color="\e[32m"
error_color="\e[31m"
reset_color="\e[0m"

# Function to echo success message in green color
function print_success() {
    echo -e "$success_color$1$reset_color"
}

# Function to echo error message in red color
function print_error() {
    echo -e "$error_color$1$reset_color"
}

# Function to echo test header.
function print_test_header() {
    echo -e "\n====== Running all tests for $1 ======\n"
}

function print_full_test() {
    test_id=$1
    test_name=$2
    test_status=$3
    test_description=$4
        test_level=$5
    test_message=$6
    if [[ "$test_status" == "PASSED" ]]; then
        print_success "Test $test_id: $test_name - $test_status"
    else
        if [[ "$test_level" == "Critical" ]]; then
            print_error "Test $test_id: $test_name - $test_status $test_level $test_description $test_message"
            exit 1
        elif [[ "$test_level" == "Warning" ]]; then
            print_error "Test $test_id: $test_name - $test_status $test_level $test_description $test_message"
        elif [[ "$test_level" == "Minor" ]]; then
            print_error "Test $test_id: $test_name - $test_status $test_message"
        fi
    fi

}
