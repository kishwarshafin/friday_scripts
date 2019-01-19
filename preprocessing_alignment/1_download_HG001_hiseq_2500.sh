#!/bin/bash
# FROM README: This README describes the library preparation and sequencing
# performed at NIST for NA12878, the AJ Trio, and the Chinese trio.
# This folder contains the data for NA12878 only.
# The folder “NHGRI_Illumina300X_novoalign_bams” contains bam files using novoalign.
# The other folders each contain ~20-30x sequencing total (a single flow cell)
# and contain folders with fastq files from each library, which can be combined for most purposes.
# RMNISTHS_30xdownsample.bam is a bam file mapped with bwa mem and down sampled to ~25-30x coverage.
echo "Downloading HG001 NIST HiSeq 2500 fastq files"

wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/131219_D00360_005_BH814YADXX/

# alignment
wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140115_D00360_0010_BH894YADXX/
wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140127_D00360_0011_AHGV6ADXX/

wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/131219_D00360_006_AH81VLADXX/
wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/131223_D00360_007_BH88WKADXX/

wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/131223_D00360_008_AH88U0ADXX/
wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140115_D00360_0009_AH8962ADXX/

wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140127_D00360_0012_BH8GVUADXX/
wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140207_D00360_0013_AH8G92ADXX/

wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140313_D00360_0014_AH8GGVADXX/
wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140313_D00360_0015_BH9258ADXX/

wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140407_D00360_0016_AH948VADXX/
wget -r ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/140407_D00360_0017_BH947YADXX/

mv ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/* .
rm -rf ftp-trace.ncbi.nlm.nih.gov/
