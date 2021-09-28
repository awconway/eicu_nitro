  tar_target(
    vital_aperiodic,
    query_cols(
      connection = eicu_conn,
      table = "vitalaperiodic",
      columns = "patientunitstayid,
            observationoffset,
            noninvasivesystolic"
    )
  )
