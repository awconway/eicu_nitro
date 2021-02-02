#' Format nitro dose column
#' @description Changes name of column to nitro_post
#' @param df dataframe modified in make_data_format
#' @importFrom dplyr mutate
#' @export
format_nitro_post <- function(df) {
  cli::cli_alert("Formatting post-infusion nitroglycering rate...")
  df %>%
    mutate(nitro_post = nitro)
}