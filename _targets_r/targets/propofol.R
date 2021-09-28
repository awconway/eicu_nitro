  tar_target(
    propofol,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'Propofol (mcg/kg/min)'"
    )
  )
