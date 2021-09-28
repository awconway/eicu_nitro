  tar_target(
    fluids,
    query_rows(
      connection = eicu_conn,
      table = "infusiondrug",
      columns = "patientunitstayid,
       infusionoffset,
       drugname,
       drugrate",
      rows = "drugname = 'NSS (ml/hr)' OR
      drugname = 'IVF (ml/hr)' OR
      drugname = 'NS (ml/hr)' OR
      drugname = '0.9 Sodium Chloride (ml/hr)' OR
      drugname = 'Normal saline (ml/hr)' OR
      drugname = 'normal saline (ml/hr)' OR
      drugname = 'NACL (ml/hr)'"
    )
  )
