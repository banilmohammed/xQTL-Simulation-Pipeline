BWA_DIR=/u/project/kruglyak/nmohamm/xQTL-Simulation-Pipeline/bwa_mem2

SPLIT_CHROM=0

INTERMEDIATE_BAMS := $(wildcard test2/*.mapping.bam)
INTERMEDIATE_RDBAMS := $(wildcard test2/*.mapping.RD.bam)

SECONDARY_FILES := $(INTERMEDIATE_BAMS) $(INTERMEDIATE_RDBAMS)

.SECONDARY: $(SECONDARY_FILES)

# generate bwa index of reference fasta
ref/.sace_ref.bwa.idx:
	@echo "Creating bwa index of $<"
	$(BWA_DIR)/bwa-mem2 index ref/sace_ref.fasta.gz
	@touch $@

# align input fastqs to reference
%.mapping.bam: ref/.sace_ref.bwa.idx %_1.fastq.gz %_2.fastq.gz
	@echo "Aligning input fastqs to reference"
	$(BWA_DIR)/bwa-mem2 mem -t 20 ref/sace_ref.fasta.gz $*_1.fastq.gz $*_2.fastq.gz | samtools sort -o $@ -T $*.tmp

# add readgroups
%.mapping.RD.bam: %.mapping.bam
	@echo "Adding readgroups to $<"
	gatk AddOrReplaceReadGroups -I $< -O $@ \
	--RGID SampleName \
	--RGLB SampleName \
	--RGPL ILLUMINA \
	--RGPU SampleName \
	--RGSM SampleName

# index aligned bam file
%.mapping.RD.bam.bai: %.mapping.RD.bam
	@echo "Indexing $^"
	samtools index $< $@

# index reference fasta
ref/sace_ref.fasta.gz.fai: ref/sace_ref.fasta.gz
	@echo "Indexing $<"
	samtools faidx $< -o $@

# generate sequence dict file
ref/.sace_ref.dict: ref/sace_ref.fasta.gz
	@echo "Generating sequence dict"
	gatk CreateSequenceDictionary -R $<
	@touch $@

# generate gvcfs
%.g.vcf.gz: ref/sace_ref.fasta.gz %.mapping.RD.bam ref/sace_ref.fasta.gz.fai ref/.sace_ref.dict %.mapping.RD.bam.bai
	@echo "Generating gVCFs"
	bash gen_gvcfs.sh $(SPLIT_CHROM) $@ $^

# index gvcf file
.%.gvcf.idx: %.g.vcf.gz
	@echo "Indexing gVCF file"
	gatk IndexFeatureFile -I $<
	@touch $@

# consolidate and generate GenomicsDB
output/.genomedb:
	@echo "Generating GenomicsDB"
	bash gen_genomedb.sh output/ test_data/ ref/sace_ref.bed
	@touch $@

# generate cohort VCF
output/sac.vcf:
	@echo "Generating Cohort VCF"
	bash gen_cohort_vcf.sh $(SPLIT_CHROM) output/sac.vcf output/sac_genome ref/sace_ref.fasta.gz
