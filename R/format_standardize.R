
#' @importFrom dplyr mutate
#' @export
format_standardize <- function(x) {
  x %>%
    dplyr::mutate(
      age_s = standardize(age),
      weight_s = standardize(weight),
      height_s = standardize(height),
      nitro_pre_s = standardize(nitro_pre),
      nitro_post_s = standardize(nitro_post),
      total_nitro_s = standardize(total_nitro),
      apachescore_s = standardize(apachescore)
    )
}