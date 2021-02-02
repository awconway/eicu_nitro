#' Add details of dose and time before dose titration that
#' blood pressure was taken
#' @description Adds:
#' - `sbp_pre`, which is the most recent value of
#' sbp before next dose of nitro
#' - `time_pre`, which is the time that sbp_pre occured,
#' in minutes before next dose of nitro
#' - `time_since_nitro`, which is the time since the last
#' dose of nitro
#' @param df dataframe created in `make_data_frame`
#' @importFrom dplyr group_by mutate last summarize
#' first left_join select ungroup
#' @export
format_sbp_pre <- function(df) {
  cli::cli_alert("Formatting pre-infusion SBP...")

  df <- df %>%
    group_by(id, n_nitro) %>%
    mutate(
      time_pre_lead = min(time_until_nitro),
      sbp_sys_pre_lead = last(sbp_sys),
      sbp_sys_nurse_pre_lead = last(sbp_sys_nurse),
      sbp_ni_pre_lead = last(sbp_ni),
      sbp_ni_nurse_pre_lead = last(sbp_ni_nurse)
    )

  tmp <- df %>%
    group_by(id, n_nitro) %>%
    summarize(
      sbp_sys_nurse_pre = first(sbp_sys_nurse_pre_lead),
      sbp_sys_pre = first(sbp_sys_pre_lead),
      sbp_ni_pre = first(sbp_ni_pre_lead),
      sbp_ni_nurse_pre = first(sbp_ni_nurse_pre_lead),
      time_pre = first(time_pre_lead)
    ) %>%
    mutate(
      n_nitro_lead = n_nitro + 1,
      sbp_sys_nurse_pre = as.numeric(sbp_sys_nurse_pre),
      sbp_sys_pre = as.numeric(sbp_sys_pre),
      sbp_ni_pre = as.numeric(sbp_ni_pre),
      sbp_ni_nurse_pre = as.numeric(sbp_ni_nurse_pre)
    )

  df <- left_join(df,
    tmp,
    by = c("id",
      "n_nitro" = "n_nitro_lead"
    )
  ) %>%
    select(
      -time_pre_lead,
      -sbp_sys_nurse_pre_lead,
      -sbp_sys_pre_lead,
      -sbp_ni_pre_lead,
      -sbp_ni_nurse_pre_lead
    ) %>%
    ungroup()

  return(df)
}