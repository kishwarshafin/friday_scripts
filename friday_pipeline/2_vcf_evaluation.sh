#!/bin/bash

# HAP.PY
sudo docker pull pkrusche/hap.py
FINAL_OUTPUT=/data/users/kishwar/friday_outputs/vcf_output/pfda_friday_HG002_GRCh37.vcf.gz
TRUTH_VCF=/data/users/common/vcf/HG002_GRCh37.vcf.gz
CONFIDENT_BED=/data/users/common/bed/HG002_GRCh37.bed
HAPPY_OUTPUT=/data/users/kishwar/deepvariant_outputs/happy_output/pfda_hg002_grch37
mkdir -p ${HAPPY_OUTPUT}

time sudo docker run -it -v /data/:/data/ \
  pkrusche/hap.py /opt/hap.py/bin/hap.py \
  ${TRUTH_VCF} \
  ${FINAL_OUTPUT_VCF} \
  -f ${CONFIDENT_BED} \
  -r ${REF} \
  -o ${HAPPY_OUTPUT}/friday_hg002_grch37 \
  --engine=vcfeval \
  --threads=${N_SHARDS}
wait;
