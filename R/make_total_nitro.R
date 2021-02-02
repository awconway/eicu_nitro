#' Add total dose of nitro
#' @importFrom dplyr group_by mutate
#' @description This function will add a column that is a
#' total dose of nitroglycerin the patient has received.
#' The dose is reset when the infusion dose is zero.
#' @importFrom dplyr group_by mutate first
#' @param df data_formatted from the pipeline
#' @export
make_total_nitro <- function(df) {
  df %>%
    group_by(id) %>%
    mutate(total_nitro = ifelse(nitro_pre != 0,
      cumsum(nitro_post), 0
    ))
}
