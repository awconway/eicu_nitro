#' Add details of dose and time after dose titration that
#' blood pressure was taken
#' @description Adds:
#' - `sbp_post`, which is the most recent value of
#' sbp before next dose of nitro
#' - `time_post`, which is the time that sbp_post occured,
#' in minutes after dose of nitro

#' @param df dataframe created in `make_data_frame`
#' @importFrom dplyr mutate
#' @export
format_sbp_post <- function(df) {
  cli::cli_alert("Formatting post-infusion SBP...")

  df %>%
    mutate(
      sbp_post = sbp,
      # sbp_sys_nurse_post = sbp_sys_nurse,
      # sbp_sys_post = as.numeric(sbp_sys),
      # sbp_ni_post = as.numeric(sbp_ni),
      # sbp_ni_nurse_post = sbp_ni_nurse,
      time_post = time_since_nitro
    )
}