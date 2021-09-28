 tar_target(
    norepinephrine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Norepinephrine (mcg/min)'"
    )
  )
