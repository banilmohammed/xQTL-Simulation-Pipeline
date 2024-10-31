#!/usr/bin/bash

# Script to generate cohort VCF files from gVCFs

SPLIT_CHROM=$1
OUTPUT_VCF=$2
OUTPUT_DIR=$(dirname ${OUTPUT_VCF})
INPUT_GENDB=$3
REF_FASTA=$4

echo "test"

if [ ${SPLIT_CHROM} -eq 0 ]; then
        echo "Not splitting by chromosome"
	gatk GenotypeGVCFs \
		--include-non-variant-sites \
		-R ${REF_FASTA} \
		-V gendb://${INPUT_GENDB} \
		-O ${OUTPUT_VCF} 
else
	# TODO: parallelize
        echo "Splitting by chromosome"
        for i in {1..16}; do
                chrom="chromosome${i}"
                chrom_vcf="${OUTPUT_DIR}/${chrom}.vcf.gz"
		gatk GenotypeGVCFs \
			--intervals ${chrom} \
			--include-non-variant-sites \
			-R ${REF_FASTA} \
			-V gendb://${INPUT_GENDB} \
			-O ${chrom_vcf} 
        done

        echo "Combining chromosomes"
        gatk MergeVcfs \
                -I "${OUTPUT_DIR}/chromosome1.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome2.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome3.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome4.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome5.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome6.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome7.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome8.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome9.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome10.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome11.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome12.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome13.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome14.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome15.vcf.gz" \
                -I "${OUTPUT_DIR}/chromosome16.vcf.gz" \
                -O ${OUTPUT_VCF}
fi
