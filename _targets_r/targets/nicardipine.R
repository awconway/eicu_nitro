 tar_target(
    nicardipine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Nicardipine (mg/hr)'"
    )
  )
