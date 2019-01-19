#!/bin/bash
# set up cmake
wget --no-check-certificate https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz
tar -xvf cmake-3.12.0-Linux-x86_64.tar.gz
mv cmake-3.12.0-Linux-x86_64 cmake-install
PATH=$(pwd)/cmake-install:$(pwd)/cmake-install/bin:$PATH
# check cmake version to be 3.12
cmake --version

# considering python3 is installed
# htslib dependencies
sudo apt-get install python3-dev gcc g++ make autoconf python3-pip libcurl4-openssl-dev
sudo apt-get install autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev
python3 -m pip install h5py graphviz pandas

# install the proper version of pytorch from https://pytorch.org/


git clone https://github.com/kishwarshafin/friday.git
cd friday
./build.sh
