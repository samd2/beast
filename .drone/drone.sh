#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

set -e

export DRONE_BUILD_DIR=$(pwd)
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export REPO_NAME=$DRONE_REPO
export USER=$(whoami)
export CC=${CC:-gcc}
export PATH=~/.local/bin:/usr/local/bin:$PATH
export TRAVIS_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export TRAVIS_EVENT_TYPE=$DRONE_BUILD_EVENT

common_install () {
  git clone https://github.com/boostorg/boost-ci.git boost-ci-cloned --depth 1
  cp -prf boost-ci-cloned/ci .
  rm -rf boost-ci-cloned

  if [ "$TRAVIS_OS_NAME" == "osx" ]; then
    unset -f cd
    echo "macos - set up homebrew openssl"
    export OPENSSL_ROOT=/usr/local/opt/openssl 

cat > ~/user-config.jam <<EOF
import os ;
local OPENSSL_ROOT = [ os.environ OPENSSL_ROOT ] ;
project
  : requirements
    <include>/usr/local/opt/openssl/include
    <variant>debug:<library-path>/usr/local/opt/openssl/lib
    <target-os>windows<variant>debug:<library-path>/usr/local/opt/openssl/debug/lib
    <variant>release:<library-path>/usr/local/opt/openssl/lib
  ;
EOF

  fi

  export SELF=`basename $REPO_NAME`
  export BOOST_CI_TARGET_BRANCH="$TRAVIS_BRANCH"
  export BOOST_CI_SRC_FOLDER=$(pwd)

  . ./ci/common_install.sh
}

if [ "$DRONE_JOB_BUILDTYPE" == "boost" ]; then

echo '==================================> INSTALL'

common_install

echo '==================================> SCRIPT'

. $BOOST_ROOT/libs/$SELF/ci/build.sh

elif [ "$DRONE_JOB_BUILDTYPE" == "codecov" ]; then

echo '==================================> INSTALL'

common_install

echo '==================================> SCRIPT'

cd $BOOST_ROOT/libs/$SELF
ci/travis/codecov.sh

elif [ "$DRONE_JOB_BUILDTYPE" == "valgrind" ]; then

echo '==================================> INSTALL'

common_install

echo '==================================> SCRIPT'

cd $BOOST_ROOT/libs/$SELF
ci/travis/valgrind.sh

elif [ "$DRONE_JOB_BUILDTYPE" == "valgrind_original" ]; then

echo '==================================> INSTALL'

export SELF=`basename $REPO_NAME`

BOOST_BRANCH=develop
if [ "$DRONE_BRANCH" == "master" ]; then
  BOOST_BRANCH=master 
fi
echo BOOST_BRANCH: $BOOST_BRANCH
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
cp -r $DRONE_BUILD_DIR/* libs/$SELF
git submodule update --init tools/boostdep
python tools/boostdep/depinst/depinst.py --git_args "--jobs 3" $SELF
./bootstrap.sh
./b2 -d0 headers

echo '==================================> SCRIPT'

cd $BOOST_ROOT
libs/beast/tools/retry.sh libs/beast/tools/build-and-test.sh

elif [ "$DRONE_JOB_BUILDTYPE" == "coverity" ]; then

echo '==================================> INSTALL'

common_install

echo '==================================> SCRIPT'

if  [ -n "${COVERITY_SCAN_NOTIFICATION_EMAIL}" -a \( "$TRAVIS_BRANCH" = "develop" -o "$TRAVIS_BRANCH" = "master" \) -a \( "$DRONE_BUILD_EVENT" = "push" -o "$DRONE_BUILD_EVENT" = "cron" \) ] ; then
cd $BOOST_ROOT/libs/$SELF
ci/travis/coverity.sh
fi

fi
