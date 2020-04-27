#! /bin/bash

if ! [[ -x my-diff ]]; then
    echo "my-diff executable does not exist"
    exit 1
fi

../../tester/run-tests.sh $*


