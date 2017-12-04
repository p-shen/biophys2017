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

# Get the p_values between each pair of the tissue types
ess_posthoc.p_values <- lapply(ess_posthoc, function(x) x$`ess_gx$SMTS`[, 4])

# Structure of ess_posthoc.p_values_adjusted
# - list of 583, each list is one gene
# - each list is a numeric vector of p_values of length 435, which has names of the pair-wise tissue types
# Example:
# > str(ess_posthoc.p_values_adjusted[[1]])
# Named num [1:435] 0.0 1.0 0.0 3.8e-06 0.0 ...
# - attr(*, "names")= chr [1:435] "Adrenal Gland-Adipose Tissue" "Bladder-Adipose Tissue" "Blood-Adipose Tissue" "Blood Vessel-Adipose Tissue" ...

## Output to files
# convert it into a datafrme for output
ess_posthoc.p_values_df <- as.data.frame(do.call(rbind, ess_posthoc.p_values))
# Structure of ess_posthoc.p_values_adjusted_df
# - 583 x 435
# - col pair-wise tissue types
# - row gene names
# - has zeros

# write into csv file
write.table(ess_posthoc.p_values_df, file="../essential_gene_posthoc_pvalues.csv")


## Analysis on non-essential genes
# Run anova on all non-essential genes
noness_anova_result <- lapply(lapply(noness_gx[,3:ncol(noness_gx)], function(x) lm(x ~ noness_gx$SMTS)), anova)

# Fit an analysis of variance model on all non-essential genes
a2 <- lapply(noness_gx[,3:ncol(noness_gx)], function(x) aov(x ~ noness_gx$SMTS))

# Compute Tukey Honest Significant Differences
noness_posthoc <- lapply(a2, function(x) TukeyHSD(x , 'noness_gx$SMTS', conf.level = 0.95))

# Get the p_values between each pair of the tissue types 
noness_posthoc.p_values <- lapply(noness_posthoc, function(x) x$`noness_gx$SMTS`[, 4])

## Output to files
# convert it into a datafrme for output
noness_posthoc.p_values_df <- as.data.frame(do.call(rbind, noness_posthoc.p_values))

#  write into csv file
write.table(noness_posthoc.p_values_df, file="../nonessential_gene_posthoc_pvalues.csv")
