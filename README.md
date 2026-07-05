# cardiomyocyte_maturation
Interpretable ML framework to identify transcriptomic signatures of iPSC-CM maturation . This repository uses RNA-seq data to isolate non-linear biomarkers via XGBoost and Random Forest, integrating Gene Regulatory Network (GRN) topology into a hybrid predictive engine to classify maturity states and identify maturation barriers.
# **Machine Learning Identification of Transcriptomic Signatures of iPSC-Derived Cardiomyocyte Maturation**

Human induced pluripotent stem cell-derived cardiomyocytes (**iPSC-CMs**) are essential for disease modeling and regenerative medicine, yet they are limited by an **immature phenotype** that resembles fetal rather than adult cells. This immaturity affects critical biological properties, including **metabolic activity, sarcomere organization, calcium handling, and electrophysiological behavior**. This repository provides an **interpretable machine learning framework** to bridge this maturation gap by identifying the molecular signatures that distinguish immature cells from mature adult cardiomyocytes.

### **Core Methodology**
The project implements a six-step pipeline designed to identify complex molecular drivers of maturation:

1.  **Automated Data Curation:** Querying and downloading raw bulk RNA-seq datasets (e.g., **GSE122380**, **GSE131236**) and organizing them into standardized metadata buckets based on cell type and chronological culture day.
2.  **Normalization & Batch Correction:** Utilizing the **ComBat package** to neutralize platform-specific batch effects, resulting in a single, unified master gene expression matrix mapped to gene symbols.
3.  **Linear vs. Non-Linear Feature Selection:** After establishing a baseline of linear markers via traditional differential expression, the framework employs **XGBoost and Random Forest** to isolate "**Non-Linear Biomarkers**". These are high-importance genes often discarded by traditional statistics due to complex patterns like biphasic curves or threshold-switch behaviors.
4.  **Topological GRN Reconstruction:** Mapping interactions between markers to build **Gene Regulatory Networks (GRNs)**. The framework computes stage-specific properties for every gene, including **node degree, hub centrality, and local clustering coefficients**.
5.  **Hybrid Predictive Modeling:** A final **Hybrid Random Forest/XGBoost Classifier** is trained on a multi-dimensional input space that fuses gene expression data with network topology metrics. This allows the model to evaluate cell status based on how well a gene is integrated into its functional network hub.

### **Datasets Integrated**
The framework draws on a diverse array of data modalities to ensure robust classification:
*   **GSE122380:** A longitudinal time series across 16 time points.
*   **GSE131236:** Normal cells at 30 and 90-day maturation stages.
*   **GTEx LV:** Normal adult tissue samples used as a mature benchmark.
*   **GSM8102175:** Fetal cell data for immature benchmarking.
*   **GSE117192:** Comparative stress-response data (Hypoxia vs. Normoxia).

### **Key Deliverables**
*   **Non-Linear Driver Index:** A catalog of transcriptomic drivers of maturation that traditional differential expression analysis fails to detect.
*   **Stage-Specific GRN Profiles:** Visual and mathematical representations of how gene interactions shift during the transition from embryonic to adult phenotypes.
*   **Hybrid Maturity Engine:** A trained and optimized predictive framework that combines expression and topology to accurately classify iPSC-CM maturity states.
*   **Maturation Barrier Assessment:** Analytical pinpointing of specific network nodes where in vitro cultures deviate from native adult tissue pathways, providing targets for future intervention.
