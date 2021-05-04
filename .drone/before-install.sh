#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

if [ "$DRONE_JOB_UUID" = "356a192b79" ] ; then
    pip install --user https://github.com/codecov/codecov-python/archive/master.zip
    wget http://downloads.sourceforge.net/ltp/lcov-1.14.tar.gz
    tar -xvf lcov-1.14.tar.gz
    cd lcov-1.14
    make install && cd ..
fi
if [ "$DRONE_JOB_UUID" = "c1dfd96eea" ] ; then
    export PATH="$PWD/llvm-$LLVM_VERSION/bin:$PATH"

fi
if [ "$DRONE_JOB_UUID" = "902ba3cda1" ] ; then
    export OPENSSL_ROOT=$(brew --prefix openssl)
fi

