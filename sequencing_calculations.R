#### LIBRARIES ####

library(grid)
library(gridExtra)
library(tidyverse)
library(magrittr)
library(lubridate)
library(readxl)
library(janitor)
library(purrr)
library(furrr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### User defined variables ####

source("../wrangling_data_ssl/read_data_ssl.R")

#### read in data ####

fastqc <- read_multiqc_fastqc("../pire_lcwgs_data_processing/salarias_fasciatus/Multi_FASTQC/multiqc_report_fq.gz_data/")
mapped_read_stats <- read_bam_reads("../pire_lcwgs_data_processing/salarias_fasciatus/BAM_metrics/")

#### Join datasets ####

