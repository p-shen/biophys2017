library(tidyverse)
library(pheatmap)

# Since you dont have the file (too large to push to github), we can try nonessential genes
# but you can run anova.R to get essential_gene_data_nonzero.csv
# gx <- data.table::fread("../essential_gene_data_nonzero.csv",drop = 1) # skip headers

noness_gx_nonzero <- data.table::fread("../nonessential_gene_data_nonzero.csv",drop = 1) # skip headers


percent_top_correlations <- 0.20 # what % of top correlated genes do we want to analyze?

cors <- cor(noness_gx_nonzero[,3:ncol(noness_gx_nonzero)], method="s")

cors[lower.tri(cors,diag=TRUE)] <- NA  #Prepare to drop duplicates and meaningless information
cors <- as.data.frame(as.table(cors))  #Turn into a 3-column table
cors <- na.omit(cors)  #Get rid of the junk we flagged above
cors <- cors[order(-abs(cors$Freq)),]

top_correlated_genes <- cors[1:ceiling(nrow(cors)*percent_top_correlations),]
top_correlated_genes <- unique(unlist(as.list(top_correlated_genes[,1:2])))
top_correlated_genes