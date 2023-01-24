#!/bin/bash

##################################################
# $1 = install_dir
# $2 = git repo url
# $3 = git repo commit
##################################################

##################################################
# Download, compile and install skywater_pdk
##################################################

git clone $2 $1/skywater-pdk

cd $1/skywater-pdk

git fetch

git checkout main && \
    git checkout -qf $3
    git submodule update --init libraries/sky130_fd_sc_hd/latest && \
    git submodule update --init libraries/sky130_fd_io/latest && \
    git submodule update --init libraries/sky130_fd_sc_hvl/latest && \
    git submodule update --init libraries/sky130_fd_pr/latest && \
    git submodule update --init libraries/sky130_fd_pr_reram/latest && \
    git submodule update

    # git submodule update --init libraries/sky130_fd_sc_lp/latest  && \
    # git submodule update --init libraries/sky130_fd_sc_hs/latest  && \
    # git submodule update --init libraries/sky130_fd_sc_ms/latest  && \
    # git submodule update --init libraries/sky130_fd_sc_ls/latest  && \
    # git submodule update --init libraries/sky130_fd_sc_hdll/latest && \

# Expect a large download! ~7GB at time of writing.
# SUBMODULE_VERSION=latest make submodules -j3 || make submodules -j1

# Regenerate liberty files
make timing -j$(nproc)
