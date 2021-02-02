#' @title Connect with database

#' @returns Connection to eicu_crd database from 
#' physionet-data in bigquery
#' @param billing Account for billing in bigquery
#' @importFrom DBI dbConnect
#' @importFrom bigrquery bigquery bq_auth
#' @export
make_connection <- function(billing) {

  eicu_nitro <- dbConnect(bigquery(), 
                               project = "physionet-data", 
                               dataset = "eicu_crd",
                               billing = "eicu-273519")

}
