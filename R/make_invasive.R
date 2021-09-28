#' invasive sbp data
#' @description Invasive sbp measurements for patients who have
#' had at least 5 nitro dose titrations (n=246)
#' @param data_formatted target from pipeline
#' @return data_invasive pipeline target
#' @export
make_invasive <- function(data_formatted) {
    inv_ids <- data_formatted %>%
        filter(sbp_measure == "invasive") %>%
        filter(
            time_pre %in% 0:15,
            time_post %in% 5:15
        ) %>%
        group_by(id) %>%
        # only the first bp within the 10-15 min timeframe after dose titration
        distinct(n_nitro, .keep_all = T) %>%
        ungroup() %>%
        filter(n_nitro > 5) %>%
        pull(patientunitstayid)

    data_formatted %>%
        filter(patientunitstayid %in% inv_ids) %>%
        select(
            id,
            n_nitro,
            sbp_pre,
            sbp_post,
            sbp_measure,
            nitro_pre,
            nitro_post,
            weight,
            height,
            gender,
            age,
            time,
            time_pre,
            time_post,
            apachescore,
            total_nitro,
            nitro_time
        )
}