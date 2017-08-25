stopifnot(exists(c("crs.lflt", "globalRasters", "mySim", "polygons")))

## -----------------------------------------------------------------------------
function(input, output, session) {
  #react <- reactiveValues()
  seed <- sample(1e8,1)
  set.seed(seed)
  message("Current seed is: ", seed)

  ## currentPolygon is a reactiveVal object
  currentPolygon <- callModule(leafletMap, "leafletMap")

  ## do initial run of the model for the default study area
  mySimCopy <- Copy(mySim)
  end(mySimCopy) <- start(mySimCopy)
  message("Running initial `spades` call...")
  initialRun <- Cache(spades, sim = mySimCopy,
                      debug = "paste(Sys.time(), paste(unname(current(sim)), collapse = ' '))",
                      .plotInitialTime = NA)
  message("Finished Initial `spades` call...")

  callModule(initialMap, "DEM", initialRun, "DEM")
  callModule(initialMap, "forestAge", initialRun, "forestAge")
  callModule(initialMap, "habitatQuality", initialRun, "habitatQuality")
  callModule(initialMap, "percentPine", initialRun, "percentPine")
  callModule(simOutputs, "simFigs", initialRun)
  callModule(dataInfo, "modDataInfo")
  callModule(simInfo, "simInfoTabs", initialRun)
  callModule(moduleInfo, "modInfoBoxes", initialRun) ## error due to missing Rmd files
  #callModule(moduleParams, "modParams", initialRun)
}
