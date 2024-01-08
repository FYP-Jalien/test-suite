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
    echo -e "$error_color$1$reser_color"
}