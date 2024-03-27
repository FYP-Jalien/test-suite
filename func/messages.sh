#!/bin/bash

success_color="\e[32m"     # green
error_color="\e[31m"       # red
warning_color='\033[1;33m' # yellow
reset_color="\e[0m"        # reset

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
    if [[ "$test_level" == "Critical" ]]; then
        critical_count=$((critical_count + 1))
    elif [[ "$test_level" == "Warning" ]]; then
        warning_count=$((warning_count + 1))
    elif [[ "$test_level" == "Minor" ]]; then
        minor_count=$((minor_count + 1))
    fi
    if [[ "$test_status" != "PASSED" ]]; then
        if [[ "$test_level" == "Critical" ]]; then
            critical_fail=$((critical_fail + 1))
            print_error "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
            exit 1
        elif [[ "$test_level" == "Warning" ]]; then
            warning_fail=$((warning_fail + 1))
            print_error "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
        elif [[ "$test_level" == "Minor" ]]; then
            minor_fail=$((minor_fail + 1))
            print_error "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
        fi
    else
        print_success "$test_id" "$test_name" "$test_status" "$test_level" "$test_message" "$test_description"
    fi
}

function print_test_summary() {
    echo -e "Test Summary:"
    echo -e "-----------------------------"
    echo -e "Critical: ${error_color}$critical_count${reset_color} (${error_color}$critical_fail Failed${reset_color}, ${success_color}$critical_success Passed${reset_color})"
    echo -e "Warning: ${warning_color}$warning_count${reset_color} (${warning_color}$warning_fail Failed${reset_color}, ${success_color}$warning_success Passed${reset_color})"
    echo -e "Minor: ${reset_color}$minor_count${reset_color} (${reset_color}$minor_fail Failed${reset_color}, ${success_color}$minor_success Passed${reset_color})"
    echo -e "-----------------------------"
}
