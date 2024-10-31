# xQTL Simulation Pipeline

## Cohort VCF Pipeline

The steps below describe the setup and usage of the Cohort VCF generation pipeline.

### Setup

To get started, you will need a couple things:

1. [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
2. gatk

	a. The easiest option would be to pull the [docker image](https://hub.docker.com/r/broadinstitute/gatk). This also includes other
tools such as `samtools`. If you are on Hoffman2, use `apptainer`. [apptainer on hoffman](https://www.hoffman2.idre.ucla.edu/Using-H2/Software/Software.html)

	b. Install manually with instructions from
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360036194592-Getting-started-with-GATK4). You will also need to install [samtools](https://github.com/samtools/samtools).

You can then clone this repo, and you should be good to go!

### Running

There is no GPU needed for this pipeline. If you are on Hoffman2, I used these resources:

```
qrsh -pe shared 15 -l h_rt=8:00:00,h_data=2G
```

0. Enter the docker/ apptainer container or your local directory containing all code and tools.
1. Verify that the `ref/` directory contains the yeast reference fasta and bed
files.
2. Edit the path to the `bwa-mem2` executables in the Makefile.
3. Run the following command:

```
make --dry-run <path to paired end reads>.gvcf.idx
ex. make --dry-run test_data/sub_AVT.gvcf.idx
```
The above command will list out the commands that `make` will run. Verify that
the paths are correct. The input path to the paired end reads should not
include the file ending (.fasta.gz).

Once you have verified that the paths are correct you can run:

```
make <path to paired end reads>.gvcf.idx
ex. make test_data/sub_AVT.gvcf.idx
```

This will do the following:

	1. Generate the bwa index of the reference fasta.
	2. Align input paired end fastas to the reference.
	3. Add readgroups to the bam file.
	4. Index bam file.
	5. Index reference fasta.
	6. Generate reference dict file for `GenomeDB`.
	7. Generate gVCF file.
	8. Index gVCF file.

4. Then to generate the genomedb you can run:

```
make output/.genomedb
```

This just generates a database that makes the joint genotyping in the next step
faster.

5. Finally to perform joint genotyping you can run:

```
make output/sac.vcf
```

This will generate and index the final cohort vcf file from all the gVCFs found
in the directory of the input paired end reads.

More details on this gatk pipeline can be found
[here](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels)
and [here](https://zenodo.org/records/12571280).


