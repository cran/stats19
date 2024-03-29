% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read_collisions}
\alias{read_collisions}
\title{Read in STATS19 road safety data from .csv files downloaded.}
\usage{
read_collisions(
  year = NULL,
  filename = "",
  data_dir = get_data_directory(),
  format = TRUE,
  silent = FALSE
)
}
\arguments{
\item{year}{Single year for which data are to be read}

\item{filename}{Character string of the filename of the .csv to read, if this is given, type and
years determine whether there is a target to read, otherwise disk scan would be needed.}

\item{data_dir}{Where sets of downloaded data would be found.}

\item{format}{Switch to return raw read from file, default is \code{TRUE}.}

\item{silent}{Boolean. If \code{FALSE} (default value), display useful progress
messages on the screen.}
}
\description{
Read in STATS19 road safety data from .csv files downloaded.
}
\section{Details}{

This is a wrapper function to access and load stats 19 data in a user-friendly way.
The function returns a data frame, in which each record is a reported incident in the
STATS19 data.
}

\examples{
\donttest{
if(curl::has_internet()) {
dl_stats19(year = 2019, type = "collision")
ac = read_collisions(year = 2019)

dl_stats19(year = 2019, type = "collision")
ac_2019 = read_collisions(year = 2019)
}
}
}
