#!/bin/bash

##################################################
# $1 = clone dir
# $2 = git repo url
# $3 = git repo commit
##################################################

##################################################
# Install required packages
##################################################

sudo apt-get update -y

sudo apt-get install -y --no-install-recommends \
    m4 \
    tcsh \
    csh \
    libx11-dev \
    tcl-dev \
    tk-dev \
    libcairo2-dev \
    mesa-common-dev \
    libglu1-mesa-dev

##################################################
# Download, compile and install magic
##################################################

git clone $2 $1/magic
cd $1/magic

git fetch
git checkout $3

./configure

make -j$(nproc)
sudo make install

# Add alias to ~/.bashrc with magicrc config
echo "alias magic='magic -d XR -rcfile /usr/local/share/pdk/sky130A/libs.tech/magic/sky130A.magicrc'" >> ~/.bashrc
