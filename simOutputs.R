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
    map <- sim$landscape[[mapID]]

    map_title <- switch(
      mapID,
      "DEM" = paste0("DEM (", start(sim), ")"),
      "forestAge" = paste0("Forest age (", start(sim), ")"),
      "percentPine" = paste0("Percent pine (", start(sim), ")"),
      "habitatQuality" = paste0("Habitat quality (", start(sim), ")")
    )

    plot(map, main = map_title)
    plot(sim$caribou, add = TRUE)
  })
}
