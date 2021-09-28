  tar_target(
    sbp_nurse_charting, query_rows(eicu_conn,
      table = "nursecharting",
      columns = "patientunitstayid,
               nursingchartoffset,
               nursingchartcelltypevalname,
               nursingchartvalue",
      rows = "nursingchartcelltypevalname = 'Non-Invasive BP Systolic'
          OR nursingchartcelltypevalname = 'Invasive BP Systolic'"
    )
  )
