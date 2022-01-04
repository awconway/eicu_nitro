#' Fill intermediate rows with infusion dose or lab results
#' @param df dataframe modified in format_raw function
#' @importFrom dplyr group_by arrange ungroup
#' @importFrom tidyr fill replace_na
#' @export
format_fill <- function(df) {
  df %>%
    group_by(id) %>%
    arrange(id, time) %>%
    fill(creat_lab, .direction = "down") %>%
    fill(dobutamine_inf, .direction = "down") %>%
    fill(fentanyl_inf, .direction = "down") %>%
    fill(midaz_inf, .direction = "down") %>%
    fill(propofol_inf, .direction = "down") %>%
    fill(dex_inf, .direction = "down") %>%
    fill(nicardipine_inf, .direction = "down") %>%
    fill(amiodarone_inf, .direction = "down") %>%
    fill(fluids_inf, .direction = "down") %>%
    fill(milrinone_inf, .direction = "down") %>%
    fill(epinephrine_inf, .direction = "down") %>%
    fill(vasopressin_inf, .direction = "down") %>%
    fill(diltiazem_inf, .direction = "down") %>%
    # fill(pain_score, .direction = "down") %>%
    fill(nitro, .direction = "down") %>%
    replace_na(replace = list(nitro = 0,
    creat_lab = 0,
    dobutamine_inf = 0,
    fentanyl_inf = 0,
    midaz_inf = 0,
    propofol_inf = 0,
    dex_inf = 0,
    nicardipine_inf = 0,
    amiodarone_inf = 0,
    fluids_inf = 0,
    milrinone_inf = 0,
    epinephrine_inf = 0,
    vasopressin_inf = 0,
    diltiazem_inf = 0,
    # pain_score = 0
    )) %>%
    ungroup()
}