cp -r ~cs537-1/tests/p1/initial-utilities ./
cp -r ~cs537-1/tests/p1/tester ./
chmod +x tester/run-tests.sh

if ! test -f ./my-look.c; then
    echo "my-look.c does not exist"
else
    echo "start testing for my-look utility..."
    cd initial-utilities/my-look/
    gcc -o my-look ../../my-look.c -Wall -Werror
    chmod +x ./test-my-look.sh $*
    ./test-my-look.sh
    cd ../../
fi

if ! test -f ./across.c; then
    echo "across.c does not exist"
else
    echo "start testing for across utility..."
    cd initial-utilities/across/
    gcc -o across ../../across.c -Wall -Werror
    chmod +x ./test-across.sh $*
    ./test-across.sh
    cd ../../
fi

if ! test -f ./my-diff.c; then
    echo "my-diff.c does not exist"
else
    echo "start testing for my-diff utility..."
    cd initial-utilities/my-diff/
    gcc -o my-diff ../../my-diff.c -Wall -Werror
    chmod +x ./test-my-diff.sh $*
    ./test-my-diff.sh
    cd ../../
fi

rm -rf tester/

