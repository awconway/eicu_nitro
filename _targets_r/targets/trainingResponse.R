tar_target(trainingResponse, {
   dataModel |> 
      filter(id %in% multiples) |>
      group_by(id) |>
      mutate(lag_nitro_pre = lag(nitro_pre),
             lag_nitro_post = lag(nitro_post),
              lag_sbp_pre = lag(sbp_pre),
             lag_sbp_post = lag(sbp_post),
             lag_nitro_diff = lag_nitro_post - lag_nitro_pre,
             lag_sbp_diff = lag_sbp_post - lag_sbp_pre) |> 
      mutate(first_titration = row_number(n_nitro)) |>
      filter(first_titration != 1) |> 
    ungroup()
})
