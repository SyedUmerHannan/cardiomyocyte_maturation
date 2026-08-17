# cardiomyocyte_maturation

Interpretable ML and bioinformatics toolkit to identify transcriptomic signatures of iPSC-derived cardiomyocyte (iPSC-CM) maturation. The repository contains a reproducible set of data-processing and analysis scripts (primarily R and Python) that build expression matrices, perform batch correction and differential expression, and extract non-linear feature drivers with machine learning.

## Quick summary

- Primary purpose: process public RNA-seq expression data and compute features/analyses used to classify cardiomyocyte maturity states and identify maturation barriers.
- Contents: data download/processing, ComBat batch-correction, EDA/QC, differential expression, ML-based feature selection, GRN analyses and downstream interpretation scripts.

---

## What's in this repository (top-level)

```
README.md                     # this file
data/                         # raw and processed expression / metadata
  raw/                        # place raw/processed downloads here (GEO/ARCHS4/GTEx inputs)
  processed/                  # normalized and batch-corrected matrices produced by scripts
scripts/                      # analysis scripts grouped by purpose
  bioinformatics/             # stepwise R/Pipeline scripts (Step 1..Step 17)
  ml/                         # ML training / helper Python scripts
```

**How it fits together:** the code processes expression inputs in data/raw/ into merged matrices (scripts/bioinformatics/Step 3), applies batch correction (Step 4), performs EDA and QC (Step 5), computes maturation curves and differential expression (Steps 6–8), runs functional analyses (Steps 9–17), and uses the scripts/ml utilities for model training and feature selection. Many bioinformatics steps are implemented as standalone step files that should be executed in order.

---

## Requirements

- Python 3.8–3.10 (some ML helper scripts in `scripts/ml`)
- R (>= 4.0) and common Bioconductor packages used in the ComBat/batch-correction and DE steps
  - install via BiocManager: `sva`, `limma`, `edgeR` (and other packages referenced inside the step scripts)
- Optional: conda/mamba for environment management, papermill for automating notebooks if you convert steps to notebooks

---

## Quickstart — run the pipeline locally

1. Clone the repository:

   git clone https://github.com/SyedUmerHannan/cardiomyocyte_maturation.git
   cd cardiomyocyte_maturation

2. Create a reproducible environment (recommended: conda/mamba):

   # create and activate
   conda create -n cardio python=3.9 -y
   conda activate cardio

   # install Python dependencies if you have a requirements.txt
   if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

3. Install R and required Bioconductor packages from an R session:

   install.packages("BiocManager")
   BiocManager::install(c("sva", "limma", "edgeR"))

4. Prepare input data:

   - Place GEO/processed expression tables and sample metadata CSVs in `data/raw/`.
   - Metadata must map sample IDs to labels/timepoints/dataset (see header of the step scripts for expected column names).

5. Run the analysis steps (example):

   # merge matrices (Step 3)
   Rscript "scripts/bioinformatics/Step 3: Merging Matrix"

   # batch-correction with ComBat (Step 4)
   Rscript "scripts/bioinformatics/Step 4: Remove Biases with ComBat"

   # EDA and QC (Step 5)
   Rscript "scripts/bioinformatics/Step 5: EDA & QC"

   # follow the remaining steps in order (6..17) as needed

Notes:
- Some step files are R scripts (use `Rscript`) while others may be plain text or require opening in an R session. If a step expects Python, run it with `python` (check the top of each step file for usage details).
- If you prefer an interactive flow, open the step files in an R session or port them to Jupyter/RMarkdown and run sequentially.

---

## Notable scripts (bioinformatics steps)

The `scripts/bioinformatics/` directory contains numbered step files. Key entries include:

- Step 1a: Download GEO Files from ARCHS4
- Step 1b: Download GTex GEO Files from ARCHS4
- Step 2: Change Gene IDs to ENSEMBLE IDs
- Step 3: Merging Matrix
- Step 4: Remove Biases with ComBat
- Step 5: EDA & QC
- Step 6: Create Maturation Curve
- Step 7: Differential Expression
- Step 8: Merge DE and ML Corelations
- Step 9: Gene Ontology
- Step 10: PPI
- Step 11: Trajectory Modeling Strategy (R)
- Step 12: TF-Upstream Regulation Analysis
- Step 13: WGCNA Co-expression
- Step 14: DE Venn
- Step 15: LINCS
- Step 16: Cross-contrast Pathway Comparison
- Step 17: Drug Connectivity

Also check `scripts/ml/` for ML training utilities and helpers used to fit XGBoost / Random Forest models.

---

## Outputs

Typical outputs (created under `data/processed/`, `results/` or `models/` if you add them):

- Normalized and batch-corrected expression matrices
- Differential expression tables and gene lists
- Feature importance tables from XGBoost / Random Forest runs
- GRN edge lists and network objects
- Figures used in analyses

---

## Reproducibility & tips

- Pin package versions using `environment.yml` or `requirements.txt` when you add them.
- Set random seeds in ML scripts for reproducibility.
- Subset to a set of highly variable genes during development to reduce memory usage.

---

## Contributing

Contributions welcome. Open an issue to discuss changes or submit a PR. Please include a minimal example run or test where possible.

---

## Contact & citation

If you use this work, please cite the associated manuscript (if available) or contact the repository owner: https://github.com/SyedUmerHannan

---

## License

Add a LICENSE file to declare reuse terms. If no LICENSE is present the repository has no explicit open-source license.
