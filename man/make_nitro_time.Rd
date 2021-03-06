% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_nitro_time.R
\name{make_nitro_time}
\alias{make_nitro_time}
\title{Add total time on nitro}
\usage{
make_nitro_time(df)
}
\arguments{
\item{df}{data_formatted from the pipeline}
}
\description{
This function will add a column that is a
total of the time in minutes that the patient has been on
a nitroglycerin infusion continuously. The time is reset
when the infusion dose is zero.
}
