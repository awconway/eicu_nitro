
#' @importFrom dplyr left_join
#' @importFrom stats rbinom
#' @export
make_train_id <- function(x, seed, frac) {
  cli::cli_alert("Splitting data into training and test sets...")

  pid <- unique(x$pid)
  set.seed(seed)
  train <- stats::rbinom(n = length(pid), size = 1, prob = frac)

  tmp <- data.frame(pid, train)

  result <- dplyr::left_join(x, tmp, by = "pid")

  return(result)
}