#!/usr/bin/bash

# Script to generate gVCF files either by splitting chromosomes or not

SPLIT_CHROM=$1
OUTPUT_VCF=$2
OUTPUT_DIR=$(dirname ${OUTPUT_VCF})
REF_FASTA=$3
ALIGNED_BAM=$4

if [ $SPLIT_CHROM -eq 0 ]; then
	echo "Not splitting by chromosome"
	gatk HaplotypeCaller \
		-R ${REF_FASTA} \
		-I ${ALIGNED_BAM} \
		-O ${OUTPUT_VCF} \
		--emit-ref-confidence GVCF
else
	# TODO: parallelize
	echo "Splitting by chromosome"
	for i in  {1..16}; do
		chrom="chromosome${i}"
		chrom_vcf="${OUTPUT_DIR}/${chrom}_g.vcf.gz"
		gatk HaplotypeCaller -R ${REF_FASTA} \
			-I ${ALIGNED_BAM} \
			-O ${chrom_vcf} \
			--emit-ref-confidence GVCF \
			-L ${chrom}
	done

	echo "Combining chromosomes"
	gatk MergeVcfs \
		-I "${OUTPUT_DIR}/chromosome1_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome2_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome3_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome4_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome5_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome6_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome7_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome8_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome9_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome10_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome11_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome12_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome13_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome14_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome15_g.vcf.gz" \
		-I "${OUTPUT_DIR}/chromosome16_g.vcf.gz" \
		-O ${OUTPUT_VCF}
fi
