#' make_sbp
#' @description Filters out noninvasive bp over 250mmHg
#'
#' @param df data frame produced from make_infusions
#' @importFrom dplyr mutate coalesce
#' @returns
#' @export
make_sbp <- function(df) {
  cli::cli_alert("Combining SBP data...")

  df %>%
    mutate(sbp_ni_nurse = as.numeric(
      as.character(noninvasivesystolic_nurse))) %>%
    mutate(sbp_sys_nurse = as.numeric(
      as.character(systemicsystolic_nurse))) %>%
    mutate(sbp_ni_nurse = case_when(
      sbp_ni_nurse < 250 ~ sbp_ni_nurse,
      TRUE ~ NA_real_
    )) %>%
    mutate(sbp_sys = systemicsystolic) %>%
    mutate(sbp_ni =  noninvasivesystolic) %>%
    select(-noninvasivesystolic_nurse,
    -systemicsystolic_nurse,
    -systemicsystolic,
    -noninvasivesystolic)

}