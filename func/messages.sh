#!/bin/bash

success_color="\e[32m"     # green
error_color="\e[31m"       # red
warning_color='\033[1;33m' # yellow
reset_color="\e[0m"        # reset

add_to_csv=false
errorOnExit=true

# Function to print text with fixed width and multiline support
function print_with_fixed_width() {
    text="$1"
    width=$2
    printf "%-${width}s" "$text" | fold -w "$width" -s
}

function print_success() {
    if [ "$add_to_csv" = true ]; then
        echo "\"$1\",\"$2\",\"$3\",\"$4\",\"$5\",\"$6\"" >>"$OUT_CSV_PATH"
    fi
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
    level=$4
    if [ "$add_to_csv" = true ]; then
        echo "\"$1\",\"$2\",\"$3\",\"$4\",\"$5\",\"$6\"" >>"$OUT_CSV_PATH"
    fi
    if [[ "$level" == "Critical" ]]; then
        color=$error_color
    elif [[ "$level" == "Warning" ]]; then
        color=$warning_color
    elif [[ "$level" == "Minor" ]]; then
        color=$reset_color
    fi
    printf "| ${color}"
    print_with_fixed_width "$1" 3
    printf "${reset_color} | ${color}"
    print_with_fixed_width "$2" 70
    printf "${reset_color} | ${color}"
    print_with_fixed_width "$3" 6
    printf "${reset_color} | ${color}"
    print_with_fixed_width "$4" 8
    printf "${reset_color} | ${color}"
    content_width=$(($(printf "%s" "$5" | wc -c) + 1))
    min_width=100
    if [[ $content_width -lt $min_width ]]; then
        content_width=$min_width
    fi
    printf "${color}"
    print_with_fixed_width "$5" $content_width
    printf "${reset_color} |\n"
}

function print_test_header() {
    if [ $add_to_csv = true ]; then
        echo "Id,Name,Status,Level,Message,Description" >>"$OUT_CSV_PATH"
    fi
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
            print_test_summary
            if [ $errorOnExit = true ]; then
                exit 1
            else
                exit 0
            fi
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
    critical_success=$((critical_count - critical_fail))
    warning_success=$((warning_count - warning_fail))
    minor_success=$((minor_count - minor_fail))
    if [ $add_to_csv = true ]; then
        echo -e "Level, Count, Failed, Passed" >>"$SUMMARY_CSV_PATH"
        echo -e "Critical,$critical_count,$critical_fail,$critical_success" >>"$SUMMARY_CSV_PATH"
        echo -e "Warning,$warning_count,$warning_fail,$warning_success" >>"$SUMMARY_CSV_PATH"
        echo -e "Minor,$minor_count,$minor_fail,$minor_success" >>"$SUMMARY_CSV_PATH"
    fi
    summary_error_color=$error_color
    summary_warning_color=$warning_color
    if [[ $critical_fail -eq 0 ]]; then
        summary_error_color=$success_color
    fi
    if [[ $warning_fail -eq 0 ]]; then
        summary_warning_color=$success_color
    fi
    echo -e "Test Summary:"
    echo -e "-----------------------------"
    echo -e "Critical: $critical_count (${summary_error_color}$critical_fail Failed${reset_color}, ${success_color}$critical_success Passed${reset_color})"
    echo -e "Warning: $warning_count (${summary_warning_color}$warning_fail Failed${reset_color}, ${success_color}$warning_success Passed${reset_color})"
    echo -e "Minor: ${reset_color}$minor_count${reset_color} (${reset_color}$minor_fail Failed${reset_color}, ${success_color}$minor_success Passed${reset_color})"
    echo -e "-----------------------------"
}
