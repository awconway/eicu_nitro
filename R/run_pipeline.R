#' @importFrom targets tar_make tar_read
#' @importFrom dplyr distinct pull summarise filter select
#' @export

run_pipeline <- function() {

  # Run targets -------------------------------------------------------------

  tar_make()


  # Model Summary -----------------------------------------------------------
  cli::cli_h1("Model summary")
  print(targets::tar_read(base_rec)$var_info %>%
    select(-source),
  n = Inf
  )
  print(targets::tar_read(base_rec))
  cli::cli_end()

  cli::cli_h1("XGboost model summary")
  print(targets::tar_read(boost_rec)$var_info %>%
    select(-source),
  n = Inf
  )
  print(targets::tar_read(boost_rec))
  cli::cli_end()

  # Summary of data ---------------------------------------------------------

  cli::cli_h1("Summary of data used in modelling")
  cli::cli_alert_info("Training dataset contains {.val
  {nrow(tar_read(invasiveTraining))}
  } observations from {.val
                 {tar_read(invasiveTraining) %>%
                 distinct(id) %>%
                 nrow()}} patients across {.val
                 {tar_read(invasiveTraining) %>%
                 distinct(hospitalid) %>%
                 nrow()}} hospitals")
  cli::cli_alert_info("Testing dataset contains {.val
  {nrow(tar_read(testing))}} observations from {.val
                 {tar_read(testing) %>%
                 distinct(id) %>%
                 nrow()}
                 } patients across {.val
                 {tar_read(testing) %>%
                 distinct(hospitalid) %>%
                 nrow()}} hospitals")

  # Baseline ----------------------------------------------------------------

  cli::cli_h1("Baseline comparison")

  baseline_rsq <- round(tar_read(baseline)$.estimate[[2]], 2)
  baseline_rmse <- round(tar_read(baseline)$.estimate[[1]], 2)

  cli::cli_alert_info("RMSE to improve on is {.val
                 {baseline_rmse}}")
  cli::cli_alert_info("R2 to improve on is {.val
                 {baseline_rsq}}")
  cli::cli_end()

  # XGBoost model -----------------------------------------------------------

  cli::cli_h1("Metrics from cross-validated XGboost model")
  boost_rmse <- tar_read(boost_metrics)|>
  summarize(min = min(mean))
  if (boost_rmse < baseline_rmse) {
    cli::cli_alert_success("RMSE was {.val {boost_rmse}}")
  } else {
    cli::cli_alert_danger("RMSE was {.val {boost_rmse}}")
  }

  # boost_rsq <- round(tar_read(boost_metrics)$mean[[2]], 2)
  # if (boost_rsq > baseline_rsq) {
  #   cli::cli_alert_success("R2 was {.val {boost_rsq}}")
  # } else {
  #   cli::cli_alert_danger("R2 was {.val {boost_rsq}}")
  # }
  cli::cli_end()

  # Random forest model -----------------------------------------------------

  rf_rmse <- round(tar_read(rf_metrics)$mean[[1]], 2)
  rf_rsq <- round(tar_read(rf_metrics)$mean[[2]], 2)

  cli::cli_h1("Metrics from cross-validated random forest model")
  if (rf_rmse < baseline_rmse) {
    cli::cli_alert_success("RMSE was {.val {rf_rmse}}")
  } else {
    cli::cli_alert_danger("RMSE was {.val {rf_rmse}}")
  }
  if (rf_rsq > baseline_rsq) {
    cli::cli_alert_success("R2 was {.val {rf_rsq}}")
  } else {
    cli::cli_alert_danger("R2 was {.val {rf_rsq}}")
  }
  cli::cli_end()

  # Linear model ------------------------------------------------------------

  cli::cli_h1("Metrics from cross-validated linear model")
  glm_rmse <- round(tar_read(glm_metrics)$mean[[1]], 2)
  glm_rsq <- round(tar_read(glm_metrics)$mean[[2]], 2)

  if (glm_rmse < baseline_rmse) {
    cli::cli_alert_success("RMSE was {.val {glm_rmse}}")
  } else {
    cli::cli_alert_danger("RMSE was {.val {glm_rmse}}")
  }
  if (glm_rsq > baseline_rsq) {
    cli::cli_alert_success("R2 was {.val {glm_rsq}}")
  } else {
    cli::cli_alert_danger("R2 was {.val {glm_rsq}}")
  }
  cli::cli_end()

  # Lasso model -------------------------------------------------------------

  cli::cli_h1("Metrics from cross-validated lasso model")

  lasso_rmse <- tar_read(lasso_metrics) %>%
    filter(.metric == "rmse") %>%
    summarise(lowest = min(mean)) %>%
    pull(lowest) %>%
    round(2)


  lasso_rsq <- tar_read(lasso_metrics) %>%
    filter(.metric == "rsq") %>%
    summarise(highest = max(mean)) %>%
    pull(highest) %>%
    round(2)

  if (lasso_rmse < baseline_rmse) {
    cli::cli_alert_success("Lowest RMSE was {.val {lasso_rmse}}")
  } else {
    cli::cli_alert_danger("Lowest RMSE was {.val {lasso_rmse}}")
  }

  if (lasso_rsq > baseline_rsq) {
    cli::cli_alert_success("Highest R2 was {.val {lasso_rsq}}")
  } else {
    cli::cli_alert_danger("Highest R2 was {.val {lasso_rsq}}")
  }

  cli::cli_alert_info("See plots for more info on tuning params and variable importance for lasso models")

  print(tar_read(lasso_vip_plot))
  print(tar_read(lasso_plot))

  # Ridge model -------------------------------------------------------------

  cli::cli_h1("Metrics from cross-validated ridge model")

  ridge_rmse <- tar_read(ridge_metrics) %>%
    filter(.metric == "rmse") %>%
    summarise(lowest = min(mean)) %>%
    pull(lowest) %>%
    round(2)


  ridge_rsq <- tar_read(ridge_metrics) %>%
    filter(.metric == "rsq") %>%
    summarise(highest = max(mean)) %>%
    pull(highest) %>%
    round(2)

  if (ridge_rmse < baseline_rmse) {
    cli::cli_alert_success("Lowest RMSE was {.val {ridge_rmse}}")
  } else {
    cli::cli_alert_danger("Lowest RMSE was {.val {ridge_rmse}}")
  }

  if (ridge_rsq > baseline_rsq) {
    cli::cli_alert_success("Highest R2 was {.val {ridge_rsq}}")
  } else {
    cli::cli_alert_danger("Highest R2 was {.val {ridge_rsq}}")
  }

  cli::cli_alert_info("See plots for more info on tuning params and variable importance for ridge models")

  print(tar_read(ridge_vip_plot))
  print(tar_read(ridge_plot))
}
