#!/usr/bin/bash

# Script to generate GenomeDB file from gVCFs

OUTPUT_DIR=$1
GVCF_DIR=$2
INPUT_BED=$3

GVCF_FILES=""

for GVCF in "${GVCF_DIR}/*.g.vcf.gz"; do
	GVCF_FILES=${GVCF_FILES}"-V $GVCF"
done

gatk GenomicsDBImport \
	--overwrite-existing-genomicsdb-workspace \
	--batch-size 200 \
	--genomicsdb-workspace-path "${OUTPUT_DIR}/sac_genome" \
	-L ${INPUT_BED} \
	$GVCF_FILES
