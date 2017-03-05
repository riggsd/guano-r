# GUANO metadata package for R
#
# You may use, distribute, and modify this code under the terms of the MIT License.


#' Maps metadata keys to a data type coercion function
data.types <- list(
  `Filter HP`=double, Length=double, `Loc Elevation`=double, `Loc Accuracy`=integer,
  TE=integer
)


#' Read a single GUANO file
#' 
#' @param filename The GUANO filename or path
#' @return list of named metadata fields
read.guano <- function(filename) {
  print(filename)
  f <- file(filename, "rb")
  riff.id <- readChar(f, 4)  # "RIFF"
  print(riff.id)
  riff.size <- readBin(f, integer(), size=4, endian="little")
  print(riff.size)
  wave.id <- readChar(f, 4)  # "WAVE"
  print(wave.id)

  read.subchunk <- function() {
    id <- readChar(f, 4)
    if (id == "") return(NULL)
    size <- readBin(f, integer(), size=4, endian="little")
    list(id=id, size=size)
  }
  
  skip.subchunk <- function(chunk) {
    print(sprintf("Skipping subchunk '%s' ...", chunk$id))
    pos <- seek(f, NA)
    seek(f, pos + chunk$size)
  }
  
  md <- list()

  while (!is.null(chunk <- read.subchunk())) {
    if (chunk$id != "guan") {
      skip.subchunk(chunk)
      next
    }
    md.txt <- readChar(f, chunk$size)
    Encoding(md.txt) <- "UTF-8"
    print(Encoding(md.txt))  # FIXME: why isn't the encoding set to UTF-8?!
    for (line in strsplit(md.txt, "\n")[[1]]) {
      line <- trimws(line)
      if (line == "") {
        next
      }
      toks <- strsplit(sub(":", "\n", line), "\n")
      key <- trimws(toks[[1]][1])
      val <- trimws(toks[[1]][2])
      if (!is.null(data.types[[key]])) {
        val <- data.types[[key]](val)
      }
      md[[key]] <- val
    }
  }

  close(f)
  return(md)
}


#' Read all GUANO file in a directory as a single dataframe
#' 
#' @param dirname The directory name (or path) which contains GUANO files
#' @return dataframe with metadata attributes as columns
read.guano.dir <- function(dirname) {
  dirname
}


## EXAMPLE USAGE

# Set custom metadata type coercion rules
integer.list <- function(x) lapply(strsplit(x, ","), as.integer)
double.list  <- function(x) lapply(strsplit(x, ","), as.double)
data.types[["BAT|SampleStart"]] <- integer.list
data.types[["BAT|Ts"]] <- double.list
data.types[["BAT|SINR"]] <- double.list

# Parse some GUANO files
md <- read.guano("test.wav")
print(md)
