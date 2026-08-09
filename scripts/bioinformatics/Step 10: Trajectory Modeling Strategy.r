## ---- Cell 1: Install packages ----
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("DESeq2", update = FALSE, ask = FALSE)
if (!dir.exists("/content/drive")) {
  system("python3 -c \"from google.colab import drive; drive.mount('/content/drive')\"")
}
library(DESeq2)

dds_path <- "/content/drive/MyDrive/Research/Cardiac Maturation AI/Master/dds_full_condition_model.rds"
dds <- readRDS(dds_path)

if (!inherits(dds, "DESeqDataSet")) {
  stop("HARD FAIL: loaded object is not a DESeqDataSet.")
}
cat("Master dds loaded:", nrow(dds), "genes x", ncol(dds), "samples\n")
print(colnames(colData(dds)))
## ---- Cell 4: Identify day + individual columns, subset to GSE122380 samples ----
# UPDATE these two variable names to match your actual colData column names
DAY_COL <- "day_estimate"        # e.g. differentiation day, numeric
INDIV_COL <- "individual"        # e.g. donor/cell-line ID

cd <- as.data.frame(colData(dds))

if (!DAY_COL %in% colnames(cd)) {
  stop(paste0("HARD FAIL: '", DAY_COL, "' not found in colData. Available columns: ",
              paste(colnames(cd), collapse=", ")))
}
if (!INDIV_COL %in% colnames(cd)) {
  stop(paste0("HARD FAIL: '", INDIV_COL, "' not found in colData. Available columns: ",
              paste(colnames(cd), collapse=", ")))
}

cd[[DAY_COL]] <- suppressWarnings(as.numeric(as.character(cd[[DAY_COL]])))
keep <- !is.na(cd[[DAY_COL]])

n_keep <- sum(keep)
if (n_keep == 0) {
  stop("HARD FAIL: zero samples have a non-NA day value - check DAY_COL name/values.")
}
cat("Samples with valid day value:", n_keep, "\n")
cat("Day range:", range(cd[[DAY_COL]][keep]), "\n")
cat("Unique individuals:", length(unique(cd[[INDIV_COL]][keep])), "\n")

dds_sub <- dds[, keep]
colData(dds_sub)[[DAY_COL]] <- cd[[DAY_COL]][keep]
colData(dds_sub)[[INDIV_COL]] <- factor(cd[[INDIV_COL]][keep])
## ---- Cell 5: Build fresh DESeqDataSet with day-continuous paired design ----
raw_counts <- counts(dds_sub, normalized = FALSE)

if (any(is.na(raw_counts))) {
  stop("HARD FAIL: NA values in raw count matrix - subsetting error.")
}

col_data_sub <- as.data.frame(colData(dds_sub))
col_data_sub$day <- col_data_sub[[DAY_COL]]
col_data_sub$individual <- col_data_sub[[INDIV_COL]]

# drop individuals with only 1 timepoint - can't contribute to a paired day effect
indiv_counts <- table(col_data_sub$individual)
single_tp <- names(indiv_counts[indiv_counts < 2])
if (length(single_tp) > 0) {
  cat("Dropping", length(single_tp), "individuals with <2 timepoints:", paste(single_tp, collapse=", "), "\n")
  keep2 <- !(col_data_sub$individual %in% single_tp)
  raw_counts <- raw_counts[, keep2]
  col_data_sub <- col_data_sub[keep2, ]
  col_data_sub$individual <- droplevels(col_data_sub$individual)
}

cat("Final samples for time-course model:", ncol(raw_counts), "\n")
cat("Final individuals:", length(unique(col_data_sub$individual)), "\n")

dds_tc <- DESeqDataSetFromMatrix(
  countData = raw_counts,
  colData = col_data_sub,
  design = ~ individual + day
)
r
## ---- Cell 6: Run DESeq2 LRT (full: individual+day vs reduced: individual only) ----
dds_tc <- DESeq(dds_tc, test = "LRT", reduced = ~ individual)

res_tc <- results(dds_tc)

if (all(is.na(res_tc$padj))) {
  stop("HARD FAIL: all padj NA - LRT likely misspecified or model failed to fit.")
}

summary(res_tc)
## ---- Cell 7: Save results ----
res_df <- as.data.frame(res_tc)
res_df$ensembl_id <- rownames(res_df)

out_dir <- "/content/drive/MyDrive/Research/Cardiac Maturation AI/Master Data/step_timecourse_LRT/"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(res_df, paste0(out_dir, "GSE122380_day_LRT_results.csv"), row.names = FALSE)

sig <- subset(res_df, padj < 0.05)
write.csv(sig, paste0(out_dir, "GSE122380_day_LRT_significant.csv"), row.names = FALSE)

cat("Tested:", nrow(res_df), " | Significant day-effect genes (padj<0.05):", nrow(sig), "\n")
## ---- Cell 8: Marker check - do your clock genes show a day trend? ----
markers <- c(
  MYH6="ENSG00000197616", MYH7="ENSG00000092054",
  TNNI3="ENSG00000129991", TNNI1="ENSG00000151632",
  RYR2="ENSG00000198626", ATP2A2="ENSG00000174950"
)
marker_hits <- res_df[res_df$ensembl_id %in% markers, c("ensembl_id","log2FoldChange","pvalue","padj")]
marker_hits$gene_symbol <- names(markers)[match(marker_hits$ensembl_id, markers)]
print(marker_hits[, c("gene_symbol","ensembl_id","log2FoldChange","padj")])
