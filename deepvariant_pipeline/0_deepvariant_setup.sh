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
sudo apt-get -y install parallel
