tar_target(
    specRFResponse,
    rand_forest(
      # trees = 500,
      # min_n = 30,
      # learn_rate = 0.015,
      # sample_size = 0.5, #0.5 was best
      # tree_depth = 1,
      trees = tune(),
      min_n = tune(),
      mtry = tune(),
    ) |>
      set_engine("randomForest")|>
      set_mode("regression")
  )
