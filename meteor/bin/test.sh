#!/bin/bash -x

export PHANTHOMJS_SCRIPT="$TRAVIS_BUILD_DIR/meteor/tests/phantomjs-script-tests.js"
export TEST_FILE="$TRAVIS_BUILD_DIR/meteor/tests/tests.html"
export SPACEJAM_COMMAND="--phantomjs-script $PHANTHOMJS_SCRIPT  --driver-package practicalmeteor:mocha"

cd $TRAVIS_BUILD_DIR
spacejam test-packages ./
EXIT_STATUS="$?"

cd "$TRAVIS_BUILD_DIR/meteor/test-app"
spacejam test $(echo $SPACEJAM_COMMAND)
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    echo "Test failed printing compare file."
    cat "$TEST_FILE.compare"
    echo "End compare file."
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-app"
MOCHA_RUN_ORDER='serial'
spacejam test $(echo $SPACEJAM_COMMAND)
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    echo "Test failed printing compare file."
    cat "$TEST_FILE.compare"
    echo "End compare file."
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi


cd "$TRAVIS_BUILD_DIR/meteor/test-app"
MOCHA_RUN_ORDER='parallel'
spacejam test --full-app $(echo $SPACEJAM_COMMAND)
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    echo "Test failed printing compare file."
    cat "$TEST_FILE.compare"
    echo "End compare file."
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-app"
MOCHA_RUN_ORDER='serial'
spacejam test --full-app $(echo $SPACEJAM_COMMAND)
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    echo "Test failed printing compare file."
    cat "$TEST_FILE.compare"
    echo "End compare file."
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-package"
MOCHA_RUN_ORDER='parallel'
spacejam test-packages $(echo $SPACEJAM_COMMAND) ./
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    echo "Test failed printing compare file."
    cat "$TEST_FILE.compare"
    echo "End compare file."
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-package"
MOCHA_RUN_ORDER='serial'
spacejam test-packages $(echo $SPACEJAM_COMMAND) ./
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    echo "Test failed printing compare file."
    cat "$TEST_FILE.compare"
    echo "End compare file."
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

exit $EXIT_STATUS