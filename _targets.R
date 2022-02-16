library(targets)
library(tidymodels)
library(dplyr)

options(tidyverse.quiet = TRUE)

tar_option_set(packages = c(
  "tidymodels", "ggplot2", 'bigrquery',
  "dplyr", "eicu", "finetune"
))

list(
    tar_target(eicu_conn, dbConnect(bigquery(),
    project = "physionet-data",
    dataset = "eicu_crd",
    # billing = 'eicu-273519',
    billing = 'sapient-pen-274417',
  )),
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
  tar_target(joinedTables, {
    join_tables(
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
      # this pain variable codes NAs as zero pain scores
      pain = pain
    )
  }),
  tar_target(dataFormattedRaw, {
    make_data_format(joinedTables)
  }),
  tar_target(
    data_formatted,
    dataFormattedRaw |>
      mutate(
        nitro_diff_mcg = nitro_post - nitro_pre
      ) |>
      # probably most resembling policy
      filter(
        sbp_pre <= 200, # shouldn't filter out post >200
        sbp_pre >= 25,
        sbp_post >= 25,
        nitro_pre <= 50,
        nitro_diff_mcg <= 20,
        nitro_diff_mcg >= -20
      )
  ),
  tar_target(time_before, 15),
  tar_target(time_after, 15),
  tar_target(dataModel, data_formatted |>
    filter(
      time_pre %in% 0:time_before,
      time_post %in% 5:time_after
    ) |>
    group_by(id) |>
    # only the first bp within the 5-15 min timeframe after dose titration
    distinct(n_nitro, .keep_all = T) |>
    ungroup() |>
    mutate(sbp_diff = sbp_post - sbp_pre, no_diff = 0)|>
    na.omit()),
  tar_target(training, dataModel),
  tar_target(foldsIndex, make_kfold(dataModel, 5)),
  tar_target(foldsFive, 
  group_vfold_cv(foldsIndex,
    group = fold,
    v = 5
  )),
  tar_target(baselineTraining, training |>
    metrics(
      truth = sbp_post,
      estimate = sbp_pre
    )),
    # use rmse for metrics
  tar_target(
    mset,
    metric_set(rmse)
  ),
  tar_target(
    control,
    control_grid(
      save_workflow = TRUE,
      save_pred = TRUE,
      extract = extract_model
    )
  ),
  tar_target(
    controlResamples,
    control_resamples(
      save_workflow = TRUE,
      save_pred = TRUE,
      extract = extract_model
    )
  ),
  # lasso model
  tar_target(specLasso, {
    linear_reg(
      penalty = tune(),
      mixture = 1
    ) |>
      set_engine("glmnet")
}),

tar_target(gridLasso, {
  dials::grid_regular(dials::penalty(),
                      levels = 100
  )
}),

tar_target(multiples, {
  dataModel |> 
  group_by (id) |>
  count() |>
  arrange(desc(n)) |>
  filter(n > 1) |>
  pull (id)
}),
tar_target(trainingResponse, {
   dataModel |> 
    filter(id %in% multiples) |>
    group_by(id) |>
    mutate(lag_nitro_pre = lag(nitro_pre), 
           lag_nitro_post = lag(nitro_post),
            lag_sbp_pre = lag(sbp_pre),
           lag_sbp_post = lag(sbp_post),
           lag_nitro_diff = lag_nitro_post - lag_nitro_pre,
           lag_sbp_diff = lag_sbp_post - lag_sbp_pre) |> 
    mutate(first_titration = row_number(n_nitro)) |>
    filter(first_titration != 1) |> 
  ungroup()
}),
  tar_target(foldsIndexResponse, make_kfold(trainingResponse, 5)),
  tar_target(foldsFiveResponse, 
  group_vfold_cv(foldsIndexResponse,
    group = fold,
    v = 5
  )),
   tar_target(baselineTrainingResponse, trainingResponse |>
    metrics(
      truth = sbp_post,
      estimate = sbp_pre
    )),
tar_target(recLassoResponse, {
  recipe(sbp_post ~
  sbp_pre +
    nitro_diff_mcg +
    total_nitro +
    n_nitro +
    nitro_time +
     sbp_pre_mean_60 +
     sbp_pre_sd_60 +
    lag_nitro_diff +
    lag_sbp_diff,
    data = trainingResponse
  ) |>
    step_YeoJohnson(
      n_nitro, nitro_time, total_nitro, sbp_pre_sd_60
    ) |>
    step_normalize(
      all_numeric_predictors()
    )|>
    step_pca(
    sbp_pre_mean_60,
    sbp_pre
    ) |> 
  step_interact(terms = ~lag_nitro_diff:lag_sbp_diff)  #This is the interaction term
}),
tar_target(workflowLassoResponse, {
  workflow()|>
    add_recipe(recLassoResponse)|>
    add_model(specLasso)
}),
tar_target(tuningLassoResponse, {
      tune_grid(
     workflowLassoResponse,
     control = control_grid(save_pred = TRUE),
      resamples = foldsFiveResponse,
      grid = gridLasso)
    }),

  tar_target(lassopredictions,{
    tuningLassoResponse |>
    collect_predictions()
  }),


# Linear Regression model 
tar_target(recLRResponse, 
           recipe(sbp_post ~
                    sbp_pre +
                    nitro_pre +
                    nitro_diff_mcg +
                    total_nitro +
                    n_nitro +
                    nitro_time +
                    time_since_nitro +
                    sbp_pre_mean_60 +
                    sbp_pre_sd_60 +
                    lag_nitro_diff +
                    lag_sbp_diff,
                  data = trainingResponse
           ) |>
             step_YeoJohnson(
               n_nitro, nitro_time, total_nitro, sbp_pre_sd_60
             ) |>
             step_normalize(
               all_numeric_predictors()
             )|>
             step_pca(
               sbp_pre_mean_60,
               sbp_pre
             ) |> 
             step_interact(terms = ~lag_nitro_diff:lag_sbp_diff) #This is the interaction term
),
tar_target(specLR, 
           linear_reg(
             mode = "regression",
           ) |>  
             set_engine('lm')
),
tar_target(workflowLRResponse, 
           workflow()|>
             add_recipe(recLRResponse)|>
             add_model(specLR)
),

tar_target(tuningLRResponse,
           fit_resamples(
             workflowLRResponse,
             resamples = foldsFiveResponse)
),


#Ridge Model
## Specifications for the ridge model
tar_target(specRidgeResponse, {
  linear_reg(
    penalty = tune(),
    mixture = 0 #Changed from 1 to 0
  ) |>
    set_engine("glmnet")
}),
## Grid search to determine the best value for the penalty parameter (i.e. amount of regularization)
tar_target(gridRidge, {
  dials::grid_regular(dials::penalty(),
                      levels = 100
  )
}),
## Recipe for the model
tar_target(recRidgeResponse, {
  recipe(sbp_post ~
           sbp_pre +
           nitro_diff_mcg +
           total_nitro +
           n_nitro +
           nitro_time +
           sbp_pre_mean_60 +
           sbp_pre_sd_60 +
           lag_nitro_diff +
           lag_sbp_diff,
         data = trainingResponse
  ) |>
    step_YeoJohnson(
      n_nitro, nitro_time, total_nitro, sbp_pre_sd_60
    ) |>
    step_normalize(
      all_numeric_predictors()
    )|>
    step_pca(
      sbp_pre_mean_60,
      sbp_pre
    ) |> 
    step_interact(terms = ~lag_nitro_diff:lag_sbp_diff) #This is the interaction term
}),

## Run the model using 5-fold cross-validation
tar_target(workflowRidgeResponse, {
  workflow()|>
    add_recipe(recRidgeResponse)|>
    add_model(specRidgeResponse)
}),
fit <- tar_target(tuningRidgeResponse, {
  tune_grid(
    workflowRidgeResponse,
    resamples = foldsFiveResponse,
    grid = gridRidge
  )
}),

#XGBoost
#XGBoost model
tar_target(recBoost, recipe(sbp_post ~ sbp_pre +
                              nitro_pre +
                              nitro_diff_mcg +
                              total_nitro +
                              n_nitro +
                              nitro_time +
                              time_since_nitro +
                              sbp_pre_mean_60 +
                              sbp_pre_sd_60 +
                              lag_nitro_diff +
                              lag_sbp_diff,
                            data = trainingResponse
)),
tar_target(
  specBoost,
  boost_tree(
    # trees = 500,
    # min_n = 30,
    # learn_rate = 0.015,
    # sample_size = 0.5, #0.5 was best
    # tree_depth = 1,
    trees = tune(),
    min_n = tune(),
    mtry = tune(),
    learn_rate = tune(),
    sample_size = tune(),
    tree_depth = tune(),
    loss_reduction = tune()
  ) |>
    set_engine("xgboost")|>
    set_mode("regression")
),

tar_target(
  workflowBoost,
  workflow()|>
    add_recipe(recBoost)|>
    add_model(specBoost)
),
tar_target(gridBoost,
           grid_max_entropy(
             tree_depth(c(8, 15)),
             min_n(c(20L, 40L)),
             mtry(c(4L, 6L)),
             loss_reduction(),
             sample_size = sample_prop(c(0.5,1.0)),
             learn_rate(c(-3,-2)),
             trees(c(500, 5000)),
             size = 50
           )
),

tar_target(tuningRaceBoost,
           tune_race_anova(
             workflowBoost,
             foldsFiveResponse,
             grid = gridBoost,
             metrics = mset,
             control = control_race(verbose_elim = TRUE)
           )
),

# randomforest model
tar_target(recRFResponse, recipe(sbp_post ~ sbp_pre +
    nitro_pre +
    nitro_diff_mcg +
    total_nitro +
    n_nitro +
    nitro_time +
    time_since_nitro +
    sbp_pre_mean_60 +
    sbp_pre_sd_60 +
    lag_nitro_diff +
    lag_sbp_diff,
    data = trainingResponse
  )|>
  step_dummy(all_nominal_predictors())
  ),
  tar_target(
    specRFResponse,
    rand_forest(
      trees = tune(),
      min_n = tune(),
      mtry = tune(),
    ) |>
      set_engine("randomForest")|>
      set_mode("regression")
  ),
   tar_target(
    workflowRFResponse,
    workflow()|>
    add_recipe(recRFResponse)|>
    add_model(specRFResponse)
  ),
  tar_target(gridRFResponse,
  grid_regular(
  trees(c(1000, 5000)),
  mtry(range = c(2, 10)),
  min_n(range = c(2, 10)),
  levels = 5
)
  ),
  tar_target(tuningGridRFResponse,
      tune_grid(
        workflowRFResponse,
        resamples = foldsFiveResponse,
        grid = gridRFResponse,
        metrics = mset,
        control = control_race(verbose_elim = TRUE)
      )
)
)

#Figure 3- Best Results from each model 
library("ggplot2")
library("extrafont")

options(scipen=100, digits=6)
options(max.print = 500000000)

IV <-c("Linear", "Lasso", "Ridge", "XGBoost", "Random Forest")
RMSE <- c( 13.3, 13.3, 13.3, 13.7, 13.7)
LCI <- c(12.07, 12.13, 12.2, 12.38, 12.58)
UCI <- c(14.53, 14.47, 14.41, 15.02, 14.82)


A$IV<-factor(A$IV, levels=c("Random Forest",
                            "XGBoost",
                            "Ridge",
                            "Lasso",
                            "Linear"))


fp <-ggplot(data=A, aes(x=IV, y=RMSE, ymin=LCI, ymax=UCI)) +
  geom_pointrange() + 
  geom_hline(yintercept=0, lty=2, size =1) +  # add a dotted line at x=1 after flip
  geom_errorbar(aes(ymin=LCI, ymax=UCI), width=0.5, cex=1)+ # Makes whiskers on the range (more aesthetically pleasing)
  coord_flip() +
  geom_point(shape = 15, color= "blue", size = 2) + # specifies the size and shape of the geompoint
  ggtitle("")+ # Blank Title for the Graph
  xlab("Models") + # Label on the Y axis (flipped specification do to coord_flip)
  ylab("RMSE (95% CI)") +
  scale_y_continuous(limits = c(11,16), breaks = c(11,12,13,14,15,16))+ # limits and tic marks on X axis (flipped specification do to coord_flip)
  theme(line = element_line(colour = "black", size = 3), # My personal theme for GGplots
        strip.background = element_rect(fill="gray90"), 
        legend.position ="none", 
        axis.line.x = element_line(colour = "black"), 
        axis.line.y = element_blank(), 
        panel.border= element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(), 
        axis.ticks = element_blank())
print(fp)
