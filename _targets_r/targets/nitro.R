  tar_target(
    nitro,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Nitroglycerin (mcg/min)'"
    )
  )
