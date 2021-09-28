  tar_target(
    patient,
    query_cols(
      connection = eicu_conn,
      table = "patient",
      columns = "patientunitstayid,
       age,
       apacheadmissiondx,
       ethnicity,
       gender,
       admissionheight,
       admissionweight,
       unitAdmitSource,
       uniquepid,
       hospitalid"
    )
  )
