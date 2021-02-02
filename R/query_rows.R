#' Download data from bigquery using both SELECT and
#' WHERE conditions

#' @description Queries run using this function select
#' all the entries from the tables for all patients
#' who had at least one entry for nitroglycerin in the
#' infusiondrug table
#'
#' @returns dataframe with data from table in eicu dataset
#' stored in bigquery
#' @importFrom dplyr tbl collect sql
#' @importFrom glue glue

#' @param connection DBI connection to bigquery
#' @param table name of table to query
#' @param columns vector of column names from the table to select
#' @param rows condition to pass to WHERE query for the table
#' @export

query_rows <- function(connection, table, columns, rows) {
  cli::cli_process_start("Downloading {table} table from bigquery",
    on_exit = "done"
  )
  query <- glue("
SELECT *
FROM   (SELECT {columns}
        FROM   `physionet-data.eicu_crd.{table}` {table}
        WHERE  ( {table}.patientunitstayid IN
                 (SELECT INFUSION.patientunitstayid
                  FROM
                           `physionet-data.eicu_crd.infusiondrug` INFUSION
                                                     WHERE
                           INFUSION.drugname = 'Nitroglycerin (mcg/min)') ))
WHERE  ( {rows})
")

  result <- tbl(
    connection,
    sql(query)
  ) %>%
    collect()

  cli::cli_process_done()
  cli::cli_rule(left = "Query results for the {table} table")
  cli::cli_alert_info("Selected the {.var {names(result)}} columns")
  cli::cli_alert_info("Retrieved {.val
  {nrow(result)}} rows of data limited to the conditions: '{rows}'")
  cli::cli_rule()
  cli::cli_end()
  return(result)
}