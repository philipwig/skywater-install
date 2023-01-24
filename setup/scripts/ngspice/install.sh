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
	bison \
	flex \
	libx11-dev \
	libx11-6 \
	libxaw7-dev \
	autoconf \
	automake \
	libtool \
	tcl \
	tcl-dev \
	tk \
	tk-dev \
	blt \
	blt-dev \
	libfftw3-3 \
	libfftw3-dev \
    libreadline-dev


##################################################
# Download, compile and install ngspice
##################################################

git clone $2 $1/ngspice
cd $1/ngspice

git fetch
git checkout $3

# Run twice because sometimes it doesn't work
./autogen.sh
./autogen.sh

./configure --disable-debug --enable-openmp --with-x --with-readline=yes  --enable-xspice --with-fftw3=yes

make -j$(nproc)
sudo make install
