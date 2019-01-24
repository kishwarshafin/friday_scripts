#!/bin/bash
### DeepVariant evaluation
### FROM HERE ### https://github.com/google/deepvariant/blob/master/docs/deepvariant-quick-start.md
# DOWNLOAD THE MODEL
BIN_VERSION="0.7.2"
MODEL_VERSION="0.7.2"


cd /data/users/common/dv_model/
MODEL_NAME="DeepVariant-inception_v3-${MODEL_VERSION}+data-wgs_standard"
MODEL_HTTP_DIR="https://storage.googleapis.com/deepvariant/models/DeepVariant/${MODEL_VERSION}/${MODEL_NAME}"
mkdir -p ${MODEL_NAME}
wget -P ${MODEL_NAME} ${MODEL_HTTP_DIR}/model.ckpt.data-00000-of-00001
wget -P ${MODEL_NAME} ${MODEL_HTTP_DIR}/model.ckpt.index
wget -P ${MODEL_NAME} ${MODEL_HTTP_DIR}/model.ckpt.meta

sudo apt -y update
sudo apt-get -y install docker.io
sudo docker pull gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}"
sudo docker pull gcr.io/deepvariant-docker/deepvariant_gpu:"${BIN_VERSION}"
sudo apt-get -y install parallel

# GPU SETUP
#(1) Install nvidia driver: https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver
  sudo apt-get -y update
  echo "Installing CUDA..."
  CUDA_DEB="cuda-repo-ubuntu1604_9.0.176-1_amd64.deb"
  curl -O http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/${CUDA_DEB}
  sudo -H apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
  sudo -H dpkg -i ./cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
  sudo -H apt-get update
  sudo -H apt-get -y install cuda-9-0

#(2) Install Docker CE: https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce
  sudo apt-get -y update
  sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-key fingerprint 0EBFCD88
  sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  sudo apt-get -y update
  sudo apt-get -y install docker-ce

#(3) Install nvidia-docker: https://github.com/NVIDIA/nvidia-docker#ubuntu-140416041804-debian-jessiestretch
# If you have nvidia-docker 1.0 installed: we need to remove it and all existing GPU containers
docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
sudo apt-get purge -y nvidia-docker

# Add the package repositories
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get -y update

# Install nvidia-docker2 and reload the Docker daemon configuration
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd

# Test nvidia-smi with the latest official CUDA image (one of these two should work)
sudo docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
sudo docker run --runtime=nvidia --rm nvidia/cuda:10.0-base nvidia-smi
