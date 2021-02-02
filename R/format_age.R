#' Format age variable
#' @description Converts age variable from character string with
#' over 89 to 90 as a numeric
#' @param df dataframe modified in make_data_format
#' @importFrom dplyr mutate
#' @export
format_age <- function(df) {
  cli::cli_alert("Formatting age with '>89' as '89'")
  suppressWarnings(
    df %>%
      mutate(age = ifelse(
        age == "> 89", 90, as.numeric(as.character(age))))
  )
}
