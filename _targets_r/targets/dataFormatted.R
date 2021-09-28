tar_target(data_formatted,
dataFormattedRaw|>
    mutate(
      nitro_diff_mcg = nitro_post - nitro_pre)|>
        #performs well
    #  filter(sbp_pre <= 200,
    # nitro_pre <= 50 | nitro_post >= 50,
    # nitro_diff <= 20)
    #performs well
    #  filter(sbp_pre <= 200 | sbp_post <= 200,
    # nitro_pre <= 50 | nitro_post >= 50,
    # nitro_diff <= 20)
    # probably most resembling policy
    filter(
      sbp_pre <= 200, #shouldn't filter out post >200
      sbp_pre >= 25,
      sbp_post >= 25,
    nitro_pre <= 50,
    nitro_diff_mcg <= 20,
    nitro_diff_mcg >=-20
    )
)
