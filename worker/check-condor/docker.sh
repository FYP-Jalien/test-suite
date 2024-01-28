#!/bin/bash
func_path="/host_func/"
source $func_path"messages.sh"

if condor_status | grep "slot"; then
    if condor_status | grep "Total Owner Claimed Unclaimed Matched Preempting Backfill  Drain"; then
        print_success "Condor is working"
    else
        print_err "Condor is not working"
    fi
else
    print_error "Condor is not working"
fi