#' Combine data from tables and format
#' @description Combine data from different tables and format
#' @importFrom dplyr select filter rename group_by mutate
#' cur_group_id arrange ungroup full_join across rowwise
#' c_across
#' @importFrom tidyr ends_with
#' @importFrom tidyr pivot_wider fill replace_na
#' @param patient dataframe from SQL query
#' @param nitro dataframe from SQL query
#' @param sbp_nurse_charting dataframe from SQL query
#' @param vital_aperiodic dataframe from SQL query
#' @param vital_periodic dataframe from SQL query
#' @param apachepatientresult dataframe from SQL query
#' @param creat dataframe from SQL query
#' @param create_vasoactive_col logial creates a column to
#' indicate that a patient was receiving another infusion
#' that is likely to influence blood pressure

#' @returns target is data_formatted
#' @export


make_data_format <- function(patient,
                             nitro,
                             sbp_nurse_charting,
                             vital_aperiodic,
                             vital_periodic,
                             apachepatientresult,
                             apachepredvar,
                             creat,
                             fentanyl,
                             midaz,
                             propofol,
                             dobutamine,
                             dex,
                             nicardipine,
                             amiodarone,
                             fluids,
                             milrinone,
                             epinephrine,
                             vasopressin,
                             diltiazem,
                             pain,
                             create_vasoactive_col = TRUE) {


  # Make data types consistent and select only pertinent data

  cli::cli_process_start(
    "Making data types consistent and selecting only pertinent data"
  )

  nitro <- nitro %>%
    type.convert()

  sbp_nurse_charting <- sbp_nurse_charting %>%
    type.convert() %>%
    tidyr::pivot_wider(
      names_from = nursingchartcelltypevalname,
      values_from = nursingchartvalue
    ) %>%
    rename(
      noninvasivesystolic_nurse = `Non-Invasive BP Systolic`,
      systemicsystolic_nurse = `Invasive BP Systolic`
    )

  patient <- patient %>%
    type.convert() %>%
    group_by(uniquepid) %>%
    mutate(pid = cur_group_id())

  apachepatientresult <- apachepatientresult %>%
    filter(apacheversion == "IVa") %>%
    select(patientunitstayid, apachescore) %>%
    type.convert()

  vital_periodic <- vital_periodic %>%
    type.convert()

  vital_aperiodic <- vital_aperiodic %>%
    type.convert()

  creat <- creat %>%
    type.convert() %>%
    mutate(creat_lab = as.numeric(labresult)) %>%
    select(-labresult, -labname)

  dobutamine <- dobutamine %>%
    type.convert() %>%
    mutate(dobutamine_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  fentanyl <- fentanyl %>%
    type.convert() %>%
    mutate(fentanyl_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  midaz <- midaz %>%
    type.convert() %>%
    mutate(midaz_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  propofol <- propofol %>%
    type.convert() %>%
    mutate(propofol_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  dex <- dex %>%
    type.convert() %>%
    mutate(dex_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  nicardipine <- nicardipine %>%
    type.convert() %>%
    mutate(nicardipine_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  amiodarone <- amiodarone %>%
    type.convert() %>%
    mutate(amiodarone_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  fluids <- fluids %>%
    type.convert() %>%
    mutate(fluids_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  epinephrine <- epinephrine %>%
    type.convert() %>%
    mutate(epinephrine_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  milrinone <- milrinone %>%
    type.convert() %>%
    mutate(milrinone_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  vasopressin <- vasopressin %>%
    type.convert() %>%
    mutate(vasopressin_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  diltiazem <- diltiazem %>%
    type.convert() %>%
    mutate(diltiazem_inf = as.numeric(drugrate)) %>%
    select(-drugrate, -drugname)

  pain <- pain %>%
    type.convert() %>%
    mutate(pain_score = as.numeric(nursingchartvalue)) %>%
    select(-nursingchartvalue, -nursingchartvalue)

  apachepredvar <- apachepredvar %>%
    select(
      patientunitstayid, admitdiagnosis, diabetes
    ) %>%
    type.convert() %>%
    mutate(diabetes = factor(diabetes,
      levels = c(0, 1),
      ordered = FALSE
    ))

  cli::cli_process_done()

  # Combine data

  cli::cli_process_start("Combining data from separate tables")

  df <- nitro %>%
    full_join(creat,
      by = c("infusionoffset" = "labresultoffset", "patientunitstayid")
    ) %>%
    full_join(dobutamine,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(fentanyl,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(midaz,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(propofol,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(dex,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(nicardipine,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(amiodarone,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(fluids,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(milrinone,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(epinephrine,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(vasopressin,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(diltiazem,
      by = c("infusionoffset", "patientunitstayid")
    ) %>%
    full_join(vital_periodic,
      by = c("infusionoffset" = "observationoffset", "patientunitstayid")
    ) %>%
    full_join(vital_aperiodic,
      by = c("infusionoffset" = "observationoffset", "patientunitstayid")
    ) %>%
    full_join(sbp_nurse_charting,
      by = c("infusionoffset" = "nursingchartoffset", "patientunitstayid")
    ) %>%
    full_join(pain,
      by = c("infusionoffset" = "nursingchartoffset", "patientunitstayid")
    ) %>%
    full_join(patient,
      by = "patientunitstayid"
    ) %>%
    full_join(apachepatientresult,
      by = "patientunitstayid"
    ) %>%
    full_join(apachepredvar,
      by = "patientunitstayid"
    ) %>%
    rename(time = infusionoffset) %>%
    group_by(patientunitstayid) %>%
    mutate(id = cur_group_id()) %>%
    arrange(id, time) %>%
    ungroup()

  cli::cli_process_done()

  cli::cli_process_start("Expanding data")

  df <- df %>%
    format_infusions() %>%
    make_sbp() %>%
    remove_time_multiples() %>%
    format_time_start_at_one() %>%
    # Fill intermediate rows with infusion dose or lab results
    group_by(id) %>%
    arrange(id, time) %>%
    fill(c(
      ends_with("_inf"),
      ends_with("_lab"),
      ends_with("_score"),
      nitro
    ), .direction = "down") %>%
    mutate(
      across(ends_with("_inf"), coalesce, 0),
      across(ends_with("_score"), coalesce, 0),
      across(ends_with("_lab"), coalesce, 0),
      across(nitro, coalesce, 0)
      ) %>%
    ungroup() %>%
    filter(!is.na(sbp_sys) | !is.na(sbp_ni) | !is.na(sbp_ni)
    | !is.na(sbp_ni_nurse)) %>%
    format_count_nitro_infusion() %>%
    format_sbp_pre() %>%
    format_sbp_post() %>%
    format_nitro_pre() %>%
    format_nitro_post() %>%
    make_total_nitro() %>%
    make_nitro_time() %>%
    nitro_dose_debug() %>%
    format_age() %>%
    format_height() %>%
    format_weight() %>%
    select(
      ends_with("id"),
      admitdiagnosis,
      diabetes,
      n_nitro,
      time,
      nitro_time,
      time_pre,
      time_post,
      sbp_sys_pre,
      sbp_sys_nurse_pre,
      sbp_ni_pre,
      sbp_ni_nurse_pre,
      sbp_sys_nurse_post,
      sbp_sys_post,
      sbp_ni_post,
      sbp_ni_nurse_post,
      nitro_pre,
      nitro_post,
      age,
      weight,
      height,
      gender,
      apachescore,
      total_nitro,
      unitAdmitSource,
      ends_with("_inf"),
      ends_with("_score"),
      ends_with("_lab")
    ) %>%
    ungroup() %>%
    make_sbp_measure() %>%
    {
      if (create_vasoactive_col) {
        create_vasoactive_col(.)
      } else {
        .
      }
    }

  cli::cli_process_done()

  return(df)
}
