## load packages and set various options ---------------------------------------
if (tryCatch(packageVersion("amc") < "0.1.1.9000", error = function(x) TRUE)) {
  devtools::install_github("achubaty/amc")
}

if (tryCatch(packageVersion("SpaDES.core") < "0.1.0", error = function(x) TRUE)) {
  devtools::install_github("PredictiveEcology/SpaDES.core")
}

if (tryCatch(packageVersion("SpaDES.shiny") < "0.1.0", error = function(x) TRUE)) {
  devtools::install_github("PredictiveEcology/SpaDES.shiny@development")
}

if (tryCatch(packageVersion("reproducible") < "0.1.3.9002", error = function(x) TRUE)) {
  devtools::install_github("PredictiveEcology/reproducible@development")
}

library(shiny)
library(shinyBS)
library(shinydashboard)
library(shinyjs)

library(sp)
library(rgdal)
library(raster)
library(leaflet)

library(amc)
library(data.table)
library(DiagrammeR)
library(ggvis)
library(magrittr)
library(markdown)
library(parallel)
library(RColorBrewer)

library(quickPlot)
library(reproducible)
library(SpaDES.tools)
library(SpaDES.core)
library(SpaDES.shiny)

raster::rasterOptions(chunksize = 1e9, maxmemory = 4e10)

._MAXCLUSTERS_. <- 2
._OS_. <- tolower(Sys.info()[["sysname"]])
._USER_. <- Sys.info()[["user"]]

._POLYNUM_. <- 618  ## ecodistrict polygon number to use for demoArea

paths <- list(
  cachePath = "cache",    ## symlinked to ~/SpaDES/cache
  modulePath = system.file("sampleModules", package = "SpaDES.core"),
  inputPath = "inputs",
  outputPath = "outputs"
)
setPaths(
  cachePath = paths$cachePath,
  modulePath = paths$modulePath,
  inputPath = paths$inputPath,
  outputPath = paths$outputPath
)

## source additional app functions / modules -----------------------------------
brk <- function() {
  paste0(paste0(rep("-", getOption("width")), collapse = ""), "\n")
}

source("inputMaps.R")
source("leaflet.R")
source("simOutputs.R") # override functions in SpaDES.shiny package

## ---- begin "for development use only"
if (FALSE) {
  ## These are all "dangerous"!
  ## in the sense that they should never be run inadvertently
  ## To rerun the spades initial call, delete the mySim object in the .GlobalEnv ##
  reproducible::clearCache(cacheRepo = "cache")
  rm(cl)
  file.remove(dir("outputs", recursive = TRUE, full.names = TRUE))
  unlink("outputs", force = TRUE)
  unlink("cache", force = TRUE, recursive = TRUE)
}
## ---- end "for development use only"

copyrightInfo <- paste(
  shiny::icon("copyright",  lib = "font-awesome"), "Copyright ",
  format(Sys.time(), "%Y"),
  paste("Her Majesty the Queen in Right of Canada,",
        "as represented by the Minister of Natural Resources Canada.")
)

## initialize app --------------------------------------------------------------
message(brk(), "  initializing app [", Sys.time(), "]", "\n", brk())

if (!exists("globalRasters")) globalRasters <- list() ## what's this for?

curDir <- getwd()
message("Current working directory: ", curDir)

## start cluster if desired
if (._MAXCLUSTERS_. > 0) {
  if (!exists("cl")) {
    ncores <- if (._USER_. == "achubaty") {
      pmin(._MAXCLUSTERS_., detectCores() / 2)
    } else {
      pmin(._MAXCLUSTERS_., detectCores() - 1)
    }

    message("Spawning ", ncores, " threads")
    if (._OS_. == "windows") {
      clusterType = "SOCK"
    } else {
      clusterType = "FORK"
    }
    cl <- makeCluster(ncores, type = clusterType)
    if (._OS_. == "windows") {
      #clusterExport(cl = cl, varlist = list("objects", "shpStudyRegion"))
    }
    message("  Finished spawning multiple threads.")
  }
}

## initialize simulation -------------------------------------------------------

## load CRS for the boreal raster
load(file.path(paths$inputPath, "west.boreal.RData")) ## loads `studyArea` object (spdf)
crs.boreal <- CRS(proj4string(studyArea))

times <- list(start = 2005, end = 2020)
parameters <- list(
  .globals = list(stackName = "landscape", burnStats = "nPixelsBurned")
)

objects <- list(studyArea = demoArea) ## demoArea defined in inputMaps.R

modules <- list(
  "caribouMovement",
  "fireSpread",
  "randomLandscapes"
)

mySim <- simInit(times = times, params = parameters, modules = modules,
                 objects = objects, paths = paths)#, outputs = outputs)

## -----------------------------------------------------------------------------
message(brk(), "finished running global.R [", Sys.time(), "]", "\n", brk())
