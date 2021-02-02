
#' @importFrom dplyr select
#' @export
remove_time_multiples <- function(df) {
  cli::cli_alert("Removing multiple time entries...")

  idx <- df %>%
    select(id, time) %>%
    duplicated(fromLast = TRUE)

  df <- df[!idx, ]

  return(df)
}
