Dementia Cohort Identification and SVM Classifier Pipeline for article ‘Machine learning-based prediction of future
dementia using routine clinical MRI brain scans and healthcare data’
================
Parminder Reel
2025-10-29



This is a comprehensive README for the Dementia Cohort Identification and SVM classifier pipeline used in the article:

***Machine learning-based prediction of future dementia using routine
clinical MRI brain scans and healthcare data***

Authors: *Parminder Singh Reel, Salim Al-Wasity, Craig Edwards, Smarti
Reel, Esma Mansouri-Benssassi, Szabolcs Suveges, Muthu Rama Krishnan
Mookiah, Susan Krueger, Emanuele Trucco, Emily Jefferson, Alexander
Doney and J. Douglas Steele.*

The Dementia Cohort Identification and SVM classifier pipeline was developed under the [PICTURES Exemplar-2 Project](https://imageonamission.ac.uk/exemplar-2/).

For any queries regarding the code contact the corresponding author at
<p.s.reel@dundee.ac.uk>

------------------------------------------------------------------------

## Table of Contents
- [Introduction](#introduction)
- [Dementia Cohort Identification Pipeline](#dementia-cohort-identification-pipeline)
    - [Overview](#overview)
    - [Prerequisites](#prerequisites)
    - [Key Scripts](#key-scripts)
    - [Data Sources](#data-sources)
- [SVM Classifier Pipeline](#svm-classifier-pipeline)
    - [Prerequisites](#prerequisites-1)  
    - [Pipeline Execution
        (Step-by-step)](#pipeline-execution-step-by-step)  
    - [Performance Metrics](#performance-metrics)  
    - [Key Parameters](#key-parameters)  
    - [Output Summary](#output-summary)
- [Funding](#funding)
- [Licence](#licence)

------------------------------------------------------------------------
# Introduction
This repository documents the methodology used in the study, encompassing both clinical cohort identification and SVM based machine learning based pipeline. The data cohort identification details how dementia and control cohorts are derived from linked healthcare records. The SVM pipeline provides a reproducible framework for model training and evaluation using T1 weighted brain MRI data, demonstrated with the publicly available IXI dataset. These components are presented independently, allowing the ML pipeline to be executed without access to restricted clinical data.

# Dementia Cohort Identification Pipeline
## Overview
The dementia and control cohorts are identifies using clinical data. This part includes R scripts that perform this step. It uses a previously validated multi-source electronic medical record (EMR) phenotyping [algorithm](https://diabetesjournals.org/care/article-lookup/doi/10.2337/dc19-0380) (Doney et al., Diabetes Care, 2019), which integrates hospital admissions (ICD coding), prescribing data (e.g. dementia-specific medications), and mortality records within longitudinal NHS data.

### Dementia Cohort
Dementia Cases were selected from GoDARTS and SHARE studies using the following four linked datasets:

1. Dispensed prescribing: This dataset includes the detailed longitudinal prescription records of all medications that are dispensed from the pharmacies to the individuals. The drugs specific to dementia i.e. Chapter 4.11 of the British National Formulary (BNF) were identified.
2. Death: The Scottish General Register Office (GRO) records information of death certification. The ICD-9 and ICD-10 codes related to dementia were identified in these certifications.
3. General hospitalisation admissions (SMR01): The general hospital inpatient and day case discharge information include the individual episode level data. The ICD-9 and ICD-10 codes related to dementia were identified in these records.
4. Psychiatric hospital discharge (SMR04): The psychiatric hospital inpatient and day case discharge information include the individual episode level data. The ICD-9 and ICD-10 related to dementia were identified from these records.

For each patient with dementia, the incident date of dementia was evaluated based on the earliest date of occurrence in any of these datasets. As EMR records are independently coded episodes over time, patients could receive codes from different dementia subtypes due to the intrinsic inaccuracy in the clinical coding. A [probabilistic model](https://diabetesjournals.org/care/article-lookup/doi/10.2337/dc19-0380) was used to assign a dementia subtype to such patients.

### Non-Dementia/Control Cohort
Non-Dementia/Control patients were selected from GoDARTS and SHARE studies and have:

1. No dementia specific drugs (Chapter 4.11 of the BNF) in the dispensed prescribing records,and
2. No ICD-9 and ICD-10 codes related to dementia in death, general hospital admissions, and psychiatric hospital discharge datasets.

## Prerequisites

### Software Requirements
- R (>= 4.0)
- Packages:
  - `dplyr`
  - `stringr`
  - `DBI`
  - `odbc`

---

## Key Scripts
The pipeline identifies patients with and without dementia using clinical records. The workflow is split into two main parts:

1. Dementia cohort construction  
2. Control cohort construction

### Dementia Cohort Construction
#### Script: `1A_Dementia_Cohort_CTRE.r`

**Purpose**

- Identify dementia patients using ICD codes from:
  - SMR01, hospital admissions  
  - SMR04, psychiatric records  
  - GRO, death records  
  - Prescribing data  

- Apply a probabilistic model to assign dementia subtype:
  - Alzheimer’s disease  
  - Vascular dementia  
  - Other dementia  
  - Unspecified dementia  

**Outputs**

- `All_Dementia_patients.csv`  

---

### Control Cohort Construction

#### Script: `1B_Controls_Cohort_CTRE.r`

**Purpose**

- Remove all dementia patients  
- Identify individuals with no dementia records  
- Link to imaging metadata  
- Extract follow up information from clinical datasets  
- Compute latest date of follow up  

**Outputs**

- `All_Non_Dementia_patients.csv`  

---
## Data Sources
The pipeline uses:

- Clinical databases
  - SMR01, hospital admissions  
  - SMR04, psychiatric admissions  
  - GRO, death records  
  - Prescribing data

Note, current scripts connect to an SQL server. In other environments, these should be adapted to CSV inputs.

---

# SVM Classifier Pipeline
This SVM Pipeline uses [SPM](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) and [MATLAB](https://uk.mathworks.com/). For demonstration purpose, it
uses publicly available T1 Brain scans from [IXI database](https://brain-development.org/ixi-dataset/) 
for the entire workflow and describes configuration, outputs, and how to run the pipeline.
## Prerequisites

### Software Requirements

- **[MATLAB](https://uk.mathworks.com/)** R2021b or later
- **SPM12** ([Statistical Parametric Mapping toolbox](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/))
- **[Parallel Computing Toolbox](https://uk.mathworks.com/products/parallel-computing.html)** (for distributed jobs)
- **[IXI Dataset](https://brain-development.org/ixi-dataset/)** (T1-weighted MRI scans)

------------------------------------------------------------------------

## Pipeline Execution (Step-by-step)

Below is a detailed, practical breakdown of each pipeline stage. Each
step includes the **purpose**, **rationale**, and **commands** to run
the step.

------------------------------------------------------------------------

### Step 0 — Download and Preparation of T1 Brain Scans

**Purpose & Rationale**  
The data related to the classification results presented in this article can only be
accessed within the HIC TRE subject to ethical and governance approvals.
Therefore, publicly accessible T1 Brain Scans from IXI data is used to
demonstrate the functional pipeline. Also, create a single master table
that links IXI metadata to MRI file paths and produces the binary
classification labels using patient age. This is critical because
downstream cross-validation and stratification depend on accurate
mapping between subjects and images.

**Download** T1 Brain Scans from
(<https://brain-development.org/ixi-dataset/>)

**Command**

``` matlab
srun -n1 -N1 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; setup_IXI_data"
```

------------------------------------------------------------------------

### Step 1 — Nested K-Fold Split Generation

**Purpose & Rationale**  
Implement nested cross-validation to provide an unbiased estimate of
generalization and to separate model selection (inner loop) from
performance estimation (outer loop).

**Command**

``` matlab
srun -n1 -N1 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step1"
```

------------------------------------------------------------------------

### Step 2 — Job Driver Generation

**Purpose & Rationale**  
Produce job driver tables that enumerate all independent combinations of
outer/inner folds, p-thresholds, and hyperparameters. These tables
enable parallel dispatch to cluster nodes or local workers and act as
reproducible experiment manifests.

**Command**

``` matlab
srun -n1 -N1 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step2_alt"
```

------------------------------------------------------------------------

### Step 3 — MRI Preprocessing and Voxel-wise t-Test Feature Selection (SPM12)

**Purpose & Rationale**  
Standardize all images to a common anatomical space (MNI) and segment
tissue classes. SPM’s unified segmentation + normalization or
shoot/DARTEL produce images that are comparable across subjects and
suitable for voxelwise statistics. Perform voxel-wise statistical tests
to detect voxels showing significant group differences. Masks derived
from these p-values reduce dimensionality and help focus the classifier
on biologically plausible regions.

**Command**

``` matlab
srun -n25 -N25 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step3_alt"
```

------------------------------------------------------------------------

### Step 4 — Inner Loop SVM Training & Validation

**Purpose & Rationale**  
Train SVM classifiers on masked voxel features and evaluate on held-out
inner folds to estimate performance of each hyperparameter combination.

**Command**

``` matlab
srun -n128 -N64 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step4_alt"
srun -n1 -N1 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step4a"
```

------------------------------------------------------------------------

### Step 5 — Hyperparameter Optimisation

**Purpose & Rationale**  
Aggregate inner-fold results to select the best hyperparameter
configuration for each outer fold without tapping into outer test data.

**Command**

``` matlab
srun -n5 -N5 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step5"
```

------------------------------------------------------------------------

### Step 6 — Outer Loop Final Training & Testing

**Purpose & Rationale**  
Use the chosen hyperparameters to train a final model on the full outer
training set and evaluate on the outer test set to estimate
generalisation.

**Command**

``` matlab
srun -n5 -N5 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step6_alt"
```

------------------------------------------------------------------------

### Step 7 — Validation, Aggregation & Reporting

**Purpose & Rationale**  
Validate that all jobs completed correctly, aggregate fold-level
results, compute summary statistics, and prepare a report for
publication or further analysis.

**Command**

``` matlab
srun -n1 -N1 /usr/local/MATLAB/R2021b/bin/matlab -nosplash -r "Rseed= 1; Step7_alt"
```

------------------------------------------------------------------------

## Performance Metrics

The pipeline records a comprehensive set of performance metrics for each
evaluation. Each metric is saved per job and aggregated across folds.

**Per-model / per-fold metrics**

- **ACC** — Accuracy (correct predictions / total observations)
- **AUC** — Area Under ROC Curve (discrimination performance)
- **SENS** — Sensitivity / True Positive Rate
- **SPEC** — Specificity / True Negative Rate
- **PPV** — Positive Predictive Value
- **NPV** — Negative Predictive Value
- **NUM_OBS** — Number of observations in test set
- **Confusion matrix entries** — `CM11`, `CM12`, `CM21`, `CM22`

------------------------------------------------------------------------

## Key Parameters

Below are the most important configuration variables controlling the
experiment. Keep track of them in `config_experiment.m`.

- `seed` — random seed for reproducibility (e.g., `42`)
- `kFolds_outer` — number of outer folds (e.g., `5`)
- `kFolds_inner` — number of inner folds (e.g., `3`)
- `p_Thres_range` — p-value thresholds for mask creation (e.g.,
  `[0.01 0.001 0.0001]`)
- `C_value_range` — SVM regularization constants (e.g.,
  `[0.01 0.1 1 10]`)
- `K_value` — kernel scale parameter when using Gaussian/RBF
- `spmpath` — path to SPM12 installation
- `imagespath` — path to preprocessed images
- `ttestoutpath`, `driverpath`, `outertraintestpath`,
  `innertraintestpath` — output directories
- `min_p`, `max_p`, `min_C`, `max_C` — ranges for final summary
  bookkeeping

------------------------------------------------------------------------

## Output Summary

A consistent directory & filename convention is used so downstream
analysis is straightforward.

**Top-level output directories**

- `ttestout/` — p-matrix and binary masks
  (`{outer}_{inner}_ttest2_result.mat`, `{p}_binarymask.mat`)
- `innertraintest/` — inner fold training/validation CSVs and per-worker
  logs
- `outertraintest/` — outer fold evaluation CSVs and predictions
- `splits/` — outer/inner split CSVs
- `driver/` — driver CSVs used to distribute work
- `runtime_log/` — step-wise runtime logs (Step1_runtime.txt, etc.)

**Important file formats**

- `.mat` — MATLAB data objects (p-matrix, masked volumes, saved SVM
  models)
- `.csv` — human-readable driver & results tables
- `.nii` — neuroimaging volumes (preprocessed tissue maps)
- `.txt` — runtime or completion flags

**Example final artifacts**

- `outer_fold_summary.csv` — final performance summary across outer
  folds
- `Inner_loop_validated.txt` — indicates all inner jobs completed
- `final_masks/` — best masks for each outer fold (for interpretation)
- `predictions/` — subject-level predicted labels & decision scores

------------------------------------------------------------------------
# Funding

This work was funded by the Medical Research Council (MRC) MICA 
Programme Grant: InterdisciPlInary Collaboration for efficienT and
effective Use of clinical images in big data health care RESearch:
PICTURES (MR/S010351/1).

------------------------------------------------------------------------
# Licence

This code is licenced under the [MIT License](https://choosealicense.com/licenses/mit/).

------------------------------------------------------------------------
