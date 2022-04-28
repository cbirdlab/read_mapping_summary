# read_mapping_summary
---

## This repository holds the tools needed for optimizing sequencing efforts using the Illumina NovaSeq 6000. 
---

### Section A. - When Mapping to a Portion of the Genome 
### Section B. - When Mapping to the Whole Genome 

---

This repository will help you answer the following question: How much sequencing needs to be done to reach your desired depth of coverage? 

Specifically, we are solving for the '% Duplicates' value needed for the [Illumina Sequencing Coverage Calculator](https://support.illumina.com/downloads/sequencing_coverage_calculator.html). To navigate to the window below, we clicked DNA Applications (blue button) > Whole-Genome Sequencing (in drop down menu).

![](https://github.com/cbirdlab/rroberts_thesis/blob/e210bc43dfb0044eed64b1c497d0e41cee9bb598/sequencing_calculations/IlluminaSeqCalc.png)

---

*Note: Although Illumina labels the unmapped reads as 'Duplicates,' this percent represents all discarded or otherwise unmapped reads*

---

## A. When Mapping to a Portion of the Genome 
---
### Solving for **x%**
---

We mapped reads to a portion (x%) of the genome.  To calculate x%, we need to sum the number of nucleotides in the top 100 contigs (nt<sub>100</sub>) that the reads were mapped to and divide that by the total number of nucleotides in the complete reference genome (nt<sub>tot</sub>).

* **nt<sub>100</sub>**: count the number of nt in the "top 100" fasta file

```bash
# log into wahab.hpc.odu.edu
cd /home/cbird/roy/rroberts_thesis/summary_data_ssl/dDocentHPC_data/Aur/
cat reference.denovoSSL.Aur-C-all-R1R2ORPH-contam-noisolate.fasta | grep -v "NODE" | wc -m 
```
* **nt<sub>100</sub>** = 31156387

* **nt<sub>tot</sub>**: get from quast output for the library used to construct the reference genome

```bash
# denovo genome assembly repo has the answer, use quast output
git clone git@github.com:philippinespire/denovo_genome_assembly.git
cd denovo_genome_assembly/compare_assemblers
```
* open [wrangle_data.R](https://github.com/philippinespire/denovo_genome_assembly/blob/main/compare_assemblers/wrangle_data.R) in Rstudio
* run script
* open tibble named `tbl_assembly`
* for Aur, filter Species column by Aur
* sort by n50, high to low
* top genome should be `Aur_all_spades_contam_R1R2ORPH_21-99_noisolate`
* obtain value from `total_length` and `estimated_reference_length` 
* **nt<sub>tot</sub>** = 439162585, 445000000


We then divide **nt<sub>100</sub>** by the **nt<sub>tot</sub>** to find  x% of the genome that our reads are mapping to:

**x%** = (31156387/439162585) * 100 = 7.09%
         (31156387/445000000) * 100 = 7.00%

This means that our reads are mapping to ~ 7.00% of the reference genome for the Aur species.

---

### Solving for **n<sub>x%nraw</sub>**
---

Given that we are mapping to x% of the reference genome, we assume that the same x% of the total number of raw reads from a given library will map to the reference. To solve for the expected number of mapped reads, **n<sub>x%nraw</sub>**, we multiply x% by the total number of raw reads, **nr<sub>tot</sub>**.

* **nr<sub>tot</sub>**: Find total number of raw reads 
add script here

* **n<sub>x%nraw</sub>**: Multiply **x%** by **nr<sub>tot</sub>**

This means that xxx reads are expected to map to the reference for Aur.

---

### Solving for **q**
---

Now that we know the expected number of mapped reads, **n<sub>x%nraw</sub>**, we can divide the actual number of mapped reads, **n<sub>x%nmapped</sub>**, by **n<sub>x%nraw</sub>** to obtain the proportion mapped, **p**.

To solve for the proportion not mapped, **q**, subtract **p** from 1 and multiply by 100.

**q** = (1 - **p**) * 100

*this percent value can then be plugged into the Illumina Sequencing Coverage Calculator* 


---

## B. When Mapping to the Whole Genome
---

Given that we are mapping to 100% of the genome, we simply divide the number of mapped reads **nr<sub>mapped</sub>** by the number of total raw reads **nr<sub>tot</sub>**.

### Data Used

**nr<sub>mapped</sub>**: Find total number of mapped reads with [`mappedReadStats.sbatch`](https://github.com/cbirdlab/rroberts_thesis/blob/main/scripts/bam_processing/mappedReadStats.sbatch)

```bash 
# login to wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/salarias_fasciatus
sbatch ../../rroberts_thesis/scripts/bam_processing/mappedReadStats.sbatch fltrBAM/ BAM_metrics Sfa .bam
```

**nr<sub>tot</sub>**: Find total number of raw reads using fastqc and Multiqc on raw fq.gz files

- This data was generated in step 1. of the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repo instructions using the [`Multi_FASTQC.sh`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. It should already exist in your species directory.

### Data Wrangled

- I used this script to read-in/join fastqc and mapped reads data on Rstudio [`sequencing_calculations.R`](https://github.com/cbirdlab/rroberts_thesis/blob/main/sequencing_calculations/sequencing_calculations.R)

- Funtions to read in the data were sourced from [`read_multiqc.R`](https://github.com/cbirdlab/read_multiqc/blob/main/read_multiqc.R)

- The functions used were `read_multiqc_fastqc()` and `read_bam_reads()`
