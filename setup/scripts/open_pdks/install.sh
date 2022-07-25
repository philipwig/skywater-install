#!/bin/bash

##################################################
# $1 = clone dir
# $2 = git repo url
# $3 = git repo commit
##################################################

##################################################
# Download, compile and install open_pdks
##################################################

# magic_version=$(ls $1/magic/ )
# export PATH=$PATH:$1/magic/bin/

cd $PDK_ROOT 
git clone $2 $1/open_pdks
cd $1/open_pdks
git checkout -qf $3

./configure --enable-sky130-pdk=$1/skywater-pdk  \
            --enable-alpha-sky130 \
            --enable-xschem-sky130 \
            --enable-sram-sky130 \
            --with-sky130-variants=all    

make -j$(nproc)

sudo make install

make distclean

echo "export PDK_ROOT='/usr/local/share/pdk'" >> ~/.bashrc