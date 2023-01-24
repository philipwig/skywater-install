#!/bin/bash

##################################################
# $1 = clone dir
# $2 = git repo url
# $3 = git repo commit
##################################################

##################################################
# Download, compile and install netgen
##################################################

git clone $2 $1/netgen

cd $1/netgen

git fetch
git checkout $3

./configure

make -j$(nproc)
sudo make install
make clean
