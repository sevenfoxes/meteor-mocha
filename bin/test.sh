#!/bin/bash -x

cd $TRAVIS_BUILD_DIR
spacejam test-packages ./
EXIT_STATUS="$?"

cd "$TRAVIS_BUILD_DIR/meteor/test-app"
TEST_FILE="$TRAVIS_BUILD_DIR/meteor/tests/test-app.html"
spacejam test --phantomjs-script "$TRAVIS_BUILD_DIR/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-app"
TEST_FILE="$TRAVIS_BUILD_DIR/meteor/tests/test-app-mirror.html"
MOCHA_RUN_ORDER='serial'
spacejam test --phantomjs-script "$TRAVIS_BUILD_DIR/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi


cd "$TRAVIS_BUILD_DIR/meteor/test-app"
TEST_FILE="$TRAVIS_BUILD_DIR/meteor/tests/test-app-full.html"
MOCHA_RUN_ORDER='parallel'
spacejam test --full-app --phantomjs-script "$TRAVIS_BUILD_DIR/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-app"
TEST_FILE="$TRAVIS_BUILD_DIR/meteor/tests/test-app-full-mirror.html"
MOCHA_RUN_ORDER='serial'
spacejam test --full-app --phantomjs-script "$TRAVIS_BUILD_DIR/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-package"
TEST_FILE="$TRAVIS_BUILD_DIR/meteor/tests/test-package.html"
MOCHA_RUN_ORDER='parallel'
spacejam test-packages --phantomjs-script "$TRAVIS_BUILD_DIR/meteor/tests/test-app-tests.js" --driver-package practicalmeteor:mocha ./
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

cd "$TRAVIS_BUILD_DIR/meteor/test-package"
TEST_FILE="$TRAVIS_BUILD_DIR/meteor/tests/test-package-mirror.html"
MOCHA_RUN_ORDER='serial'
spacejam test-packages --phantomjs-script "$TRAVIS_BUILD_DIR/meteor/tests/test-app-tests.js" --driver-package practicalmeteor:mocha ./
LAST_EXIT_STATUS="$?"
if [ "$LAST_EXIT_STATUS" -ne "0" ]
    then
    EXIT_STATUS="$LAST_EXIT_STATUS"
fi

exit $EXIT_STATUS