#!/bin/bash
### FRIDAY EVALUATION

# RUN DEEPVARIANT
FRIDAY_PATH=/home/kishwar/Kishwar/software/friday
OUTPUT_DIR=/data/users/kishwar/friday_outputs/images/pfda_HG002_GRCh37
VCF_OUTPUT_DIR=/data/users/kishwar/friday_outputs/vcf_output

REF=/data/users/common/ref/GRCh37/human_g1k_v37.fasta
BAM=/data/users/common/bam/precision_fda/pfda_HG002_GRCh37.bam
MODEL=/data/users/common/friday_model/hg001_grch37/_epoch_6_checkpoint.pkl
N_SHARDS=32

mkdir -p ${OUTPUT_DIR}
mkdir -p ${VCF_OUTPUT_DIR}

# IMAGE GENERATION
time seq 0 $((N_SHARDS-1)) | time parallel --ungroup python3 ${FRIDAY_PATH}/generate_images.py \
--bam ${BAM} \
--fasta ${REF}\
--threads ${N_SHARDS} \
--chromosome_name 1-22,X,Y \
--sample_name "NA24385" \
--output_dir ${OUTPUT_DIR} \
--thread_id {}
wait;

# CSV PROCESSING
# THIS IS EMBARASSING, NEED TO HANDLE THIS INSIDE IMAGE GENERATION :-(
cd ${OUTPUT_DIR}

for i in `seq 1 22`;
do
  cat ${i}_*.csv > ${i}.csv
done
cat X_* > X.csv
cat Y_* > Y.csv
rm -rf X_*
rm -rf Y_*
wait;

# VARIANT CALLING
time python3 call_variants.py \
--csv_dir ${OUTPUT_DIR} \
--bam_file ${BAM} \
--chromosome_name 1-22,X,Y \
--batch_size 1024 \
--num_workers 64 \
--model_path ${MODEL} \
--gpu_mode 1 \
--output_dir ${VCF_OUTPUT_DIR}

wait;


# FOR FRIDAY THIS IS DONE SEPARATELY, ONCE THE FINAL OUTPUT IS GENREATED THE FINAL OUTPUT FILE NEEDS TO GO THERE
# HAP.PY
sudo docker pull pkrusche/hap.py
FINAL_OUTPUT_VCF=/data/users/kishwar/friday_outputs/vcf_output/pfda_friday_HG002_GRCh37.vcf.gz
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
