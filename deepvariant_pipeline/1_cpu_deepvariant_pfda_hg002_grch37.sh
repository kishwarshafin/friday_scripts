#!/bin/bash
### DeepVariant evaluation
### FROM HERE ### https://github.com/google/deepvariant/blob/master/docs/deepvariant-quick-start.md
# RUN DEEPVARIANT
BIN_VERSION="0.7.2"
MODEL_VERSION="0.7.2"
OUTPUT_DIR=/data/users/kishwar/deepvariant_outputs/examples/pfda_HG002_grch37
VCF_OUTPUT_DIR=/data/users/kishwar/deepvariant_outputs/vcf_outputs
LOGDIR=/data/users/kishwar/deepvariant_outputs/logs
FINAL_OUTPUT_VCF=${VCF_OUTPUT_DIR}/pfda_HG002_GRCh37.vcf.gz

REF=/data/users/common/ref/GRCh37/human_g1k_v37.fasta
BAM=/data/users/common/bam/precision_fda/pfda_HG002_GRCh37.bam
MODEL=/data/users/common/dv_model/DeepVariant-inception_v3-0.7.2+data-wgs_standard/model.ckpt

mkdir -p ${OUTPUT_DIR}
mkdir -p ${VCF_OUTPUT_DIR}
mkdir -p ${LOGDIR}

N_SHARDS=32

sudo docker pull gcr.io/deepvariant-docker/deepvariant:${BIN_VERSION}
wait;
# create images
time seq 0 $((N_SHARDS-1)) | \
  parallel --eta --halt 2 --joblog ${LOGDIR}/log --res ${LOGDIR} \
  sudo docker run \
    -v /data/:/data/ \
    gcr.io/deepvariant-docker/deepvariant:${BIN_VERSION} \
    /opt/deepvariant/bin/make_examples \
    --mode calling \
    --ref ${REF} \
    --reads ${BAM} \
    --sample_name "NA24385" \
    --examples ${OUTPUT_DIR}/examples.tfrecord@${N_SHARDS}.gz \
    --task {}
wait;

CALL_VARIANTS_OUTPUT=${OUTPUT_DIR}/call_variants_output.tfrecord.gz
wait;

time sudo docker run \
  -v /data/:/data/ \
  gcr.io/deepvariant-docker/deepvariant:${BIN_VERSION} \
  /opt/deepvariant/bin/call_variants \
 --outfile ${CALL_VARIANTS_OUTPUT} \
 --examples ${OUTPUT_DIR}/examples.tfrecord@${N_SHARDS}.gz \
 --checkpoint ${MODEL}
wait;


time sudo docker run \
   -v /data/:/data/ \
   gcr.io/deepvariant-docker/deepvariant:${BIN_VERSION} \
   /opt/deepvariant/bin/postprocess_variants \
   --ref ${REF} \
   --infile ${CALL_VARIANTS_OUTPUT} \
   --outfile ${FINAL_OUTPUT_VCF}
wait;

# HAP.PY
sudo docker pull pkrusche/hap.py
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
  -o ${HAPPY_OUTPUT}/deepvariant_hg002_grch37 \
  --engine=vcfeval \
  --threads=${N_SHARDS}
wait;
