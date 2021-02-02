# Decision tree - takes a while so commented out

# https://www.tidymodels.org/start/tuning/#tuning

tar_target(dt, decision_tree(
  cost_complexity = tune(),
  tree_depth = tune()
) %>%
  set_engine("rpart") %>%
  set_mode("regression")),

tar_target(tree_grid, dials::grid_regular(dials::cost_complexity(),
  dials::tree_depth(),
  levels = 5
)),

tar_target(
  tree_res,
  wf %>%
    add_model(dt) %>%
    tune_grid(
      resamples = folds,
      grid = tree_grid
    )
),

tar_target(dt_metrics, collect_metrics(tree_res)),

tar_target(dt_tuning_plot, dt_metrics %>%
  mutate(tree_depth = factor(tree_depth)) %>%
  ggplot2::ggplot(ggplot2::aes(cost_complexity,
    mean,

    color = tree_depth
  )) +
  ggplot2::geom_line(size = 1.5, alpha = 0.6) +
  ggplot2::geom_point(size = 2) +
  ggplot2::facet_wrap(~.metric, scales = "free", nrow = 2) +
  ggplot2::scale_x_log10(labels = scales::label_number()) +
  ggplot2::scale_color_viridis_d(option = "plasma", begin = .9, end = 0)),

# make_sbp
  df %>%
    mutate(noninvasivesystolic_nurse = as.numeric(
      as.character(noninvasivesystolic_nurse))) %>%
    mutate(systemicsystolic_nurse = as.numeric(
      as.character(systemicsystolic_nurse))) %>%
    mutate(noninvasivesystolic_nurse = case_when(
      noninvasivesystolic_nurse < 250 ~ noninvasivesystolic_nurse,
      TRUE ~ NA_real_
    )) %>%
    mutate(
      sbp_sys = coalesce(
          systemicsystolic,
          systemicsystolic_nurse
        )
    ) %>%
    mutate(
      sbp_ni = coalesce(
          noninvasivesystolic,
          noninvasivesystolic_nurse
        )
    ) %>%
    # this is preferentially taking the systemic measurement
    # when both systemic and non-invasive is available
    mutate(sbp = coalesce(
      sbp_sys,
      sbp_ni
    ))


targets::tar_load(nitro)
targets::tar_load(patient)
targets::tar_load(infusion_drug)
targets::tar_load(sbp_nurse_charting)
targets::tar_load(vital_aperiodic)
targets::tar_load(vital_periodic)
targets::tar_load(apachepatientresult)
targets::tar_load(apachepredvar)
targets::tar_load(creat)
targets::tar_load(fentanyl)
targets::tar_load(midaz)
targets::tar_load(propofol)
targets::tar_load(dobutamine)
targets::tar_load(dex)
targets::tar_load(nicardipine)
targets::tar_load(fluids)
targets::tar_load(amiodarone)
targets::tar_load(milrinone)
targets::tar_load(epinephrine)
targets::tar_load(vasopressin)
targets::tar_load(diltiazem)
targets::tar_load(pain)
devtools::load_all()


library(dplyr, warn.conflicts = FALSE)
df <- tibble(
  x_inf = c(0.0138, 1, 2),
  y_inf = c(1, NA, NA),
  x_sc = c(NA, NA, NA)
  )

df %>% mutate(
  across(ends_with("_inf"), coalesce, 0),
  across(ends_with("_sc"), coalesce, 0)
)


df %>% 
replace_na(replace = list(x_inf = 0))

