tar_target(recBoost, recipe(sbp_post ~ sbp_pre +
    nitro_pre +
    nitro_diff_mcg +
    total_nitro +
    n_nitro +
    nitro_time +
    time_since_nitro +
    sbp_pre_mean_60 +
    sbp_pre_sd_60,
  data = training
  )|>
  step_dummy(all_nominal_predictors())
  )
