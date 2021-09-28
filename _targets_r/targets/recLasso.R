tar_target(recLasso, {
    recipe(sbp_post ~
    sbp_pre +
      nitro_diff_mcg +
      total_nitro +
      n_nitro +
      nitro_time +
       sbp_pre_mean_60 +
       sbp_pre_sd_60,
      data = training
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
      )
})
