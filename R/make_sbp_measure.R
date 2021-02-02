#' Split invasive and non-invasive sbp measurements
#' @return dataframe with column to indicate type of sbp measurement
#' @param df dataframe in make_data_format
#' @importFrom dplyr filter mutate bind_rows select

make_sbp_measure <- function(df) {
    ni <- df %>%
        filter(!is.na(sbp_ni_pre) & !is.na(sbp_ni_post)) %>%
        mutate(
            sbp_pre = sbp_ni_pre,
            sbp_post = sbp_ni_post,
            sbp_measure = "non-invasive"
        )

    sys <- df %>%
        filter(!is.na(sbp_sys_pre) & !is.na(sbp_sys_post)) %>%
        mutate(
            sbp_pre = sbp_sys_pre,
            sbp_post = sbp_sys_post,
            sbp_measure = "invasive"
        )

    ni_nurse <- df %>%
        filter(!is.na(sbp_ni_nurse_pre) & !is.na(sbp_ni_nurse_post)) %>%
        mutate(
            sbp_pre = sbp_ni_nurse_pre,
            sbp_post = sbp_ni_nurse_post,
            sbp_measure = "non-invasive"
        )

    df <- ni %>%
        bind_rows(sys, ni_nurse) %>%
        select(
            -sbp_ni_pre, -sbp_ni_post, -sbp_sys_pre, -sbp_sys_post,
            -sbp_ni_nurse_pre, -sbp_ni_nurse_post, -sbp_sys_nurse_pre,
            -sbp_sys_nurse_post
        ) %>%
        unique()
        return(df)
}