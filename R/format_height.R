#' Format height coloumn
#' @description Changes name of column to height
#' @param df dataframe modified in make_data_format
#' @importFrom dplyr mutate
#' @export
format_height <- function(df) {
  cli::cli_alert("Formatting height...")
  df %>%
    dplyr::mutate(height = admissionheight)
}