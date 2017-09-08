message(brk(), "start running inputMaps.R [", Sys.time(), "]", "\n")

## ensure global parameters exist (from global.R)
stopifnot(exists(c("paths")))

## -----------------------------------------------------------------------------
# load studyArea object (SpatialPointsDataFrame) and validate it using gBuffer
f <- file.path(paths$inputPath, "west.boreal.RData")
stopifnot(file.exists(f))
load(f)
studyArea <- Cache(rgeos::gBuffer, spgeom = studyArea, byid = TRUE, width = 0,
                   cacheRepo = paths$cachePath)
rm(f)

## ecodistricts etc. for leaflet maps ------------------------------------------
## downlooad ecodistricts etc. data
urls_eco <- list(
  ecozones = "http://sis.agr.gc.ca/cansis/nsdb/ecostrat/zone/ecozone_shp.zip",
  ecoprovinces = "http://sis.agr.gc.ca/cansis/nsdb/ecostrat/province/ecoprovince_shp.zip",
  ecoregions = "http://sis.agr.gc.ca/cansis/nsdb/ecostrat/region/ecoregion_shp.zip",
  ecodistricts = "http://sis.agr.gc.ca/cansis/nsdb/ecostrat/district/ecodistrict_shp.zip"
)

sapply(urls_eco, amc::dl.data, dest = paths$inputPath, unzip = TRUE)

## reproject/crop ecodistricts for studyArea
message("reprojecting ecodistricts...")
ecos <- c("ecozones", "ecoprovinces", "ecoregions", "ecodistricts")

ecodistricts <- Cache(shapefile, file.path(paths$inputPath, "Ecodistricts", "ecodistricts"),
                      cacheRepo = paths$cachePath)

allEcos <- function(ecos, ecoCRS, studyArea, cachePath) {
  studyAreaEco <- spTransform(studyArea, ecoCRS) %>%
    Cache(cacheRepo = cachePath)
  ecoOut <- list()
  for(ec in ecos) {
    message("reprojecting ",ec," ...")
    ecoOut[[ec]] <- shapefile(asPath(file.path(paths$inputPath, gsub(ec,pattern="^e", replacement = "E"), ec))) %>%
      crop(., studyAreaEco) %>%
      spTransform(., crs(studyArea)) %>%
      Cache(cacheRepo = cachePath, digestPathContent = TRUE)
  }
  return(ecoOut)
}

allEco <- allEcos(ecos, crs(ecodistricts), studyArea, cachePath = paths$cachePath) %>%
  Cache(cacheRepo = paths$cachePath)
list2env(allEco, .GlobalEnv)

message("reprojections complete!")

## create default study area for demo
demoArea <- ecodistricts[which(ecodistricts[["ECODISTRIC"]] == ._POLYNUM_.), ]
save(demoArea, file = file.path(paths$inputPath, paste0("demoArea_", ._POLYNUM_., ".rds")))

## create list of available polygons for leaflet -------------------------------
crs.lflt <- sp::CRS("+init=epsg:4326")
ecodistrictsLFLT <- spTransform(ecodistricts, crs.lflt)
ecoregionsLFLT <- spTransform(ecoregions, crs.lflt)
ecoprovincesLFLT <- spTransform(ecoprovinces, crs.lflt)
ecozonesLFLT <- spTransform(ecozones, crs.lflt)

availablePolygons <- names(urls_eco)
availablePolygonAdjective <- tools::toTitleCase(availablePolygons) %>%
  sapply(function(x) {
    substr(x, 1, nchar(x) - 1) ## trim the last letter
  }, USE.NAMES = FALSE)
availableProjections <- c("", "LFLT")
available <- data.frame(
  stringsAsFactors = FALSE,
  expand.grid(stringsAsFactors = FALSE,
              polygons = availablePolygons,
              projections = availableProjections),
  names = rep(tools::toTitleCase(availablePolygons), 2)
)

polygons <- lapply(seq_len(NROW(available)), function(ii) {
  get(paste0(available$polygons[ii], available$projections[ii]))
}) %>%
  setNames(available$names)

rm(list = c(names(urls_eco), paste0(names(urls_eco), "LFLT")))

polygonColours <- c(rep(c("red", "blue"), length(names(urls_eco))))
polygonIndivIdsColum <- list("ZONE_NAME", "PROVINCE_", "REGION_NAM", "ECODISTRIC") %>%
  set_names(names(polygons[1:4]))

## -----------------------------------------------------------------------------
message("finished running inputMaps.R [", Sys.time(), "]", "\n", brk())
