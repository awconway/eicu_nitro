#' @title Connect with database

#' @returns Connection to eicu database from 
#' your copy of physionet-data in bigquery
#' @param billing Account for billing in bigquery
#' @param dataset name of bigquery dataset where 
#' eicu data has been copied into
#' @importFrom DBI dbConnect
#' @importFrom bigrquery bigquery
#' @export
make_connection <- function(project,
                            dataset,
                            billing) {
  eicu_nitro <- dbConnect(bigquery(), 
                               project = project, 
                               dataset = dataset,
                               billing = billing)

}
