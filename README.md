# cardiomyocyte_maturation

Interpretable ML framework to identify transcriptomic signatures of iPSC-CM maturation.

This repository implements a pipeline that processes bulk RNA-seq data, performs normalization and batch correction, identifies non-linear feature drivers using XGBoost and Random Forest, reconstructs gene regulatory networks (GRNs), and trains a hybrid classifier that integrates expression and network topology to predict cardiomyocyte maturity.

---

## Quickstart — run the pipeline locally

1. Clone the repository:

   git clone https://github.com/SyedUmerHannan/cardiomyocyte_maturation.git
   cd cardiomyocyte_maturation

2. Create a reproducible environment (recommended: conda/mamba):

   # create and activate
   conda create -n cardio python=3.9 -y
   conda activate cardio

   # install Python dependencies (if a requirements file exists)
   if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

   # OR if an environment.yml is provided
   if [ -f environment.yml ]; then conda env create -f environment.yml; fi

3. Install R and required Bioconductor packages (used for ComBat / batch-correction):

   # from an R session
   install.packages("BiocManager")
   BiocManager::install(c("sva", "limma", "edgeR"))

   R >= 4.0 is recommended.

4. Start Jupyter Lab / Notebook for interactive runs:

   jupyter lab

---

## What to expect in this repo

Typical layout (your clone may vary):

- data/
  - raw/            # raw downloads (FASTQ or processed expression tables)
  - processed/      # normalized, batch-corrected matrices used by models
  - metadata/       # sample metadata CSV/TSV mapping samples to labels/timepoints
- notebooks/        # Jupyter notebooks for each pipeline step
- scripts/          # convenience scripts for download, preprocessing, and training (if present)
- src/              # reusable Python modules
- results/          # trained models, metrics, and figures
- models/           # saved model artifacts

If any of these directories are missing, create them or update notebook/script paths accordingly.

---

## Provide or download data

This project uses public RNA-seq datasets (examples below). You must either place data in `data/raw/` or run the repository's download utility (if provided).

Datasets commonly used in analyses here:
- GSE122380
- GSE131236
- GSE117192
- GSM8102175 (fetal)
- GTEx (left ventricle samples)

Ways to supply data:
- Run a download script (if present):
  python scripts/download_geo.py --accessions GSE122380 GSE131236 --out data/raw/

- Manually download processed expression tables and metadata from GEO/ENA and place them under `data/raw/` and `data/metadata/`.

Important: Ensure a metadata CSV exists that maps sample IDs to labels (e.g., day/timepoint, dataset, cell type). Notebooks expect a metadata table path — open the notebook header cells to see or update parameters.

---

## Running the pipeline

You can run the analysis in two modes: interactively via notebooks (recommended for first runs) or non-interactively using scripts.

Interactive (recommended):
1. Launch Jupyter Lab: `jupyter lab`
2. Open notebooks in `notebooks/` and run them in this suggested order:
   1. 00_data_curation.ipynb — download / organize data and build metadata
   2. 01_preprocess_normalize.ipynb — preprocessing, normalization, and batch correction (ComBat)
   3. 02_linear_baseline.ipynb — differential expression baseline analyses
   4. 03_feature_selection.ipynb — XGBoost / Random Forest non-linear feature selection
   5. 04_grn_reconstruction.ipynb — GRN reconstruction and topology calculations
   6. 05_hybrid_model.ipynb — train and evaluate hybrid classifier

If the exact notebook names differ, open the notebooks folder and follow the numbered order indicated in filenames or notebook titles.

Non-interactive (scripts) — example commands (adapt paths/names to files present in the repo):

- Download (example):
  python scripts/download_geo.py --accessions GSE122380 GSE131236 --out data/raw/

- Preprocess / normalize:
  python scripts/preprocess.py --input data/raw/ --metadata data/metadata/samples.csv --out data/processed/

- Batch correction (R script example):
  Rscript scripts/batch_correct.R data/processed/expression_raw.csv data/processed/expression_combat.csv data/metadata/samples.csv

- Train hybrid model:
  python scripts/train_model.py --config configs/train.yaml --data data/processed/expression_combat.csv --out results/

If scripts with these names aren't present, run the corresponding notebooks or inspect `scripts/` and `src/` to find actual filenames.

Automate notebooks non-interactively using papermill (good for reproducible pipelines):

  pip install papermill
  papermill notebooks/00_data_curation.ipynb notebooks/out/00_data_curation_run.ipynb -p RAW_DIR data/raw -p OUT_DIR data/processed

---

## Reproducibility & best practices

- Pin package versions using `environment.yml` or `requirements.txt`.
- Set random seeds in notebooks and scripts for sklearn, xgboost, numpy, and torch (if used).
- For large expression matrices, reduce memory pressure by using a set of highly variable genes (HVGs) during development.
- Use GPU-accelerated XGBoost if available for faster training (install xgboost with GPU support).

---

## Typical outputs

- data/processed/: normalized and ComBat-corrected expression matrices
- results/feature_importances/: CSV tables of top non-linear drivers
- results/grn/: edge lists and graph objects
- models/: saved model artifacts
- results/figures/: plots and figures used in manuscript

---

## Troubleshooting

- Missing dependencies: install from `requirements.txt` or `environment.yml`. For R steps, ensure Bioconductor packages installed via BiocManager.
- File not found: update notebook/script parameters to point to the correct data and metadata paths.
- Memory / runtime errors: run on a machine with more memory or subset the gene set during development.

---

## Contributing

Contributions welcome. Please open an issue describing the change or submit a pull request with tests and an example run.

---

## Contact & citation

If you use this code, please cite the associated manuscript (if available) or contact the repository owner via GitHub: https://github.com/SyedUmerHannan

---

## License

Add a LICENSE file to declare how the code can be reused. If there is no LICENSE file, the repository has no explicit open-source license.