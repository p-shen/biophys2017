ess_gx <- read.csv("../expdata_essential_gene.csv",sep='\t')
non_ess_gx <- read.csv("../expdata_nonessential_gene_data.csv", sep = '\t')
ess_gene_list <- data.table::fread("../names_essential_genes.csv", drop = 1)$x
noness_gene_list <- data.table::fread("../names_nonessential_genes.csv", drop = 1)$x

tissue_list <- unique(ess_gx$SMTS)

# normalize method - make all values lie between 0 - 1
normalize <- function(exp){
  exp <- (exp - min(exp))/(max(exp) - min(exp))
  exp
}

# The function that perform t-test
get_pvalue_table <- function(type,filter.zero = FALSE, normalized = FALSE){
  #normalized = TRUE
  # type = 'non_essential'
  gene_tissue_exp <- c()
  gene_list <- c()
  
  # Decide the data we use according to type argument
  if(type == "essential"){
    gene_tissue_exp <- ess_gx[,-1]
    gene_list <- names(gene_tissue_exp)[-1]
  }else{
    gene_tissue_exp <- non_ess_gx[,-1]
    gene_list <- names(gene_tissue_exp)[-1]
  }
  
  # Make all the value lie between 0 - 1 if normalized argument is true
  if(normalized == TRUE){
    for(tissue in tissue_list){
      for(gene in gene_list){
        gene_tissue_exp[which(gene_tissue_exp$SMTS==tissue),gene] <- normalize(gene_tissue_exp[which(gene_tissue_exp$SMTS==tissue),gene])
      }
      
    }
    gene_tissue_exp
  }
  
  gene_tissue_pvalue_table <- matrix(ncol = length(tissue_list),nrow = 0)
  # Get pvalue list of all the gene
  for(gene in gene_list){
    
    # for every gene, select one cell line as one group, and the remaining cell lines as another
    tissue_pvalue_list <- c()
    for(tissue in tissue_list){
      target_tissue_gene_exp <- gene_tissue_exp[which(gene_tissue_exp$SMTS==tissue),gene]
      
      remaining_tissue_gene_exp <- gene_tissue_exp[which(gene_tissue_exp$SMTS!=tissue),gene]
      
      # Filter zero value if filter.zero == TRUE
      if(filter.zero == TRUE){
        target_tissue_gene_exp <- target_tissue_gene_exp[which(target_tissue_gene_exp!=0)]
        remaining_tissue_gene_exp <- remaining_tissue_gene_exp[which(remaining_tissue_gene_exp!=0)]
      }
      
      # Perform t-test of 2 groups
      pval <- 0
      if(length(target_tissue_gene_exp) <= 1 | length(remaining_tissue_gene_exp) <= 1){
        pval <- NA
      }else{
        pval <- t.test(target_tissue_gene_exp, remaining_tissue_gene_exp)$p.value
      }
      tissue_pvalue_list <- append(tissue_pvalue_list,pval)
    }
    
    gene_tissue_pvalue_table <- rbind(gene_tissue_pvalue_table, tissue_pvalue_list)
  }
  
  # Get the final pvla
  gene_tissue_pvalue_table <- as.data.frame(gene_tissue_pvalue_table)
  colnames(gene_tissue_pvalue_table) <- tissue_list
  rownames(gene_tissue_pvalue_table) <- gene_list
  
  gene_tissue_pvalue_table
  
}

# Create subfolders first before creating the file
dir.create((paste0("../ttest_results/")),showWarnings = FALSE)

ess_ttest_results <- get_pvalue_table("essential")
ess_ttest_results_filtered <- get_pvalue_table("essential", filter.zero = TRUE)
ess_ttest_results_filtered_normalized <- get_pvalue_table("essential", filter.zero = TRUE, normalized = TRUE)

write.csv(ess_ttest_results, file="../ttest_results/essential_ttest_results.csv",row.names = TRUE)
write.csv(ess_ttest_results_filtered,file="../ttest_results/ess_ttest_results_filtered.csv",row.names = TRUE)
write.csv(ess_ttest_results_filtered_normalized, file="../ttest_results/essential_ttest_results_filtered_normalized.csv",row.names = TRUE)


non_ess_ttest_results <- get_pvalue_table("non_essential")
non_ess_ttest_results_filtered <- get_pvalue_table("non_essential", filter.zero = TRUE)
non_ess_ttest_results_filtered_normalized <- get_pvalue_table("non_essential", filter.zero = TRUE, normalized = TRUE)

write.csv(non_ess_ttest_results, file="../ttest_results/non_essential_ttest_results.csv",row.names = TRUE)
write.csv(non_ess_ttest_results_filtered,file="../ttest_results/non_ess_ttest_results_filtered.csv",row.names = TRUE) 
write.csv(non_ess_ttest_results_filtered_normalized, file="../ttest_results/non_essential_ttest_results_filtered_normalized.csv",row.names = TRUE)