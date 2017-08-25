library(shiny)
library(shinydashboard)
library(shinyBS)

dashboardPage(skin = "green",
  dashboardHeader(title = "templateApp"),
  dashboardSidebar(width = 300,
    sidebarMenu(id = "wholeThing",
      h4(HTML("&nbsp;"), "Maps"),
      menuItem("Change polygon layer", tabName = "Polygons", icon = icon("map-o")),
      menuItem("DEM", tabName = "dem_Map", icon = icon("area-chart")),
      menuItem("Forest age", tabName = "age_Map", icon = icon("clock-o")),
      menuItem("Habitat quality", tabName = "habitat_Map", icon = icon("signal")),
      menuItem("Percent pine", tabName = "pine_Map", icon = icon("tree")),
      br(),
      h4(HTML("&nbsp;"), "Figures"),
      menuItem("Simulation outputs", tabName = "simFigures", icon = icon("bar-chart")),
      br(),
      h4(HTML("&nbsp;"), "Model details"),
      menuItem("Data Sources", tabName = "dataSources", icon = icon("database")),
      menuItem("Model Overview", tabName = "simDiagrams", icon = icon("sitemap")),
      menuItem("Module Info", tabName = "moduleInfo", icon = icon("puzzle-piece")),
      menuItem("Parameter Values", tabName = "paramVals", icon = icon("wrench")),
      br(),
      sidebarFooter() ## CSS rules push the footer to the bottom of the sidebar
    )
  ),
  dashboardBody(
    includeCSS("www/style.css"),

    tabItems(
      tabItem("dem_Map", initialMapUI("DEM")),
      tabItem("age_Map", initialMapUI("forestAge")),
      tabItem("habitat_Map", initialMapUI("habitatQuality")),
      tabItem("pine_Map", initialMapUI("percentPine")),
      tabItem("simFigures", simOutputsUI("simFigs")),

      tabItem("dataSources", dataInfoUI("modDataInfo")),
      tabItem("simDiagrams", simInfoUI("simInfoTabs")),
      tabItem("moduleInfo", moduleInfoUI("modInfoBoxes")),
      #tabItem("paramVals", moduleParamsUI("modParams")),
      tabItem("paramVals", p("NOT YET IMPLEMENTED")),

      ## do polygons last because it takes the longest
      tabItem("Polygons", fluidRow(
        tabBox(width = 12,
               tabPanel("Current Polygons", tabName = "Polygons1",
                        fluidRow(leafletMapUI("leafletMap")))
               )
        )
      )
    ),

    copyrightFooter(copyrightInfo) ## defined in global.R
  )
)
