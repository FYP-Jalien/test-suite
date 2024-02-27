#!/bin/bash

id=$((id + 1))
name="Copy Sample JDL to SE check"
level="Critical"
description="Sample JDL should be copied to SE before submitting the job"
if ! alien.py cp file://"$SAMPLE_JDL_PATH" alien://sample.jdl >/dev/null; then
    if alien.py ls | grep -q "sample.jdl"; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "sample.jdl exists"
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Failed to copy $SAMPLE_JDL_PATH to alien://"
    fi
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Sample JDL copied to alien://"
fi

id=$((id + 1))
name="Copy testscript.sh to SE check"
level="Critical"
description="Sample JDL should be copied to SE before submitting the job"
if ! alien.py cp file://$"$TESTSCRIPT_PATH" alien://testscript.sh >/dev/null; then
    if alien.py ls | grep -q "testscript.sh"; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "testscript.sh exists"
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Failed to copy $TESTSCRIPT_PATH to alien://"
    fi
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "testscript.sh copied to alien://"
fi
