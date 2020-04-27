#! /bin/bash

if ! [[ -x my-look ]]; then
    echo "my-look executable does not exist"
    exit 1
fi

../../tester/run-tests.sh $*


