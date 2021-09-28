  tar_target(
    creat,
    query_rows(
      connection = eicu_conn,
      table = "lab",
      columns = "patientunitstayid,
      labname,
      labresultoffset,
      labresult",
      rows = "labname = 'creatinine'"
    )
  )
