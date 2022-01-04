tar_target(
    specBoostResponse,
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
  )
