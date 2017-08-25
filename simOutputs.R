### simulation outputs (graphs and figures) ------------------------------------
simOutputsUI <- function(id) {
  ns <- NS(id)

  fluidRow(
    tabBox(width = 12,
           tabPanel("Landscape", plotOutput(ns("landscape")))
    )
  )
}

simOutputs <- function(input, output, session, sim) {
  output$landscape <- renderPlot({
    Plot(sim$landscape)
  })
}

### initial map ----------------------------------------------------------------
initialMapUI <- function(id) {
  ns <- NS(id)

  fluidRow(
    plotOutput(ns("map_init"))
  )
}

initialMap <- function(input, output, session, sim, mapID) {
  output$map_init <- renderPlot({
    switch(
      mapID,
      "DEM" = {
        map <- sim$landscape[[mapID]]
        map_title <- paste0("DEM (", start(sim), ")")
      },
      "forestAge" = {
        map <- sim$landscape[[mapID]]
        map_title <- paste0("Forest age (", start(sim), ")")
      },
      "percentPine" = {
        map <- sim$landscape[[mapID]]
        map_title <- paste0("Percent pine (", start(sim), ")")
      },
      "habitatQuality" = {
        map <- sim$landscape[[mapID]]
        map_title <- paste0("Habitat quality (", start(sim), ")")
      }
    )

    clearPlot()
    Plot(map, title = map_title)
    Plot(sim$caribou, addTo = map)
  })
}
