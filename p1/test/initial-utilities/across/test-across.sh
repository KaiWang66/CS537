#! /bin/bash

if ! [[ -x across ]]; then
    echo "across executable does not exist"
    exit 1
fi

../../tester/run-tests.sh $*


