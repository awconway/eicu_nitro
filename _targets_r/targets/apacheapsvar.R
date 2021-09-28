  tar_target(
    apacheapsvar,
    query_cols(
      connection = eicu_conn,
      table = "apacheapsvar",
      columns = "*"
    )
  )
