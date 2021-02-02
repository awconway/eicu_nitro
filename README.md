
# Predicting blood pressure changes after nitroglcerin dose titration using the eicu dataset

<!-- badges: start -->
<!-- badges: end -->

This repository holds the source code to conduct an analysis of the [eicu](https://eicu-crd.mit.edu) dataset. The goal is to predict changes in blood pressure after a nitroglycerin dose titration. The [targets](https://github.com/ropensci/targets) `R` package was used to manage the analysis workflow. Steps in the workflow are in the `_targets.R` file.

## Connecting to the eicu bigquery database

- Follow the instructions to gain access through [physionet](https://eicu-crd.mit.edu)
- Add your bigquery project name (used for billing) to _targets.R in the `eicu_conn` target

## Adding new predictors

There are two functions in this package that will assist querying the eicu database. Below are instructions for adding new predictors from the eicu dataset to the modelling workflow.

### 'Fixed' predictors (i.e. won't change throughout hospitalization, like age, admission diagnoses etc.):

If the variable is in one of the tables where a query already exists, you can just modify the query in `_targets.R` to insert the column name from the eicu bigquery table into the columns argument in `query_cols`. Then, include the name of that variable in the very last select function in `make_data_format`.

If the variable is in a table not already included in a query, then you can add a new query. `query_cols` will let you select just columns of particular tables in eicu where the `patientunitstayid` variable matches with any entry in the `infusiondrug` table where a dose of nitroglycerin was administered.

The result of a new query (i.e. the target), should be passed first to the `make_data_format` function in the _targets.R workflow. Within the `make_data_format` function, the target name will need to be added as an argument and steps included for preprocessing it before it can be included as a predictor in the model.

First, convert the variable name with the value you want to include in the model as a predictor to be more descriptive and include a suffix to indicate if it is an infusion (_inf), lab result (_lab) or some type of rating scale score (_score), such as pain (e.g. converted to 'pain_score').

```r
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

```r
full_join(apachepredvar,
      by = "patientunitstayid"
    ) %>%
```

Then, include the name of that variable in the very last select function in `make_data_format`.

>As shown for the apachepredvar table above, some additional steps may be required to convert the variable to a proper format for modelling (i.e. factor or numeric). Inspect results and warning carefully when adding new predictors to the modelling workflow.

### 'Time-varying' predictors (e.g. doses of infusions, lab results etc)

`query_rows` does the same as query_cols with the added condition of being able to filter rows that meet a specific condition. For example, in the `norepinephrine` target, the query uses the condition "drugname = 'Norepinephrine (mcg/min)'" to only retrieve instances from the `infusiondrug` table where a dose of norepinephrine was entered.

The result of a new query (i.e. the target), should be passed first to the `make_data_format` function in the _targets.R workflow. Within the `make_data_format` function, the target name will need to be added as an argument and steps included for preprocessing it before it can be included as a predictor in the model.

First, convert the variable name with the value you want to include in the model as a predictor to be more descriptive and include a suffix to indicate if it is an infusion (_inf), lab result (_lab) or some type of rating scale score (_score), such as pain (e.g. converted to 'pain_score').

```r
pain <- pain %>%
    type.convert() %>%
    mutate(pain_score = as.numeric(nursingchartvalue)) %>%
    select(-nursingchartvalue, -nursingchartvalue)
```

The new result should be joined to the results of other queries by the `patientunitstayid` variable. Also, to ensure the 'offset' variable gets recoded to a new variable called 'time', we need to first rename it to a consistent term, which is `infusionoffset`.

```r
full_join(pain,
      by = c("infusionoffset" = "nursingchartoffset", "patientunitstayid")
    ) %>%
```

>Some additional steps may be required to convert the variable to a proper format for modelling (i.e. factor or numeric). Inspect results and warning carefully when adding new predictors to the modelling workflow.

## Resampling

The `init_split` target produces an object of type rsplit, which is used to create the training and testing datasets used in subsequent steps in the modelling workflow. This `init_split` object uses a custom approach to the typical `initial_split()` function from tidymodels. This custom approach was needed because the data set used in the modelling includes multiple dose titrations from the same patients throughout their hospitalization. The custom function `custom_rsplit` ensures there are no patients included in both the training and testing sets.

## Preprocessing

This modelling workflow uses the tidymodels package to manage all steps of the workflow. All steps are included in the `_targets.R` file. As an example, the `base_rec` target contains the preprocessing steps for the subsequent models. These steps can be modified or new recipes developed instead to pass into the subsequent modelling steps.

## Running the workflow after adding predictors

If any predictors are added or functions changed, then you will need to run the following code to execute the workflow:

```r 
devtools::document()
devtools::load_all()
run_pipeline()
```

If no predictors are added or functions changed, `targets::tar_make()` is all that is needed to run the workflow.