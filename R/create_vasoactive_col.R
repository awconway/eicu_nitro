#' Add a column to indicate if other infusion that will interact
#' with blood pressure is in use
#' 
#' @export


create_vasoactive_col <- function(df) {
          rowwise(df) %>%
          mutate(vasoactive = sum(c_across(ends_with("_inf")))) %>%
          mutate(vasoactive = ifelse(vasoactive == 0, "no vasoactive",
            "vasoactive"
          )) %>%
          ungroup() %>%
          select(
            -ends_with("_inf")
          )
}