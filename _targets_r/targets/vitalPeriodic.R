  tar_target(
    vital_periodic,
    query_cols(
      connection = eicu_conn,
      table = "vitalperiodic",
      columns = "patientunitstayid,
            observationoffset,
            systemicsystolic"
    )
  )
