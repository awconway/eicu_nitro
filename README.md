# Predicting blood pressure changes after nitroglcerin dose titration using the eicu dataset

<!-- badges: start -->

![Docker Cloud Build Status](<https://img.shields.io/docker/cloud/build/awconway/eicu_nitro)

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
bigquery::bq_auth(email = "your gmail address associated with physionet account",
                  use_oob = TRUE)
```

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

This modelling workflow uses the tidymodels package to manage all steps of the workflow. All steps are included in the `_targets.R` file. As an example, the `base_rec` target contains the preprocessing steps for the subsequent models. These steps can be modified or new recipes developed instead to pass into the subsequent modelling steps.

## Running the workflow after adding predictors

If any predictors are added or functions changed, then you will need to run the following code to execute the workflow:

``` r
devtools::document()
devtools::load_all()
run_pipeline()
```

If no predictors are added or functions changed, `targets::tar_make()` is all that is needed to run the workflow.
