tar_target(specLassoResponse, {
    linear_reg(
      penalty = tune(),
      mixture = 1
    ) |>
      set_engine("glmnet")
})
