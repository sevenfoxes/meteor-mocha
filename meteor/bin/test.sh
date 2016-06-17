#!/bin/bash -x

cd $REPO_HOME
#spacejam test-packages ./
EXIT_STATUS="$?"
export TEST_FILE="$REPO_HOME/meteor/tests/test-app.html"
function createCompareFile {

  if [ "$1" -ne "0" ]
      then
      if [ -n "${TRAVIS_BUILD_DIR}" ]
        then
        echo "Test failed printing compare file."
#        cat "$TEST_FILE.compare"
        echo "End compare file."
      else
        cat "$TEST_FILE.compare" >> "$(dirname $TEST_FILE)/$2.compare.html"
      fi
      rm -rf "$TEST_FILE.compare"
      EXIT_STATUS="$1"
  fi
  return ${EXIT_STATUS}
}

export TEST_FILE="$REPO_HOME/meteor/tests/test-app.html"

cd "$REPO_HOME/meteor/test-app"
spacejam test --phantomjs-script "$REPO_HOME/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
createCompareFile "$?" "test-app-parallel"
EXIT_STATUS="$?"


cd "$REPO_HOME/meteor/test-app"
MOCHA_RUN_ORDER='serial'
spacejam test --phantomjs-script "$REPO_HOME/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
createCompareFile "$?" "test-app-serial"
EXIT_STATUS="$?"


cd "$REPO_HOME/meteor/test-app"
MOCHA_RUN_ORDER='parallel'
spacejam test --full-app --phantomjs-script "$REPO_HOME/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
createCompareFile "$?" "test-full-app-parallel"
EXIT_STATUS="$?"


cd "$REPO_HOME/meteor/test-app"
MOCHA_RUN_ORDER='serial'
spacejam test --full-app --phantomjs-script "$REPO_HOME/meteor/tests/test-app-tests.js"  --driver-package practicalmeteor:mocha
createCompareFile "$?" "test-full-app-serial"
EXIT_STATUS="$?"


export TEST_FILE="$REPO_HOME/meteor/tests/test-package.html"

cd "$REPO_HOME/meteor/test-package"
MOCHA_RUN_ORDER='parallel'
spacejam test-packages --phantomjs-script "$REPO_HOME/meteor/tests/test-app-tests.js" --driver-package practicalmeteor:mocha ./
createCompareFile "$?" "test-package-parallel"
EXIT_STATUS="$?"


cd "$REPO_HOME/meteor/test-package"
MOCHA_RUN_ORDER='serial'
spacejam test-packages --phantomjs-script "$REPO_HOME/meteor/tests/test-app-tests.js" --driver-package practicalmeteor:mocha ./
createCompareFile "$?" "test-app-parallel"
EXIT_STATUS="$?"

exit $EXIT_STATUS