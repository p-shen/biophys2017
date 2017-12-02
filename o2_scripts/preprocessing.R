# install packages on O2 environment
install.packages("dplyr")
install.packages("tidyverse")

library(dplyr)
library(tidyverse)

# to test this locally, change this to the sample file
#gx <- data.table::fread("../sample.csv", sep = "\t", skip=2) # skip headers
gx <- data.table::fread("../GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_tpm.gct", sep = "\t", skip=2) # skip
attr <- read.csv("../GTEx_v7_Annotations_SampleAttributesDS.txt", sep="\t")

gx_by_gene <- as.data.frame(t(gx[,3:ncol(gx)])) # select only expression data and transpose
colnames(gx_by_gene) <- gx$Description # gene names on columns
gx_by_gene$SAMPID <- names(gx)[3:ncol(gx)] # add another column for sample ID

# select sample ID and tissue type from attr and right join to gx_by_gene by sample ID
gx_by_gene <- attr %>%
    select(`SAMPID`,`SMTS`) %>%
        right_join(gx_by_gene)

ess_gene_list <- data.table::fread("../essential_genes.csv", drop = 1)$x
noness_gene_list <- data.table::fread("../nonessential_genes.csv", drop = 1)$x

# Get the essential and non-essential genes column IDs
matched_ess <- match(ess_gene_list, colnames(gx_by_gene))
names(matched_ess) <- ess_gene_list
matched_ess <- matched_ess[!is.na(matched_ess)] # remove NA (no matching genes)

matched_non_ess <- match(noness_gene_list, colnames(gx_by_gene))
names(matched_non_ess) <- noness_gene_list
matched_non_ess <- matched_non_ess[!is.na(matched_non_ess)] # remove NA (no matching genes)

# Get the expression data for the essential and non-essential genes and write out
ess_gx <- gx_by_gene[,c(1,2,matched_ess)]
write.table(ess_gx, file="../essential_gene_cols.csv", sep="\t")

non_ess_gx <- gx_by_gene[,c(1,2,matched_non_ess)]
write.table(non_ess_gx, file="../nonessential_gene_cols.csv", sep="\t")
