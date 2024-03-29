% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ulez.R
\name{get_ULEZ}
\alias{get_ULEZ}
\title{Download DVLA-based vehicle data from the TfL API using VRM.}
\usage{
get_ULEZ(vrm)
}
\arguments{
\item{vrm}{A list of VRMs as character strings.}
}
\description{
Download DVLA-based vehicle data from the TfL API using VRM.
}
\section{Details}{

This function takes a character vector of vehicle registrations (VRMs) and returns DVLA-based vehicle data from TfL's API, included ULEZ eligibility.
It returns a data frame of those VRMs which were successfully used with the TfL API.  Vehicles are either compliant, non-compliant or exempt.  ULEZ-exempt vehicles will not have all vehicle details returned - they will simply be marked "exempt".

Be aware that the API has usage limits.  The function will therefore limit API calls to below 50 per minute - this is the maximum rate before an API key is required.
}

\examples{
\donttest{
if(curl::has_internet()) {
vrm = c("1RAC","P1RAC")
get_ULEZ(vrm = vrm)
}
}
}
