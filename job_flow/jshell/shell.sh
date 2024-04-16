#!/bin/bash

set -e

"$JALIEN_PATH/jalien" login &
jbox_pid=$!
echo "Wait 30 seconds until JBox starts"
sleep 30

id=$((id + 1))
name="Verify JShell is working"
level="Critical"
description="pwd command should be working in JShell"
if [ "$("$JALIEN_PATH/jalien" -e pwd)" = "/localhost/localdomain/user/j/jalien/" ]; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "pwd is providing the expected output in JShell"
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "pwd is not providing /localhost/localdomain/user/j/jalien/ in JShell"
fi
