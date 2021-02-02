#' @importFrom dplyr group_by mutate ungroup
#' @export
format_time_start_at_one <- function(df) {
  cli::cli_alert("Formatting observations to start at t = 1 ...")

  df %>%
    group_by(id) %>%
    mutate(time = time - min(time) + 1) %>%
    ungroup()
}
