#!/bin/bash

source ../func/messages.sh

alienv_path="./alma-alienv"
sample_path="./sample_test.jdl"
testscript_path="./testscript_test.sh"
shared_volume_env="/home/jananga/FYP/SHARED_VOLUME/env_setup.sh"

# Check if the alienv script exists
if [ ! -f "$alienv_path" ]; then
    print_error "$alienv_path does not exist."
    exit 1
fi
# Check if the alienv script is executable
if [ ! -x "$alienv_path" ]; then
    print_error "$alienv_path is not executable."
    exit 1
fi
# Check if the sample jdl exists
if [ ! -f "$sample_path" ]; then
    print_error "$sample_path does not exist."
    exit 1
fi
# Check if the testscript exists
if [ ! -f "$testscript_path" ]; then
    print_error "$testscript_path does not exist."
    exit 1
fi
# Check if the shared volume env exists
if [ ! -f "$shared_volume_env" ]; then
    print_error "$shared_volume_env does not exist."
    exit 1
fi

print_success "All files and directories exist."


source $alienv_path setenv xjalienfs
if [ $? -ne 0 ] ; then
    print_error "Could not source  $alienv_path."
    exit 1
fi
source $shared_volume_env
if [ $? -ne 0 ] ; then
    print_error "Could not source $shared_volume_env"
    exit 1
fi
alien.py cp file://$sample_path alien://sample.jdl
if [ $? -ne 0 ] ; then
    print_error "Failed to copy $sample_path to alien://sample.jdl"
    exit 1
fi
alien.py cp file://$testscript_path alien://testscript.sh
if [ $? -ne 0 ] ; then
    print_error "Failed to copy $testscript_path to alien://  "
    exit 1
fi

print_success "Copy jobs are done."

result="$(alien.py ls)"

if [ $? -ne 0 ] ; then
    print_error "Could not ls in alien.py"
    exit 1
fi

if !  echo "$result" | grep -q "sample.jdl"  ; then
    print_error "sample.jdl does not exist in alien.py ls"
    exit 1
fi

if !  echo "$result" | grep -q "testscript.sh"  ; then
    print_error "testscript.sh does not exist in alien.py ls"
    exit 1
fi

print_success "Copy jobs are verified."

job_result=$(alien.py submit "./sample.jdl")
if [ $? -ne 0 ] ; then
    print_error "Failed to submit sample.jdl"
    exit 1
fi

if echo "$job_result" | grep -q "Submitting /localhost/localdomain/user/j/jalien/sample.jdl" && echo "$job_result" | grep -q "^Your new job ID is [0-9]\+$"; then
    job_id=$(echo "$job_result" | awk '/Your new job ID is/ {print $NF}')
    print_success "Job submitted successfully. Job ID: $job_id"
else
    print_error "Job submission failed or output format is not as expected."
    exit 1
fi

function get_job_state(){
    result=$(alien.py ps)
    job_row=$(grep "jalien $1" <<< "$result")
    if [ -z "$job_row" ]; then
        exit 1
    fi
    echo "$job_row" | awk '{split($0, a); print a[NF-1]}'
}

state=$(get_job_state "$job_id")
if [ $? -ne 0 ] ; then
    print_error "Job ID $1 either not found or has a different format."
    exit 1
fi
if [[ -n $state ]]; then
    print_success "$job_id is in $state State."
else
    print_error "invalid state for $job_id."
    exit 1
fi

if [[ $state == "I" ]]; then
    sleep 45
    state=$(get_job_state "$job_id")
    if [ $? -ne 0 ] ; then
        print_error "Job ID $1 either not found or has a different format."
        exit 1
    fi
    if [[ -n $state ]]; then
        if [[ $state == "I" ]]; then
            print_error "$job_id still is I state. Probably Optimiser is not running."
            exit 1
        else
            print_success "$job_id is in $state State."
        fi
    else
        print_error "invalid state for $job_id."
        exit 1
    fi
fi


