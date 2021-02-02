#' Count number of nitro dose titrations
#' @description Adds the following variables:
#' - `n_nitro`, which enumerates the doses of nitro within levels of 'id'
#' - `time_until_nitro`, which is the time until the next dose of nitro
#' - `time_since_nitro`, which is the time since the last dose of nitro
#' @importFrom dplyr group_by mutate lag lead select ungroup
#' @importFrom tidyr fill
#' @param df dataframe modified in make_data_format
#' @return dataframe to be further modified in make_data_format

#' @export
format_count_nitro_infusion <- function(df) {
  cli::cli_alert("Formatting nitroglycerin infusion data...")

  df %>%
    group_by(id) %>%
    mutate(nitro_idx = ifelse(
      ((nitro - lag(nitro)) == 0) | is.na((nitro - lag(nitro))),
      0,
      1
    )) %>%
    mutate(
      time_last_nitro = ifelse(nitro_idx == 1, time, NA),
      time_next_nitro = lead(time_last_nitro)
    ) %>%
    tidyr::fill(time_last_nitro, .direction = "down") %>%
    tidyr::fill(time_next_nitro, .direction = "up") %>%
    mutate(
      time_since_nitro = time - time_last_nitro,
      time_until_nitro = time_next_nitro - time,
      n_nitro = cumsum(nitro_idx) + 1
    ) %>%
    select(
      -time_last_nitro,
      -time_next_nitro
    ) %>%
    ungroup()
}