tar_target(recRFResponse, recipe(sbp_post ~ sbp_pre +
    nitro_pre +
    nitro_diff_mcg +
    total_nitro +
    n_nitro +
    nitro_time +
    time_since_nitro +
    sbp_pre_mean_60 +
    sbp_pre_sd_60 +
    pain_score +
    lag_nitro_diff +
    lag_sbp_diff,
    data = trainingResponse
  )|>
  step_dummy(all_nominal_predictors()) |>
  step_interact(terms = ~lag_nitro_diff:lag_sbp_diff) #This is the interaction term

  )
