
#' @importFrom dplyr mutate
#' @export
format_weight <- function(df) {
  cli::cli_alert("Formatting weight...")

  df %>%
    dplyr::mutate(weight = admissionweight)
}