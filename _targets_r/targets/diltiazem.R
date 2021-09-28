
  tar_target(
    diltiazem,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Diltiazem (mg/hr)'"
    )
  )
