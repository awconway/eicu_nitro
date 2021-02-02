#' Add total time on nitro
#' @description This function will add a column that is a
#' total of the time in minutes that the patient has been on
#' a nitroglycerin infusion continuously. The time is reset
#' when the infusion dose is zero.
#' @importFrom dplyr group_by mutate first
#' @param df data_formatted from the pipeline
#' @export
make_nitro_time <- function(df) {
  df %>%
    group_by(id) %>%
    mutate(nitro_time = ifelse(nitro_pre != 0,
      time - first(time), 0
    ))
}