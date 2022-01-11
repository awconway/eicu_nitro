# Predicting blood pressure changes after nitroglcerin dose titration using the eicu dataset

<!-- badges: start -->

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/awconway/eicu_nitro)

<!-- badges: end -->

This repository holds the source code to conduct an analysis of the [eicu](https://eicu-crd.mit.edu) dataset. The goal is to predict changes in blood pressure after a nitroglycerin dose titration. The [targets](https://github.com/ropensci/targets) `R` package was used to manage the analysis workflow. Steps in the workflow are in the `_targets.R` file.

## Reproducible analysis with Docker

The statistical anlyses requires various packages to be installed, and may not work properly if package versions have changed. Therefore, a [Docker image is provided](https://hub.docker.com/repository/docker/awconway/eicu_nitro) to run the code reproducibly.

### Run Docker locally

**If you already have [docker](https://docs.docker.com/install/) installed**

  - Run the following in a terminal:

<!-- end list -->

    docker run -e PASSWORD=mu -p 8787:8787 awconway/eicu_nitro

  - Open a web browser and go to: localhost:8787
  - Enter rstudio as the username and mu as the password to enter an RStudio session.
  - Create a new project from version control (File \> New project \> Version Control \> Git \> <https://github.com/awconway/eicu_nitro.git> )

### Run Docker on a Cloud

Instead of installing docker on your system you can run it on a remote server, such as [Digital Ocean](https://www.digitialocean.com). This [link](https://m.do.co/c/89cf8df06791) provides you with $100 free credit to use for a 60-day period. After signing up, follow these steps to run this project on a Digital Ocean droplet:

  - Create a DigitalOcean droplet. Choose a server with Docker installed from the *Marketplace* menu and choose a size for your server (number of CPUs and amount of RAM). It would be best to choose a server with at least 16GB RAM.

  - Select `User data` from the `Select additional options` section and enter the text as displayed below.

<!-- end list -->

    #cloud-config
    runcmd:
      - docker run -e PASSWORD=mu -p 8787:8787 awconway/eicu_nitro

  - Create the droplet.

  - Wait a few minutes for the docker image to load into the server then open a web browser and type in the ip address of the droplet you just created followed by the port 8787 (e.g. ipaddress:8787).

  - Enter rstudio as the username and mu as the password to enter an RStudio session.

  - Create a new project from version control (File \> New project \> Version Control \> Git \> <https://github.com/awconway/eicu_nitro.git> )

>*Destroy the DigitalOcean droplet when finished inspecting the analyses*

## Connecting to the eicu bigquery database

First, follow the instructions to gain access through [physionet](https://eicu-crd.mit.edu). Once you have access to the data on bigquery, run the following code in the RStudio session and follow instructions in a pop-up browser to copy your token to the console:

```r
bigrquery::bq_auth(email = "your gmail address associated with physionet account",
                  use_oob = TRUE)
```

>Make sure to select to allow access to bigquery

## Adding new predictors

There are two functions in this package that will assist querying the eicu database. Below are instructions for adding new predictors from the eicu dataset to the modelling workflow.

### 'Fixed' predictors (i.e. won't change throughout hospitalization, like age, admission diagnoses etc.):

If the variable is in one of the tables where a query already exists, you can just modify the query in `_targets.R` to insert the column name from the eicu bigquery table into the columns argument in `query_cols`. Then, include the name of that variable in the very last select function in `make_data_format`.

If the variable is in a table not already included in a query, then you can add a new query. `query_cols` will let you select just columns of particular tables in eicu where the `patientunitstayid` variable matches with any entry in the `infusiondrug` table where a dose of nitroglycerin was administered.

The result of a new query (i.e. the target), should be passed first to the `make_data_format` function in the \_targets.R workflow. Within the `make_data_format` function, the target name will need to be added as an argument and steps included for preprocessing it before it can be included as a predictor in the model.

First, convert the variable name with the value you want to include in the model as a predictor to be more descriptive and include a suffix to indicate if it is an infusion (\_inf), lab result (\_lab) or some type of rating scale score (\_score), such as pain (e.g. converted to 'pain_score').

``` r
apachepredvar <- apachepredvar %>%
    select(
      patientunitstayid, admitdiagnosis, diabetes
    ) %>%
    type.convert() %>%
    mutate(diabetes = factor(diabetes,
      levels = c(0, 1),
      ordered = FALSE
    ))
```

The new result should be joined to the results of other queries by the `patientunitstayid` variable.

``` r
full_join(apachepredvar,
      by = "patientunitstayid"
    ) %>%
```

Then, include the name of that variable in the very last select function in `make_data_format`.

> As shown for the apachepredvar table above, some additional steps may be required to convert the variable to a proper format for modelling (i.e. factor or numeric). Inspect results and warning carefully when adding new predictors to the modelling workflow.

### 'Time-varying' predictors (e.g. doses of infusions, lab results etc)

`query_rows` does the same as query_cols with the added condition of being able to filter rows that meet a specific condition. For example, in the `norepinephrine` target, the query uses the condition "drugname = 'Norepinephrine (mcg/min)'" to only retrieve instances from the `infusiondrug` table where a dose of norepinephrine was entered.

The result of a new query (i.e. the target), should be passed first to the `make_data_format` function in the \_targets.R workflow. Within the `make_data_format` function, the target name will need to be added as an argument and steps included for preprocessing it before it can be included as a predictor in the model.

First, convert the variable name with the value you want to include in the model as a predictor to be more descriptive and include a suffix to indicate if it is an infusion (\_inf), lab result (\_lab) or some type of rating scale score (\_score), such as pain (e.g. converted to 'pain_score').

``` r
pain <- pain %>%
    type.convert() %>%
    mutate(pain_score = as.numeric(nursingchartvalue)) %>%
    select(-nursingchartvalue, -nursingchartvalue)
```

The new result should be joined to the results of other queries by the `patientunitstayid` variable. Also, to ensure the 'offset' variable gets recoded to a new variable called 'time', we need to first rename it to a consistent term, which is `infusionoffset`.

``` r
full_join(pain,
      by = c("infusionoffset" = "nursingchartoffset", "patientunitstayid")
    ) %>%
```

> Some additional steps may be required to convert the variable to a proper format for modelling (i.e. factor or numeric). Inspect results and warning carefully when adding new predictors to the modelling workflow.

## Resampling

The `init_split` target produces an object of type rsplit, which is used to create the training and testing datasets used in subsequent steps in the modelling workflow. This `init_split` object uses a custom approach to the typical `initial_split()` function from tidymodels. This custom approach was needed because the data set used in the modelling includes multiple dose titrations from the same patients throughout their hospitalization. The custom function `custom_rsplit` ensures there are no patients included in both the training and testing sets.

## Preprocessing

This modelling workflow uses the tidymodels (to run the models) and targets (to store model results) packages to manage all steps of the workflow. All steps are included in Rmarkdown files that end in Targets. We will refer to these as `target markdown` files (as per the language used in the targets package). As an example, the `lassoTargets.Rmd` target markdown file contains the model specification and preprocessing steps used to evaluate optimal parameters for a LASSO model. These steps can be modified or new recipes developed instead to pass into the subsequent modelling steps. 

**If changes are made to the code chunks in a target markdown file, the file should be 'knitted' before the workflow is executed (i.e. before runnding `targets::tar_make()`).**

## Running the workflow after adding predictors

If any predictors are added or functions changed, then you will need to run the following code to execute the workflow:

``` r
devtools::document()
install.packages('.') #installs the functions in the R folder
```

If no predictors are added or functions changed, `targets::tar_make()` is all that is needed to run the workflow.

## Target structure

  <pre style="font-family:Menlo,'DejaVu Sans Mono',consolas,'Courier New',monospace">📦️ eicu_nitro
        ┣━━ 📄 <span style="font-weight: bold;"><a href="globalTargets.Rmd">globalTargets.Rmd</a></span>
        ┃   ┗━━ 🎯 globalpackages <span style="color:#808080"> - global options/functions common to all targets</span>
        ┣━━ 📄 <span style="font-weight: bold;"><a href="bigquery.Rmd">bigquery.Rmd</a></span>
        ┃   ┣━━ 🎯 eicu_conn <span style="color:#808080"> - connection to bigquery database</span>
        ┃   ┣━━ 🎯 patient <span style="color:#808080"> - patient table in eicu</span>
        ┃   ┣━━ 🎯 nitro <span style="color:#808080"> - nitro doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 dobutamine <span style="color:#808080"> - dobutamine doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 phenylephrine <span style="color:#808080"> - phenylephrine doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 furosemide <span style="color:#808080"> - furosemide doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 propofol <span style="color:#808080"> - propofol doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 norepinephrine <span style="color:#808080"> - norepinephrine doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 fentanyl <span style="color:#808080"> - fentanyl doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 midaz <span style="color:#808080"> - midazolam doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 dex <span style="color:#808080"> - Dexmedetomidine doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 nicardipine <span style="color:#808080"> - nicardipine doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 amiodarone <span style="color:#808080"> - amiodarone doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 fluids <span style="color:#808080"> - fluids doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 milrinone <span style="color:#808080"> - milrinone doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 epinephrine <span style="color:#808080"> - epinephrine doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 vasopressin <span style="color:#808080"> - vasopressin doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 diltiazem <span style="color:#808080"> - diltiazem doses from infusiondrug table in eicu</span>
        ┃   ┣━━ 🎯 sbpNurseCharting <span style="color:#808080"> - systolic blood pressure doses from nursecharting table in eicu</span>
        ┃   ┣━━ 🎯 pain <span style="color:#808080"> - pain scores from nursecharting table in eicu</span>
        ┃   ┣━━ 🎯 vital_aperiodic <span style="color:#808080"> - non-invasive systolic blood pressure measurements from vitalaperiodic table in eicu</span>
        ┃   ┣━━ 🎯 vital_periodic <span style="color:#808080"> - invasive systolic blood pressure measurements from vitalperiodic table in eicu</span>
        ┃   ┣━━ 🎯 apacheapsvar <span style="color:#808080"> - apache scores from apacheapsvar table in eicu</span>
        ┃   ┣━━ 🎯 apachepatientresult <span style="color:#808080"> - components of apache scores from apachepatientresult table in eicu</span>
        ┃   ┣━━ 🎯 apachepredvar <span style="color:#808080"> - variables for apache scores from apachepredvar table in eicu</span>
        ┃   ┗━━ 🎯 creat <span style="color:#808080"> - creatinine measurements from lab table in eicu</span>
        ┣━━ 📄 <span style="font-weight: bold;"><a href="preprocessing.Rmd">preprocessing.Rmd</a></span>
        ┃   ┣━━ 🎯 joinedTables <span style="color:#808080"> - joins dataframes of targets produced from the bigquery.Rmd file</span>
        ┃   ┣━━ 🎯 dataFormattedRaw <span style="color:#808080"> - Processes data into the format needed for analysis</span>
        ┃   ┗━━ 🎯 dataFormatted <span style="color:#808080"> - filter out nitro dose titrations that don't fit the typical approach used for titration by nurses</span>
        ┣━━ 📄 <span style="font-weight: bold;"><a href="dataModel.Rmd">dataModel.Rmd</a></span>
        ┃   ┣━━ 🎯 timeBefore <span style="color:#808080"> - filter out observations where the bp was measured more than 15 minutes before a dose change</span>
        ┃   ┣━━ 🎯 timeAfter <span style="color:#808080"> - filter out observations where the bp was measured more than 15 minutes before and after a dose change</span>
        ┃   ┣━━ 🎯 dataModel <span style="color:#808080"> - filter data to only the first bp within the 5-15 min timeframe after dose titration</span>
        ┃   ┣━━ 🎯 splitId <span style="color:#808080"> - makes an id for splitting into training/testing that ensures no observations from individual participants are in both samples</span>
        ┃   ┣━━ 🎯 initSplit <span style="color:#808080"> - creates initial split object for use in tidymodels workflow</span>
        ┃   ┣━━ 🎯 training <span style="color:#808080"> - training data comprising 75% of total observations</span>
        ┃   ┣━━ 🎯 testing <span style="color:#808080"> - testing data comprising 25% of total observations</span>
        ┃   ┣━━ 🎯 foldsIndex <span style="color:#808080"> - makes an id for crossfold validation that ensures no observations from individual participants are in both samples</span>
        ┃   ┣━━ 🎯 foldsFive  <span style="color:#808080"> - creates folds for 5-fold cross-validation</span>                                                     
        ┃   ┣━━ 🎯 baselineTraining  <span style="color:#808080"> - baseline metric for comparison in training - predictions need to be better than just passing in the 'pre' sbp as a prediction</span>
        ┃   ┗━━ 🎯 baselineTesting  <span style="color:#808080"> - baseline metric for comparison in testing - predictions need to be better than just passing in the 'pre' sbp as a prediction</span>
        ┣━━ 📄 <span style="font-weight: bold;"><a href="modelSetup.Rmd">modelSetup.Rmd</a></span>
        ┃   ┣━━ 🎯 mset <span style="color:#808080"> - use rmse for metrics</span>
        ┃   ┣━━ 🎯 control <span style="color:#808080"> - save predictions when using tune_grid()</span>
        ┃   ┗━━ 🎯 controlResamples <span style="color:#808080"> - save predictions when using fit_resamples()</span>
        ┣━━ 📄 <span style="font-weight: bold;"><a href="lassoTargets.Rmd">lassoTargets.Rmd</a></span>
        ┃   ┣━━ 🎯 specLasso <span style="color:#808080"> - model specifications</span>
        ┃   ┣━━ 🎯 gridLasso <span style="color:#808080"> - grid for tuning</span>
        ┃   ┣━━ 🎯 recLasso <span style="color:#808080"> - recipe for the model</span>
        ┃   ┣━━ 🎯 workflowLasso <span style="color:#808080"> - workflow for the model</span>
        ┃   ┣━━ 🎯 tuningLasso <span style="color:#808080"> - trained models using 5-fold cross-validation</span>
        ┃   ┗━━ 🎯 lassoFinal <span style="color:#808080"> - final fit using best model from parameter tuning</span>
        ┣━━ 📄 <span style="font-weight: bold;"><a href="lassoEval.Rmd">lassoEval.Rmd</a></span>
        ┃   ┗━━ 📊 Evaluation of models
        ┣━━ 📄 <span style="font-weight: bold;"><a href="boostTargets.Rmd">boostTargets.Rmd</a></span>
        ┃   ┣━━ 🎯 specBoost <span style="color:#808080"> - model specifications</span>
        ┃   ┣━━ 🎯 gridBoost <span style="color:#808080"> - grid for tuning</span>
        ┃   ┣━━ 🎯 recBoost <span style="color:#808080"> - recipe for the model</span>
        ┃   ┣━━ 🎯 workflowBoost <span style="color:#808080"> - workflow for the model</span>
        ┃   ┣━━ 🎯 resampleBoost <span style="color:#808080"> - trained models using 5-fold cross-validation</span>
        ┃   ┗━━ 🎯 boostFinal <span style="color:#808080"> - final fit using best model from parameter tuning</span>
        ┗━━ 📄 <span style="font-weight: bold;"><a href="boostEval.Rmd">boostEval.Rmd</a></span>
            ┗━━ 📊 Evaluation of models
</pre>
    