library(leaflet)
library(shiny)
library(shinydashboard)
library(rgdal)
library(raster)

ras <- stack(list.files("data", full.names = TRUE, pattern = "*.tif$"))

dashboardPage(
  dashboardHeader(
    title = "R Gis - Raster Time Series Analysis",
    titleWidth = 450
  ),
  dashboardSidebar(
    h4("Filter:"),
    actionButton("filterCheckSav", "Savitzky-Golay")
    # checkboxInput("filterCheckWhit", "Whittaker", value = FALSE)
  ),

  dashboardBody(
    fluidRow(
      tabBox(
        title = "Interactive Image Analysis", id = "tabset",
        tabPanel("Raster",
                 plotOutput("rasPlot", click = "rasPlot_click"),
                 #fileInput("ras", h3("Raster Input"), multiple = T),
                 sliderInput("layer", 
                             "Plot Timestep", 
                             min = 1, 
                             max = nlayers(ras), 1, 
                             width="100%"),
                 dateRangeInput("dates", h3("Date range"))),
        tabPanel("Basemap", 
                 leafletOutput("Map", width = "100%", height = 700),
                 sliderInput("layer_render", 
                             "Plot Timestep", 
                             min = 1, 
                             max = nlayers(ras), 1, 
                             width="100%"))
      ),
      
      box(
        title = "Properties", status = "info", solidHeader = TRUE,
        HTML("<b>Layers:</b>"),
        textOutput("rasNlayers"),
        HTML("<b>Resolution:</b>"),
        textOutput("rasRes"),
        HTML("<b>Projection:</b>"),
        textOutput("rasProj"),
        h4("Selected Coordinates"),
        textOutput("cellnumber")
      ),
      
      box(
        title = "Time Series", status = "success", solidHeader = TRUE,
        plotOutput("TSplot")
      ),
      
      box(
        title = "Values", status = "info", solidHeader = TRUE,
        tableOutput("df")
      )
    )
  )
)