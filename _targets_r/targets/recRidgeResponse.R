tar_target(recRidgeResponse, {
    recipe(sbp_post ~
    sbp_pre +
      nitro_diff_mcg +
      total_nitro +
      n_nitro +
      nitro_time +
       sbp_pre_mean_60 +
       sbp_pre_sd_60 +
      pain_score +
      lag_nitro_diff +
      lag_sbp_diff,
      data = trainingResponse
    ) |>
      step_YeoJohnson(
        n_nitro, nitro_time, total_nitro, sbp_pre_sd_60, pain_score
      ) |>
      step_normalize(
        all_numeric_predictors()
      )|>
      step_pca(
      sbp_pre_mean_60,
      sbp_pre
      ) |> 
    step_interact(terms = ~lag_nitro_diff:lag_sbp_diff) #This is the interaction term
  
})
