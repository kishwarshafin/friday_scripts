#!/bin/bash

# PICARD
# wget https://github.com/broadinstitute/picard/releases/download/2.18.21/picard.jar
# export PICARD=/home/kishwar/software/picard.jar
# sudo apt update; sudo apt install default-jdk; java -version; java -jar $PICARD -h

# BWA
# sudo apt-get install make gcc zlib1g-dev make
# sudo apt-get install autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev
# git clone https://github.com/lh3/bwa.git; cd bwa; make
# sudo ln bwa /usr/local/bin/

# SAMTOOLS
# wget https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2
# tar -xjvf samtools-1.7.tar.bz2
# cd samtools-1.7/
# make
# sudo make prefix=/usr/local/bin install
# sudo ln -s /usr/local/bin/bin/samtools /usr/bin/samtools
# samtools --version

ALIGN_FASTQS() {
  mkdir -p /data/tmp
  mkdir -p /data/tmp/logs

  PICARD=/home/kishwar/software/picard.jar
  REF=/data/ref/GRCh38/GRCh38_full_analysis_set_plus_decoy_hla.fa
  # PICARD=/home/kishwar/Kishwar/software/picard/picard.jar
  # REF=/data/users/common/ref/GRCh38/GRCh38_full_analysis_set_plus_decoy_hla.fa

  # THE FILE SYSTEM IS NOW LIBRARY->PROJECT->READ_GROUP->FASTQs
  for LIBRARY in */;
  do
    echo "PROCESSING: ${LIBRARY}"
    cd ${LIBRARY}
    for PROJECT in */;
    do
      cd ${PROJECT}

      for READ_GROUP in */;
      do
        cd ${READ_GROUP}
        READ_GROUP_NAME=

        echo "1/3: BWA ALIGNMENT: ${READ_GROUP_NAME}"
        header=$(cat ${READ_GROUP_NAME}_R1.fastq | head -n 1)
        id=$(echo $header | head -n 1 | cut -f 1-4 -d":" | sed 's/@//' | sed 's/:/_/g')
        sm=$(echo $header | head -n 1 | grep -Eo "[ATGCN]+$")
        echo "Read Group @RG\tID:$id\tSM:$id"_"$sm\tLB:$id"_"$sm\tPL:ILLUMINA"
        (bwa mem \
        -M \
        -t 32 \
        -R $(echo "@RG\tID:$id\tSM:$id"_"$sm\tLB:$id"_"$sm\tPL:ILLUMINA") \
        ${REF} \
        ${READ_GROUP_NAME}_R1.fastq ${READ_GROUP_NAME}_R2.fastq |
        samtools sort -@32 -o ${READ_GROUP_NAME}_GRCh38_clean.bam -) > "/data/tmp/logs/bwa_samtools_HG001_GRCh38.log" 2>&1
        wait;

        mv ${READ_GROUP_NAME}_GRCh38_clean.bam ../
        echo "DONE: ${READ_GROUP}"
        cd ..
      done
      for i in *_GRCh38_clean.bam;do echo "INPUT=${i}" >> all_read_groups.txt ;done ;wait
      readarray -t bam_array < all_read_groups.txt
      rm all_read_groups.txt
      export ${bam_array[@]}
      echo ${bam_array[@]}

      #run markduplicates on all samples. This will remove all duplicates while also merging all the bams into a single file
      echo "MARKING DUPLICATES AND MERGING: ${LIBRARY}"
      LIBRARY_NAME=${LIBRARY::-1}
      (java -verbose:gc -XX:+UseParallelOldGC -XX:+AggressiveOpts -XX:ParallelGCThreads=32 -Xms50g  -Xmx110g -jar ${PICARD} MarkDuplicates \
      $(echo ${bam_array[@]}) \
      OUTPUT=${LIBRARY_NAME}_HG001_GRCh38.bam \
      METRICS_FILE=/data/tmp/logs/dupmetrics_${LIBRARY_NAME}_HG001_GRCh38.txt \
      CREATE_INDEX=true \
      REMOVE_DUPLICATES=true \
      MAX_RECORDS_IN_RAM=40000000 \
      ASSUME_SORT_ORDER=coordinate \
      USE_JDK_DEFLATER=true \
      USE_JDK_INFLATER=true \
      TMP_DIR=/data/tmp) > "/data/tmp/logs/markdup_HG001_GRCh38.log" 2>&1
      wait;

      rm -rf *_GRCh38_clean.bam
      cd ..

    done
    echo "DONE: ${LIBRARY}"
    cd ..
  done
}

ALIGN_FASTQS
wait

# gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp -r <bam_file> gs://kishwar-giab-alignments/bams/giab_HG001_GRCh38/
