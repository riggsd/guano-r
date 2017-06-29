# GUANO-R

An R package for reading GUANO bat acoustic metadata.

[GUANO](https://github.com/riggsd/guano-py/blob/master/doc/guano_specification.md) is the "Grand Unified Acoustic Notation Ontology", a universal, extensible metadata specifically for use with bat acoustic recordings.


## Installation

This code should still be considered "example quality"!

```r
install.packages("devtools")
devtools::install_github("riggsd/guano-r", subdir="guano")

library("guano")
```

Note: If installation from GitHub fails with "Peer certificate cannot be authenticated", as on some corporate networks, run the following commands before `install_github`:

```r
library(httr)
set_config(config(ssl_verifypeer=0L))
```

## Example Usage

Read GUANO metadata from a single file as a named list:

```r
> read.guano("/Users/driggs/bat_calls/AZ/Tucson/2017-03-27 Walkabout/2017-03-27 20-48-52.wav")

$`GUANO|Version`
[1] "1.0"

$Timestamp
[1] "2017-03-27 20:48:52"

$Make
[1] "Titley Scientific"

$Model
[1] "Walkabout"

$`Firmware Version`
[1] "0.104"

$`Species Manual ID`
[1] "Myse"

$`Loc Position`
[1]   32.34322 -110.96443
```

Read GUANO metadata from all files in a directory as a single dataframe:

```r
df <- read.guano.dir("/Users/driggs/bat_calls/", recursive=TRUE)
View(df)
```


Work with bat calls in the geospatial domain:

```r
library("sp")

# remove all bat calls which don't have a GPS point
purged.df <- df[!is.na(df[["Loc.Position.Lat"]]),]

# extract the coordinates
xy <- purged.df[,c("Loc.Position.Lon", "Loc.Position.Lat")]

# produce a spatial dataframe ready for GIS analysis
wgs84 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
spdf <- SpatialPointsDataFrame(xy, purged.df, proj4string=wgs84)
plot(spdf)
```

## License

You may use, distribute, and modify this code under the terms of the [MIT License](https://opensource.org/licenses/MIT).
