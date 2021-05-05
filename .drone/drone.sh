#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

set -xe
export TRAVIS_BUILD_DIR=$(pwd)
export DRONE_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export TRAVIS_EVENT_TYPE=$DRONE_BUILD_EVENT
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export REPO_NAME=$DRONE_REPO
export USER=$(whoami)
export CC=${CC:-gcc}
export PATH=~/.local/bin:/usr/local/bin:$PATH

echo '==================================> BEFORE_INSTALL'

if [ "$VARIANT" = "beast_coverage" ] ; then
    pip install --user https://github.com/codecov/codecov-python/archive/master.zip
    wget http://downloads.sourceforge.net/ltp/lcov-1.14.tar.gz
    tar -xvf lcov-1.14.tar.gz
    cd lcov-1.14
    make install && cd ..
fi
if [ "$VARIANT" = "beast_ubasan" ] ; then
    export PATH="$PWD/llvm-$LLVM_VERSION/bin:$PATH"

fi
if [ "$TRAVIS_OS_NAME" = "osx" ] ; then
    export OPENSSL_ROOT=$(brew --prefix openssl)
fi

# -------------------------------------------------------------------

if [ "$DRONE_JOB_BUILDTYPE" == "boost" ]; then

echo '==================================> INSTALL'

cd ..
$TRAVIS_BUILD_DIR/tools/get-boost.sh $TRAVIS_BRANCH $TRAVIS_BUILD_DIR
cd boost-root
export PATH=$PATH:"`pwd`"
export BOOST_ROOT=$(pwd)
./bootstrap.sh
cp libs/beast/tools/user-config.jam ~/user-config.jam
echo "using $TOOLSET : : $COMPILER : $CXX_FLAGS ;" >> ~/user-config.jam

sudo updatedb
echo "Debug1"
locate libboost_context.so.1.77.0 || true
locate libboost_context.so || true

echo '==================================> SCRIPT'

cd ../boost-root
libs/beast/tools/retry.sh libs/beast/tools/build-and-test.sh

elif [ "$DRONE_JOB_BUILDTYPE" == "docs" ]; then

echo '==================================> INSTALL'

cd ..
mkdir tmp && cd tmp
git clone -b 'Release_1_8_15' --depth 1 https://github.com/doxygen/doxygen.git
cd doxygen
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Release
cd build
sudo make install
cd ../..
wget -O saxonhe.zip https://sourceforge.net/projects/saxon/files/Saxon-HE/9.9/SaxonHE9-9-1-4J.zip/download
unzip saxonhe.zip
sudo rm /usr/share/java/Saxon-HE.jar
sudo cp saxon9he.jar /usr/share/java/Saxon-HE.jar
cd ..
BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
git clone -b $BOOST_BRANCH https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init libs/context
git submodule update --init tools/boostbook
git submodule update --init tools/boostdep
git submodule update --init tools/docca
git submodule update --init tools/quickbook
cp -r $TRAVIS_BUILD_DIR/* libs/beast
python tools/boostdep/depinst/depinst.py ../tools/quickbook
./bootstrap.sh
./b2 headers

echo '==================================> SCRIPT'

echo "using doxygen ; using boostbook ; using saxonhe ;" > ~/user-config.jam
./b2 -j3 libs/beast/doc//boostrelease

fi
