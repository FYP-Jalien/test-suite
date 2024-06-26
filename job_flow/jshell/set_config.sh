#!/bin/bash

id=$((id + 1))
name="Check host config exists in the SHARED_COLUME"
level="Critical"
description="$SHARED_VOLUME_PATH/config/ComputingElement/host/ should exist"
# shellcheck disable=SC1090
if ! [ -d "$SHARED_VOLUME_PATH/config/ComputingElement/host" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$SHARED_VOLUME_PATH/config/ComputingElement/host does not exits"
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$SHARED_VOLUME_PATH/config/ComputingElement/host exits"
fi

if [ -d "$HOME/.alien/config" ]; then
    if [ "$(ls -A "$HOME/.alien/config" | wc -l)" -gt 0 ]; then
        rm "$HOME"/.alien/config/*
    fi
else
    mkdir -p "$HOME/.alien/config"
fi
cp -a "$SHARED_VOLUME_PATH/config/ComputingElement/host/." "$HOME/.alien/config"
id=$((id + 1))
name="Check home .alien config is created"
level="Critical"
description="$HOME/.alien/config/ should be created"
# shellcheck disable=SC1090
if [ ! -d "$HOME/.alien/config" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$HOME/.alien/config does not exits"
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$HOME/.alien/config exits"
fi

if [ -d "$HOME/.globus" ]; then
    if [ "$(ls -A "$HOME/.globus" | wc -l)" -gt 0 ]; then
        rm "$HOME"/.globus/*
    fi
else
    mkdir -p "$HOME/.globus"
fi
cp -a "$SHARED_VOLUME_PATH/globus/user/." "$HOME/.globus/"
id=$((id + 1))
name="Check home .globus is created"
level="Critical"
description="$HOME/.globus/ should be created"
# shellcheck disable=SC1090
if [ ! -d "$HOME/.globus" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$HOME/.globus does not exits"
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$HOME/.globus exits"
fi
