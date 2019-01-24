#!/bin/bash
### DeepVariant evaluation
### FROM HERE ### https://github.com/google/deepvariant/blob/master/docs/deepvariant-quick-start.md
# RUN DEEPVARIANT
BIN_VERSION="0.7.2"
MODEL_VERSION="0.7.2"
sudo docker pull gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}"

OUTPUT_DIR=/data/users/kishwar/deepvariant_outputs/examples/ccs_15kb_HG002_GRCh38
VCF_OUTPUT_DIR=/data/users/kishwar/deepvariant_outputs/vcf_outputs
LOGDIR=/data/users/kishwar/deepvariant_outputs/logs
FINAL_OUTPUT_VCF=${VCF_OUTPUT_DIR}/ccs_15kb_HG002_GRCh38.vcf.gz

REF=/data/users/common/ref/GRCh38/GRCh38_full_analysis_set_plus_decoy_hla.fa
BAM=/data/users/common/bam/ccs/bam/HG002.grch38.pb-ccs-15k.mm2.full.bam
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
    --realign_reads=False \
    --examples ${OUTPUT_DIR}/examples.tfrecord@${N_SHARDS}.gz \
    --task {}
wait;

CALL_VARIANTS_OUTPUT=${OUTPUT_DIR}/call_variants_output.tfrecord.gz
wait;

time sudo nvidia-docker run \
  -v /data/:/data/ \
  gcr.io/deepvariant-docker/deepvariant_gpu:"${BIN_VERSION}" \
  /opt/deepvariant/bin/call_variants \
  --outfile "${CALL_VARIANTS_OUTPUT}" \
  --examples "${OUTPUT_DIR}"/examples.tfrecord@"${N_SHARDS}".gz \
  --checkpoint "${MODEL}"
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
TRUTH_VCF=/data/users/common/vcf/HG002_GRCh38.vcf.gz
CONFIDENT_BED=/data/users/common/bed/HG002_GRCh38.bed
HAPPY_OUTPUT=/data/users/kishwar/deepvariant_outputs/happy_output/ccs_15kb_HG002_GRCh38
mkdir -p ${HAPPY_OUTPUT}

time sudo docker run -it -v /data/:/data/ \
  pkrusche/hap.py /opt/hap.py/bin/hap.py \
  ${TRUTH_VCF} \
  ${FINAL_OUTPUT_VCF} \
  -f ${CONFIDENT_BED} \
  -r ${REF} \
  -o ${HAPPY_OUTPUT}/deepvariant_ccs_15kb_hg002_grch38 \
  --engine=vcfeval \
  --threads=${N_SHARDS}
wait;
