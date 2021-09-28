  tar_target(
    pain, query_rows(eicu_conn,
      table = "nursecharting",
      columns = "patientunitstayid,
               nursingchartoffset,
               nursingchartcelltypevalname,
               nursingchartvalue",
      rows = "nursingchartcelltypevalname = 'Pain Score'"
    )
  )
