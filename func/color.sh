#!/bin/bash

function remove_color() {
    echo "$1" | sed -r "s/\x1B\[[0-9;]*[mK]//g"
}
