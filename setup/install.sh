#!/bin/bash

# miniconda install directory
INSTALL_DIR = ~/tools

# Wait for cloud-init setup to finish
cloud-init status --wait

# Update
sudo apt-get update -y

# Install essential packages for every image
sudo apt-get install -y \
    build-essential \
    autoconf \
    automake \
    git \
    make \
    wget
    # curl \
    # csh \
    # tcl \
    # tk \
    # libreadline-dev \
    # flex \
    # bison \
    # libx11-6 \
    # libcairo2 \
    # libfftw3-3 \
    # libxpm4 \
    # libxaw7 \
    # libglu1-mesa

# Install miniconda
mkdir -p $INSTALL_DIR/miniconda3

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $INSTALL_DIR/miniconda3/miniconda.sh

chmod +x $INSTALL_DIR/miniconda3/miniconda.sh

$INSTALL_DIR/miniconda3/miniconda.sh -b -u -p $INSTALL_DIR/miniconda3

rm -rf $INSTALL_DIR/miniconda3/miniconda.sh
$INSTALL_DIR/miniconda3/bin/conda init bash

source ~/.bashrc

$INSTALL_DIR/miniconda3/bin/conda update conda -y
$INSTALL_DIR/miniconda3/bin/conda env create --file /remote/setup/environment.yaml

# Set skywater as default conda env
echo "source activate skywater" >> ~/.bashrc