library(tidyverse)
library(dplyr)

## Preprocess
# Read in essential and non-essential gene expression data
ess_gx <- data.table::fread("../expdata_essential_gene.csv", fill = T)
ess.gx_colname <- colnames(ess_gx)[-length(colnames(ess_gx))]
ess_gx <- ess_gx[,-1]
colnames(ess_gx) <- ess.gx_colname

noness_gx <- data.table::fread("../expdata_nonessential_gene_data.csv", fill = T)
noness.gx_colname <- colnames(noness_gx)[-length(colnames(noness_gx))]
noness_gx <- noness_gx[,-1]
colnames(noness_gx) <- noness.gx_colname

# log transforma the expression data
ess_gx[, 3:ncol(ess_gx)] <- log2(ess_gx[, 3:ncol(ess_gx)]+1)
noness_gx[, 3:ncol(noness_gx)] <- log2(noness_gx[, 3:ncol(noness_gx)]+1)

## Analysis on essential genes
# Run anova on all essential genes
ess_anova_result <- lapply(lapply(ess_gx[,3:ncol(ess_gx)], function(x) lm(x ~ ess_gx$SMTS)), anova)

# Fit an analysis of variance model on all essential genes
a1 <- lapply(ess_gx[,3:ncol(ess_gx)], function(x) aov(x ~ ess_gx$SMTS))

# Compute Tukey Honest Significant Differences
ess_posthoc <- lapply(a1, function(x) TukeyHSD(x , 'ess_gx$SMTS', conf.level = 0.95))

# Get the p_values between each pair of the cell lines 
ess_posthoc.p_values <- lapply(ess_posthoc, function(x) x$`ess_gx$SMTS`[, 4])
# Adjusted for multi hypo testing and Get those less than 0.05 but greater than 0
ess_posthoc.p_values_adjusted <- lapply(ess_posthoc.p_values, p.adjust, "fdr") %>% lapply(function(x) x[which(x < 0.05 & x > 0)])

# Structure of ess_posthoc.p_values_adjusted
# - list of 583, each list is one gene
# - each list is a numeric vector of p_values, which has col names of the pair-wise cell lines
# Example:
# > str(posthoc.p_values_adjusted[[1]])
# Named num [1:66] 3.80e-06 3.62e-08 2.29e-08 3.01e-08 1.15e-07 ...
# - attr(*, "names")= chr [1:66] "Blood Vessel-Adipose Tissue" "Colon-Adipose Tissue" "Nerve-Adipose Tissue" "Salivary Gland-Adipose Tissue" ...
