#' Split invasive and non-invasive sbp measurements
#' @return dataframe with column to indicate type of sbp measurement
#' @param df dataframe in make_data_format
#' @importFrom dplyr filter mutate bind_rows select
#' @export
#' 

make_sbp_measure <- function(df) {
    ni <- df %>%
        filter(!is.na(sbp_ni)) %>%
        mutate(
            sbp = sbp_ni,
            sbp_measure = "non-invasive"
        )

    sys <- df %>%
        filter(!is.na(sbp_sys)) %>%
        mutate(
            sbp = sbp_sys,
            sbp_measure = "invasive"
        )

    ni_nurse <- df %>%
        filter(!is.na(sbp_ni_nurse)) %>%
        mutate(
            sbp = sbp_ni_nurse,
            sbp_measure = "non-invasive"
        )

    df <- ni %>%
        bind_rows(sys, ni_nurse) %>%
        select(
            -sbp_ni, -sbp_sys,
            -sbp_ni_nurse, -sbp_sys_nurse
        ) %>%
        unique()|>
    group_by(id)|>
    arrange(time)|>
    mutate(sbp_mean_60 = slider::slide_index_mean(
        sbp, time,
        before = 60
    ),
    sbp_median_60 = slider::slide_index_dbl(
        sbp, time, median,
        before = 60
    ),
    sbp_sd_60 = slider::slide_index_dbl(
        sbp, time, sd,
        .before = 60
    )
    )|>
    mutate(sbp_mean_120 = slider::slide_index_mean(
        sbp, time,
        before = 120
    ),
    sbp_median_120 = slider::slide_index_dbl(
        sbp, time, median,
        before = 120
    ),
    sbp_sd_120 = slider::slide_index_dbl(
        sbp, time, sd,
        .before = 120
    )
    )|>
    ungroup()
    return(df)
    # ni <- df %>%
    #     filter(!is.na(sbp_ni_pre) & !is.na(sbp_ni_post)) %>%
    #     mutate(
    #         sbp_pre = sbp_ni_pre,
    #         sbp_post = sbp_ni_post,
    #         sbp_measure = "non-invasive"
    #     )

    # sys <- df %>%
    #     filter(!is.na(sbp_sys_pre) & !is.na(sbp_sys_post)) %>%
    #     mutate(
    #         sbp_pre = sbp_sys_pre,
    #         sbp_post = sbp_sys_post,
    #         sbp_measure = "invasive"
    #     )

    # ni_nurse <- df %>%
    #     filter(!is.na(sbp_ni_nurse_pre) & !is.na(sbp_ni_nurse_post)) %>%
    #     mutate(
    #         sbp_pre = sbp_ni_nurse_pre,
    #         sbp_post = sbp_ni_nurse_post,
    #         sbp_measure = "non-invasive"
    #     )

    # df <- ni %>%
    #     bind_rows(sys, ni_nurse) %>%
    #     select(
    #         -sbp_ni_pre, -sbp_ni_post, -sbp_sys_pre, -sbp_sys_post,
    #         -sbp_ni_nurse_pre, -sbp_ni_nurse_post, -sbp_sys_nurse_pre,
    #         -sbp_sys_nurse_post
    #     ) %>%
    #     unique()
    #     return(df)
}