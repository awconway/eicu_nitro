#' Remove unrealistic nitro doses
#' @importFrom dplyr group_by mutate
#' @description This function will remove the
#' rows where doses less than 1mcg/min were noted
#' @importFrom dplyr group_by mutate pull filter
#' @param df data_formatted from the pipeline
#' @export
nitro_dose_debug <- function(df) {
  unrealistic_dose_post <- df %>%
    # all in the pre column are also in the post
    filter(nitro_post < 1 & nitro_post > 0) %>%
    distinct(id) %>%
    pull(unique(id))

  df %>%
    filter(!id %in% unrealistic_dose_post)
}