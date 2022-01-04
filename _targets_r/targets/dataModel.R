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
    na.omit()) 
  
