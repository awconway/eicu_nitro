  tar_target(
    fentanyl,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Fentanyl (mcg/hr)'"
    )
  )
