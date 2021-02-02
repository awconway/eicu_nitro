library(targets)
library(ggplot2)
suppressPackageStartupMessages(library(dplyr))
library(magrittr)
suppressPackageStartupMessages(library(tidymodels))
library(embed)

devtools::load_all()

# Other predictors to add:

# response to previous dose change
# lab values other than creat?
# could we annotate the dataset to add 'predictions' from expert
# clinicians as our baseline comparison to mimic real world practice?

list(

  # Load data from bigquery -------------------------------------------------

  tar_target(eicu_conn, make_connection(billing = "eicu-273519")),


  tar_target(
    patient,
    query_cols(
      connection = eicu_conn,
      table = "patient",
      columns = "patientunitstayid,
       age,
       apacheadmissiondx,
       ethnicity,
       gender,
       admissionheight,
       admissionweight,
       unitAdmitSource,
       uniquepid,
       hospitalid"
    )
  ),

  tar_target(
    nitro,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Nitroglycerin (mcg/min)'"
    )
  ),

  tar_target(
    dobutamine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Dobutamine (mcg/kg/min)'"
    )
  ),

  # zero results returned for phenylephrine
  tar_target(
    phenylephrine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Phenylephrine (mcg/hr)'"
    )
  ),

  # only 2 patients who were on furosemide during a nitro titration
  tar_target(
    furosemide,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Furosemide (mg/hr)'"
    )
  ),
  # only 6 patients who were on norepinephrine during a nitro titration
  tar_target(
    norepinephrine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Norepinephrine (mcg/min)'"
    )
  ),

  # Propofol ml/hr or mcg/kg/min doesn't occur frequently
  tar_target(
    propofol,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Propofol (mcg/kg/min)'"
    )
  ),
  # Fentanyl ml/hr doesn't occur frequently in patients who received nitro
  tar_target(
    fentanyl,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Fentanyl (mcg/hr)'"
    )
  ),

  tar_target(
    midaz,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Midazolam (mg/hr)'"
    )
  ),

  tar_target(
    dex,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Dexmedetomidine (mcg/kg/hr)'"
    )
  ),

  tar_target(
    nicardipine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Nicardipine (mg/hr)'"
    )
  ),
  tar_target(
    amiodarone,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Amiodarone (mg/min)'"
    )
  ),

  tar_target(
    fluids,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'NSS (ml/hr)' OR
      drugname = 'IVF (ml/hr)' OR
      drugname = 'NS (ml/hr)' OR
      drugname = '0.9 Sodium Chloride (ml/hr)' OR
      drugname = 'Normal saline (ml/hr)' OR
      drugname = 'normal saline (ml/hr)' OR
      drugname = 'NACL (ml/hr)'"
    )
  ),

  tar_target(
    milrinone,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Milrinone (mcg/kg/min)'"
    )
  ),

  tar_target(
    epinephrine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Epinephrine (mcg/min)'"
    )
  ),

  tar_target(
    vasopressin,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Vasopressin (units/min)'"
    )
  ),

  tar_target(
    diltiazem,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Diltiazem (mg/hr)'"
    )
  ),

  tar_target(
    sbp_nurse_charting, query_rows(eicu_conn,
      table = "nursecharting",
      columns = "patientunitstayid,
               nursingchartoffset,
               nursingchartcelltypevalname,
               nursingchartvalue",
      rows = "nursingchartcelltypevalname = 'Non-Invasive BP Systolic'
          OR nursingchartcelltypevalname = 'Invasive BP Systolic'"
    )
  ),

  tar_target(
    pain, query_rows(eicu_conn,
      table = "nursecharting",
      columns = "patientunitstayid,
               nursingchartoffset,
               nursingchartcelltypevalname,
               nursingchartvalue",
      rows = "nursingchartcelltypevalname = 'Pain Score'"
    )
  ),

  tar_target(
    vital_aperiodic,
    query_cols(
      connection = eicu_conn,
      table = "vitalaperiodic",
      columns = "patientunitstayid,
            observationoffset,
            noninvasivesystolic"
    )
  ),
  tar_target(
    vital_periodic,
    query_cols(
      connection = eicu_conn,
      table = "vitalperiodic",
      columns = "patientunitstayid,
            observationoffset,
            systemicsystolic"
    )
  ),

  tar_target(
    apacheapsvar,
    query_cols(
      connection = eicu_conn,
      table = "apacheapsvar",
      columns = "*"
    )
  ),

  tar_target(
    apachepatientresult,
    query_cols(
      connection = eicu_conn,
      table = "apachepatientresult",
      columns = "patientunitstayid,
       apachescore,
       apacheversion"
    )
  ),

  tar_target(
    apachepredvar,
    query_cols(
      connection = eicu_conn,
      table = "apachepredvar",
      columns = "*"
    )
  ),

  tar_target(
    creat,
    query_rows(
      connection = eicu_conn,
      table = "lab",
      columns = "patientunitstayid,
      labname,
      labresultoffset,
      labresult",
      rows = "labname = 'creatinine'"
    )
  ),

  # pre-processing data into format for analysis
  tar_target(
    data_formatted,
    make_data_format(
      patient = patient,
      nitro = nitro,
      sbp_nurse_charting = sbp_nurse_charting,
      vital_aperiodic = vital_aperiodic,
      vital_periodic = vital_periodic,
      apachepatientresult = apachepatientresult,
      apachepredvar = apachepredvar,
      creat = creat,
      fentanyl = fentanyl,
      midaz = midaz,
      propofol = propofol,
      dobutamine = dobutamine,
      dex = dex,
      nicardipine = nicardipine,
      amiodarone = amiodarone,
      fluids = fluids,
      milrinone = milrinone,
      epinephrine = epinephrine,
      vasopressin = vasopressin,
      diltiazem = diltiazem,
      #this pain variable codes NAs as zero pain scores
      pain = pain,
      #combines other infusions into one variable
      create_vasoactive_col = T
    )
  ),
  # this filters out observations where the bp was taken more than
  # 15 minutes before and after a dose change
  tar_target(time_before, 15),
  tar_target(time_after, 15),
  tar_target(data_model, data_formatted %>%
    filter(
      time_pre %in% 0:time_before,
      time_post %in% 5:time_after
    ) %>%
    group_by(id) %>%
    # only the first bp within the 5-15 min timeframe after dose titration
    distinct(n_nitro, .keep_all = T) %>%
    ungroup() %>%
    na.omit()),

  tar_target(data_split, data_model %>%
    make_train_id(seed = 1, frac = 0.75)),
  tar_target(
    init_split,
    custom_rsplit(
      data_split,
      which(data_split$train == 1),
      which(data_split$train == 0)
    )
  ),
  tar_target(training, training(init_split)),
  tar_target(testing, testing(init_split)),
  tar_target(folds_index, make_kfold(training, 10, 1)),
  tar_target(folds, group_vfold_cv(folds_index,
    group = fold,
    v = 10
  )),

  # predictions need to be better than just passing
  # in the 'pre' sbp as a prediction - we'll call this the baseline
  tar_target(baseline, training %>%
    metrics(
      truth = sbp_post,
      estimate = sbp_pre
    )),

  # Base workflow with model

  tar_target(base_rec, recipe(sbp_post ~ .,
    data = training
  ) %>%
    update_role(ends_with("id"),
      new_role = "id variable"
    ) %>%
    update_role(train, new_role = "splitting indicator") %>%
    step_BoxCox(
      nitro_time, total_nitro,
      has_role("infusion")
    ) %>%
    step_center(
      all_numeric(),
      -all_outcomes(),
      -nitro_time,
      -total_nitro
    ) %>%
    step_scale(all_numeric(), -all_outcomes()) %>%
    # categorical embedding used (https://embed.tidymodels.org)
    step_lencode_glm(admitdiagnosis, outcome = vars(sbp_post)) %>%
    step_lencode_glm(unitAdmitSource, outcome = vars(sbp_post)) %>%
    step_dummy(
      all_nominal(),
      #not the variables we have used categorical embedding
      -admitdiagnosis,
      -unitAdmitSource,
      -has_role("id variable")
    )),

  tar_target(wf, workflow() %>%
    add_recipe(base_rec)),

  # linear model
  tar_target(glm, linear_reg(penalty = 0.001, mixture = 0.5) %>%
    set_engine("glmnet", nlambda = 4)),
  tar_target(
    glm_fit, wf %>%
      add_model(glm) %>%
      fit_resamples(folds)
  ),
  tar_target(glm_metrics, collect_metrics(glm_fit)),

  # xgboost model
  tar_target(boost, boost_tree() %>%
    set_mode("regression") %>%
    set_engine("xgboost")),

  tar_target(
    boost_fit,
    wf %>%
      add_model(boost) %>%
      fit_resamples(folds)
  ),
  tar_target(boost_metrics, collect_metrics(boost_fit)),

  # random forest model
  tar_target(rf, rand_forest(trees = 50) %>%
    set_engine("randomForest") %>%
    set_mode("regression")),
  tar_target(
    rf_fit,
    wf %>%
      add_model(rf) %>%
      fit_resamples(folds)
  ),
  tar_target(rf_metrics, collect_metrics(rf_fit)),


  # Lasso https://juliasilge.com/blog/lasso-the-office/

  tar_target(lasso_spec, linear_reg(
    penalty = tune(),
    mixture = 1
  ) %>%
    set_engine("glmnet")),

  tar_target(lambda_grid, dials::grid_regular(dials::penalty(),
    levels = 100
  )),


  tar_target(
    lasso_grid,
    tune_grid(
      wf %>% add_model(lasso_spec),
      resamples = folds,
      grid = lambda_grid
    )
  ),

  tar_target(lasso_metrics, lasso_grid %>%
    collect_metrics()),

  tar_target(
    lasso_plot,
    lasso_metrics %>%
      ggplot(aes(penalty, mean, color = .metric)) +
      geom_errorbar(aes(
        ymin = mean - std_err,
        ymax = mean + std_err
      ),
      alpha = 0.5
      ) +
      geom_line(size = 1.5) +
      facet_wrap(~.metric, scales = "free", nrow = 2) +
      scale_x_log10() +
      theme(legend.position = "none")
  ),

  tar_target(lasso_lowest_rmse, lasso_grid %>%
    select_best("rmse")),

  tar_target(lasso_final, finalize_workflow(
    wf %>%
      add_model(lasso_spec), lasso_lowest_rmse
  )),

  tar_target(lasso_vip_plot, lasso_final %>%
    fit(training) %>%
    pull_workflow_fit() %>%
    vip::vi(lambda = lasso_lowest_rmse$penalty) %>%
    mutate(
      Importance = abs(Importance),
      Variable = forcats::fct_reorder(Variable, Importance)
    ) %>%
    ggplot(aes(x = Importance, y = Variable, fill = Sign)) +
    geom_col() +
    scale_x_continuous(expand = c(0, 0)) +
    labs(y = NULL)),

  # Only when optimized feature selection and tuning
  # tar_target(lasso_test, last_fit(lasso_final,
                                  # init_rsplit,
                                  # metrics = metric_set(mae, rmse, rsq)
                                  # ) %>%
  #              collect_metrics())

  # Ridge regression

  tar_target(ridge_spec, linear_reg(
    penalty = tune(),
    mixture = 0
  ) %>%
    set_engine("glmnet")),


  tar_target(
    ridge_grid,
    tune_grid(
      wf %>% add_model(ridge_spec),
      resamples = folds,
      grid = lambda_grid
    )
  ),

  tar_target(ridge_metrics, ridge_grid %>%
    collect_metrics()),

  tar_target(
    ridge_plot,
    ridge_metrics %>%
      ggplot(aes(penalty, mean, color = .metric)) +
      geom_errorbar(aes(
        ymin = mean - std_err,
        ymax = mean + std_err
      ),
      alpha = 0.5
      ) +
      geom_line(size = 1.5) +
      facet_wrap(~.metric, scales = "free", nrow = 2) +
      scale_x_log10() +
      theme(legend.position = "none")
  ),

  tar_target(ridge_lowest_rmse, ridge_grid %>%
    select_best("rmse")),

  tar_target(ridge_final, finalize_workflow(
    wf %>%
      add_model(ridge_spec), ridge_lowest_rmse
  )),

  tar_target(ridge_vip_plot, ridge_final %>%
    fit(training) %>%
    pull_workflow_fit() %>%
    vip::vi(lambda = ridge_lowest_rmse$penalty) %>%
    mutate(
      Importance = abs(Importance),
      Variable = forcats::fct_reorder(Variable, Importance)
    ) %>%
    ggplot(aes(x = Importance, y = Variable, fill = Sign)) +
    geom_col() +
    scale_x_continuous(expand = c(0, 0)) +
    labs(y = NULL)),

  # Only when optimized feature selection and tuning
  # tar_target(ridge_test, last_fit(ridge_final,
  #                                 init_rsplit,
  # metrics = metric_set(mae, rmse, rsq)) %>%
  #              collect_metrics())

  # neural network: multi-layer perceptron with keras
  tar_target(keras_tune_pra, mlp(
    hidden_units = tune(),
    penalty = tune(),
    epochs = 200, #may need more but need to be careful not to overfit
    activation = "relu"
  ) %>%
    set_engine("keras") %>%
    set_mode("regression")),

  tar_target(keras_grid, keras_tune_pra %>%
    parameters() %>%
    grid_max_entropy(size = 10)),

  tar_target(keras_wflow, workflow() %>%
    add_recipe(base_rec) %>%
    add_model(keras_tune_pra)),

  tar_target(
    keras_fit,
    tune_grid(keras_wflow,
      resamples = folds,
      grid = keras_grid
    )
  ),

  tar_target(keras_metrics, keras_fit %>%
    collect_metrics()),

  # on inspection the best rmse (12.8) had 9 hidden units and 200 epochs
  # tar_target(keras_best, keras_fit$.metrics[5][[1]][5,] %>%
  #              select(hidden_units, penalty, epochs,.config)),
  #
  # tar_target(keras_final, finalize_workflow(
  #              keras_wflow, keras_best)),

  # Only when optimized feature selection and tuning
  # tar_target(keras_test, last_fit(keras_final,
  #                                 init_split,
  #                                 metrics = metric_set(mae, rmse, rsq)                                  ) %>%
  #              collect_metrics())

  # Invasive data modelling
  # only 246 patients available for time-series modelling from eicu
  tar_target(data_invasive, make_invasive(data_formatted))
)