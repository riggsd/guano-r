library(guano)


context("parse.timestamp tests")

test_that("parse ISO 8601 datetimes", {
  expect_equal(.parse.timestamp(NA),   NA)
  expect_equal(.parse.timestamp(NULL), NA)
  expect_equal(.parse.timestamp(""),   NA)
  
  expect_equal(.parse.timestamp("2015-12-31T23:59:59"),        as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S"))
  expect_equal(.parse.timestamp("2015-12-31T23:59:59.123"),    as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S"))
  expect_equal(.parse.timestamp("2015-12-31T23:59:59.123456"), as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S"))

  expect_equal(.parse.timestamp("2015-12-31T23:59:59Z"),        as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S", tz="UTC"))
  expect_equal(.parse.timestamp("2015-12-31T23:59:59.123Z"),    as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S", tz="UTC"))
  expect_equal(.parse.timestamp("2015-12-31T23:59:59.123456Z"), as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S", tz="UTC"))
  
  expect_equal(.parse.timestamp("2015-12-31T23:59:59+04:00"),        as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S", tz="Etc/GMT+4"))
  expect_equal(.parse.timestamp("2015-12-31T23:59:59.123+04:00"),    as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S", tz="Etc/GMT+4"))
  expect_equal(.parse.timestamp("2015-12-31T23:59:59.123456+04:00"), as.POSIXlt("2015-12-31T23:59:59", format="%Y-%m-%dT%H:%M:%S", tz="Etc/GMT+4"))
})
