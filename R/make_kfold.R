
#' @importFrom dplyr inner_join
#' @export
make_kfold <- function(x, 
k 
# seed 
) {
  cli::cli_alert("Creating CV folds...")

  # set.seed(seed) # not needed because targets has seed
  pid <- unique(x$pid)
  fold <- sample(1:k, size = length(pid), replace = TRUE)

  result <- dplyr::inner_join(x, data.frame(pid, fold), by = "pid")

  return(result)
}