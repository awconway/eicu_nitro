#' Format nitro dose column
#' @description Changes name of column to nitro_post
#' @param df dataframe modified in make_data_format
#' @importFrom dplyr group_by mutate first summarize left_join select ungroup
#' @export
format_nitro_pre <- function(df) {
  cli::cli_alert("Formatting pre-infusion nitroglycering rate...")

  df <- df %>%
    group_by(id, n_nitro) %>%
    mutate(nitro_pre_lag = first(nitro))

  tmp <- df %>%
    group_by(id, n_nitro) %>%
    summarize(nitro_pre = first(nitro_pre_lag)) %>%
    mutate(n_nitro_lag = n_nitro + 1)

  df <- left_join(df,
    tmp,
    by = c("id", "n_nitro" = "n_nitro_lag")
  ) %>%
    select(-nitro_pre_lag) %>%
    ungroup()
}
