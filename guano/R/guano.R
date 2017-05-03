# GUANO metadata package for R
#
# You may use, distribute, and modify this code under the terms of the MIT License.


#' Parse ISO 8601 subset timestamps
.parse.timestamp <- function(s) {
  if (is.na(s) || is.null(s) || s == "") {
    return(NA)
  } else if (endsWith(s, "Z")) {
    # UTC
    return(strptime(s, "%Y-%m-%dT%H:%M:%S", tz="UTC"))
  } else if (length(gregexpr(":", s)[[1]]) == 3) {
    # UTC offset
    len <- nchar(s)
    s <- paste(substr(s, 1, len-3), substr(s, len-1, len), sep="")
    return(strptime(s, "%Y-%m-%dT%H:%M:%S%z"))
  } else {
    # local
    return(strptime(s, "%Y-%m-%dT%H:%M:%S"))
  }
}


#' Maps metadata keys to a data type coercion function
data.types <- list(
  `Filter HP`=as.double,
  `Filter LP`=as.double,
  Humidity=as.double,
  Length=as.double,
  `Loc Accuracy`=as.integer,
  `Loc Elevation`=as.double,
  `Loc Position`=function(val) lapply(strsplit(val, " "), as.double)[[1]],
  Note=function(val) gsub("\\\\n", "\n", val),
  Samplerate=as.integer,
  #`Species Auto ID`=?, `Species Manual ID`=?,  # TODO: comma separated
  #Tags=?,  # TODO: comma separated
  TE=function(val) if (is.na(val) || is.null(val) || val == "") 1 else as.integer(val),
  `Temperature Ext`=as.double, `Temperature Int`=as.double,
  Timestamp=.parse.timestamp
)


#' Read a single GUANO file
#' 
#' @param filename The GUANO filename or path
#' @return list of named metadata fields
read.guano <- function(filename) {
  f <- file(filename, "rb")
  riff.id <- readChar(f, 4)
  if (length(riff.id) == 0 || riff.id != "RIFF") return(NULL)
  riff.size <- readBin(f, integer(), size=4, endian="little")
  wave.id <- readChar(f, 4)  # "WAVE"
  if (length(wave.id) == 0 || wave.id != "WAVE") return(NULL)
  
  read.subchunk <- function() {
    id <- readChar(f, 4)
    if (length(id) == 0 || id == "") return(NULL)
    size <- readBin(f, integer(), size=4, endian="little")
    list(id=id, size=size)
  }
  
  skip.subchunk <- function(chunk) {
    #print(sprintf("Skipping subchunk '%s' ...", chunk$id))
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
    Encoding(md.txt) <- "UTF-8"  # FIXME: this still isn't setting the encoding to UTF-8
    for (line in strsplit(md.txt, "\n")[[1]]) {
      line <- trimws(line)
      if (line == "") {
        next
      }
      toks <- strsplit(sub(":", "\n", line), "\n")
      key <- trimws(toks[[1]][1])
      val <- trimws(toks[[1]][2])
      if (is.na(key) || is.null(key) || key == "") {
        next
      }
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
#' @param pattern An optional glob pattern. Only files names which match will be returned (default "*.wav")
#' @param recursive logical. Should we recurse into sub-directories?
#' @return dataframe with metadata attributes as columns
read.guano.dir <- function(dirname, pattern="*.wav", recursive=FALSE) {
  filenames <- list.files(dirname, glob2rx(pattern), full.names=TRUE, recursive=recursive, ignore.case=TRUE)
  # read GUANO metadata as a one-row dataframe for each file
  metadatas <- lapply(lapply(as.list(filenames), read.guano), as.data.frame)
  # merge all into one dataframe, filling in missing fields with NA
  do.call(rbind.fill, metadatas)
}


## EXAMPLE USAGE

# Set custom metadata type coercion rules
#integer.list <- function(x) lapply(strsplit(x, ","), as.integer)
#double.list  <- function(x) lapply(strsplit(x, ","), as.double)
#data.types[["BAT|SampleStart"]] <- integer.list
#data.types[["BAT|Ts"]] <- double.list
#data.types[["BAT|SINR"]] <- double.list

# Parse some GUANO files
#md <- read.guano("test.wav")
#print(md$Timestamp)

#md <- read.guano("/Users/driggs/workspace/batutils/testdata/sonobat4.1/FrioRvrBigSpgsRanchTX-Lwr-1920140308_232208-Myve.wav")
#print(md)
#res <- read.guano.dir("/Users/driggs/workspace/batutils/testdata/sonobat4.1")
#View(res)
