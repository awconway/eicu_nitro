tar_target(specRidgeResponse, {
    linear_reg(
      penalty = tune(),
      mixture = 0 
    ) |>
      set_engine("glmnet")
})
