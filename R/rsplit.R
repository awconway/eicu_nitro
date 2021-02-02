#' Make rsplit object
#' 
#' @description This is a function from rsample that is
#' not exported but we need it because we use our own method
#' for the split that takes into account patient id
#' @export
#' @param in_id vector of integers taken from data_split where
#' the column `train` equals 1 (to select training set)
#' @param out_id vector of integers taken from data_split where
#' the column `train` equals 0 (to select testing set)
#' 

custom_rsplit <- function(data, in_id, out_id) {
  if (!is.data.frame(data) & !is.matrix(data))
    stop("`data` must be a data frame.", call. = FALSE)
  
  if (!is.integer(in_id) | any(in_id < 1))
    stop("`in_id` must be a positive integer vector.", call. = FALSE)
  
  if(!all(is.na(out_id))) {
    if (!is.integer(out_id) | any(out_id < 1))
      stop("`out_id` must be a positive integer vector.", call. = FALSE)
  }
  
  if (length(in_id) == 0)
    stop("At least one row should be selected for the analysis set.",
         call. = FALSE)
  
  structure(
    list(
      data = data,
      in_id = in_id,
      out_id = out_id
    ),
    class = "rsplit"
  )
}