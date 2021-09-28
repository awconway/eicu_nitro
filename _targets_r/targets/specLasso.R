tar_target(specLasso, {
    linear_reg(
      penalty = tune(),
      mixture = 1
    ) |>
      set_engine("glmnet")
})
