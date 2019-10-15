## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  out.width = "50%"
)

## ----pkgs, warning=FALSE-------------------------------------------------
pkgs = c(
  "sf",          # spatial data package
  "stats19",     # downloads and formats open stats19 crash data
  "dplyr",       # a package data manipulation, part of the tidyverse
  "tmap"         # for making maps
)

## ----cite, echo=FALSE----------------------------------------------------
knitr::write_bib(x = pkgs, "packages.bib")

## ---- eval=FALSE---------------------------------------------------------
#  remotes::install_cran(pkgs)
#  # remotes::install_github("ITSLeeds/pct")

