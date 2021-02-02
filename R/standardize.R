#' @export
standardize <- function(x){
  return( (x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE))
}
