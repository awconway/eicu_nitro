  tar_target(
    phenylephrine,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Phenylephrine (mcg/hr)'"
    )
  )
