  tar_target(
    milrinone,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Milrinone (mcg/kg/min)'"
    )
  )
