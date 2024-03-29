source("../skip-download.R")
# source("tests/skip-download.R") # from root directory

context("test-format: accidents")

test_that("format_collisions works", {
  df = format_collisions(stats19::accidents_sample_raw)
  expect_equal(nrow(df), nrow(stats19::accidents_sample_raw))
})

context("test-format: vehicles")

context("test-format: casualties")

context("test-format: sf")
test_that("format_column_names works", {
  # basic
  rd = names(stats19::accidents_sample_raw)
  expect_equal(nrow(rd), nrow(format_column_names(rd)))
})
test_that("format_sf works", {
  rd = format_collisions(stats19::accidents_sample_raw)
  df1 = format_sf(rd)
  df2 = format_sf(rd, lonlat = TRUE)
  expect_equal(nrow(df1), nrow(rd))
  expect_equal(nrow(df2), nrow(rd))
  expect_true(is(df1, "sf"))
  expect_true(is(df2, "sf"))
})

test_that("format_ppp returns ppp object", {
  rd = accidents_sample
  rd_ppp = format_ppp(rd)
  expect_true(is(rd_ppp, "ppp"))
})

test_that("is it possible to change window object in format_ppp", {
  rd = accidents_sample
  rd_ppp = format_ppp(rd)
  suppressWarnings({
    rd_ppp2 = format_ppp(
      rd,
      # bounding box of leeds which is smaller the default bbox which
      # covers all UK
      window = spatstat.geom::owin(c(425046.1, 435046.1), c(428577.2, 438577.2))
    )
  })
  # since the bbox is smaller there must be fewer points
  expect_true(rd_ppp2$n <= rd_ppp$n)
})

test_that("format_ppp exclude events with missing coordinates", {
  rd = accidents_sample
  rd_ppp = format_ppp(rd)
  rd2 = rd
  rd2[1, "location_easting_osgr"] = NA
  rd2[1, "location_northing_osgr"] = NA
  rd_ppp2 = format_ppp(rd2)
  # since the bbox is smaller there must be fewer points
  expect_true(rd_ppp2$n <= rd_ppp$n)
})

