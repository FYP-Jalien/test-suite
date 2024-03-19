#!/bin/bash

success_color="\e[32m" # green
error_color="\e[31m"   # red
reset_color="\e[0m"    # reset

# Function to print text with fixed width and multiline support
function print_with_fixed_width() {
    text="$1"
    width=$2
    printf "%-${width}s" "$text" | fold -w "$width" -s
}

function print_success() {
    printf "| ${success_color}"
    print_with_fixed_width "$1" 3
    printf "${reset_color} | ${success_color}"
    print_with_fixed_width "$2" 70
    printf "${reset_color} | ${success_color}"
    print_with_fixed_width "$3" 6
    printf "${reset_color} | ${success_color}"
    print_with_fixed_width "$4" 8
    printf "${reset_color} |\n"
}

function print_error() {
    printf "| ${error_color}"
    print_with_fixed_width "$1" 3
    printf "${reset_color} | ${error_color}"
    print_with_fixed_width "$2" 70
    printf "${reset_color} | ${error_color}"
    print_with_fixed_width "$3" 6
    printf "${reset_color} | ${error_color}"
    print_with_fixed_width "$4" 8
    printf "${reset_color} | ${error_color}"
    content_width=$(($(printf "%s" "$5" | wc -c) + 1))
    min_width=100
    if [[ $content_width -lt $min_width ]]; then
        content_width=$min_width
    fi
    printf "${error_color}"
    print_with_fixed_width "$5" $content_width
    printf "${reset_color} |\n"
}

function print_test_header() {
    printf "Running all tests\n"
    printf "| "
    print_with_fixed_width "Id" 3
    printf " | "
    print_with_fixed_width "Name" 70
    printf " | "
    print_with_fixed_width "Status" 6
    printf " | "
    print_with_fixed_width "Level" 8
    printf " | "
    print_with_fixed_width "Message" 100
    printf " |\n"
}
function print_full_test() {
    test_id=$1
    test_name=$2
    test_status=$3
    test_description=$4
    test_level=$5
    test_message=$6

    if [[ "$test_status" != "PASSED" ]]; then
        if [[ "$test_level" == "Critical" ]]; then
            print_error "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
            exit 1
        elif [[ "$test_level" == "Warning" ]]; then
            print_error "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
        elif [[ "$test_level" == "Minor" ]]; then
            print_error "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
        fi
    else
        print_success "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
    fi
}
