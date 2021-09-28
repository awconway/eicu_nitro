  tar_target(
    apachepredvar,
    query_cols(
      connection = eicu_conn,
      table = "apachepredvar",
      columns = "*"
    )
  )
