#' format data for infusions
#' @description This function will create a variable called `nitro`
#' which is the dose rate
#'
#' @param df data frame produced from make_infusions
#' @importFrom dplyr mutate case_when
#' @importFrom readr parse_number
#' @export
format_infusions <- function(df) {

  # Many warnings are expected, but they are recorded
  df %>%
    mutate(drugrate = suppressWarnings(
      readr::parse_number(as.character(drugrate))
    )) %>%
    mutate(
      nitro =
        case_when(
          drugname == "Nitroglycerin (mcg/min)" ~ drugrate,
          TRUE ~ NA_real_
        )
    ) %>%
    select(-drugname, -drugrate)

}
