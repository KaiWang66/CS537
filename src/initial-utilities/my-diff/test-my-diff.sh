#! /bin/bash

if ! [[ -x my-diff ]]; then
    echo "*** ERROR: my-diff executable does not exist"
    exit 0
fi

../../tester/run-tests.sh $*


