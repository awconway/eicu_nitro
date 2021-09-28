  tar_target(
    apachepatientresult,
    query_cols(
      connection = eicu_conn,
      table = "apachepatientresult",
      columns = "patientunitstayid,
       apachescore,
       apacheversion"
    )
  )
