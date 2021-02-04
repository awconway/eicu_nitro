#' Download data from bigquery using only a SELECT condition

#' @description Queries run using this function select
#' all the entries from the tables for all patients
#' who had at least one entry for nitroglycerin in the
#' infusiondrug table

#' @importFrom glue glue
#' @returns Character string of SQL query
#' @importFrom dplyr tbl collect sql
#' @param connection DBI connection to bigquery
#' @param query SQL query as a string
#' @param table name of table to query
#' @param columns vector of column names from the table to select
#' @export
query_cols <- function(connection, table, columns) {
  cli::cli_process_start("Downloading {table} table from bigquery",
    on_exit = "done"
  )
  query <- glue("
SELECT {columns}
FROM   `physionet-data.eicu_crd.{table}` {table}
WHERE  {table}.patientunitstayid IN (SELECT INFUSION.patientunitstayid
                                          FROM
       `physionet-data.eicu_crd.infusiondrug`
       INFUSION
                                          WHERE
              INFUSION.drugname = 'Nitroglycerin (mcg/min)')
          ")

  result <- tbl(
    connection,
    sql(query)
  ) %>%
    collect()

  cli::cli_process_done()
  cli::cli_rule()
  cli::cli_alert_info("Selected the {.var {names(result)}} columns")
  cli::cli_alert_info("Retrieved {.val {nrow(result)}} rows of data")
  cli::cli_rule()
  cli::cli_end()
  return(result)
}