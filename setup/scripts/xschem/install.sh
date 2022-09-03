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
	libx11-6 \
	libx11-dev \
	libxrender1 \
	libxrender-dev \
	libxcb1 \
	libx11-xcb-dev \
	libcairo2 \
	libcairo2-dev \
	tcl \
	tcl-dev \
	tk \
	tk-dev \
	flex \
	bison \
	libxpm4 \
	libxpm-dev \
	gawk \
	xterm

##################################################
# Download, compile and install xschem
##################################################

git clone $2 $1/xschem
cd $1/xschem
git checkout $3

./configure

make -j$(nproc)
sudo make install

echo "alias xschem='xschem --rcfile /usr/local/share/pdk/sky130A/libs.tech/xschem/xschemrc'" >> ~/.bashrc
