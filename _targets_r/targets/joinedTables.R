tar_target(joinedTables, {
  eicu::join_tables(
        patient = patient,
        nitro = nitro,
        sbp_nurse_charting = sbp_nurse_charting,
        vital_aperiodic = vital_aperiodic,
        vital_periodic = vital_periodic,
        apachepatientresult = apachepatientresult,
        apachepredvar = apachepredvar,
        creat = creat,
        fentanyl = fentanyl,
        midaz = midaz,
        propofol = propofol,
        dobutamine = dobutamine,
        dex = dex,
        nicardipine = nicardipine,
        amiodarone = amiodarone,
        fluids = fluids,
        milrinone = milrinone,
        epinephrine = epinephrine,
        vasopressin = vasopressin,
        diltiazem = diltiazem,
        # this pain variable codes NAs as zero pain scores
        pain = pain
      )
})
