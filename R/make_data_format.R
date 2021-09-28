#' Combine data from tables and format
#' @description Combine data from different tables and format
#' @importFrom dplyr select filter rename group_by mutate
#' cur_group_id arrange ungroup full_join across rowwise
#' c_across
#' @importFrom tidyr ends_with
#' @importFrom tidyr pivot_wider fill replace_na
#' @param df df returned from join_tables
#' @param create_vasoactive_col logial creates a column to
#' indicate that a patient was receiving another infusion
#' that is likely to influence blood pressure

#' @returns target is data_formatted
#' @export


make_data_format <- function(df, create_vasoactive_col = TRUE) {


  # Make data types consistent and select only pertinent data

  cli::cli_process_start("Expanding data")

  df <- df %>%
    format_infusions() %>%
    make_sbp() %>%
    make_sbp_measure() %>%
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
    # filter(!is.na(sbp_sys) | !is.na(sbp_ni) | !is.na(sbp_ni)
    # | !is.na(sbp_ni_nurse)) %>%
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
      sbp_pre,
      sbp_post,
      sbp_pre_mean_60,
      sbp_pre_median_60,
      sbp_pre_sd_60,
      sbp_pre_mean_120,
      sbp_pre_sd_120,
      sbp_pre_median_120,
      sbp_measure,
      time_since_nitro,
      # sbp_sys_pre,
      # sbp_sys_nurse_pre,
      # sbp_ni_pre,
      # sbp_ni_nurse_pre,
      # sbp_sys_nurse_post,
      # sbp_sys_post,
      # sbp_ni_post,
      # sbp_ni_nurse_post,
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
