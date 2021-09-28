  tar_target(
    dex,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Dexmedetomidine (mcg/kg/hr)'"
    )
  )
