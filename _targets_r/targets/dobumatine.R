
  tar_target(
    dobutamine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Dobutamine (mcg/kg/min)'"
    )
  )
