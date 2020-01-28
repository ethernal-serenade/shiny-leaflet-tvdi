library(leaflet)
library(shiny)
library(shinydashboard)
library(rgdal)
library(raster)

ras <- stack(list.files("data", full.names = TRUE, pattern = "*.tif$"))

function (input, output, sesion){
  xBase <- (extent(ras)[2] + extent(ras)[1]) / 2
  yBase <- (extent(ras)[4] + extent(ras)[3]) / 2
  sp <- SpatialPoints(data.frame(xBase, yBase))
  crs(sp) <- crs(ras)
  sp <- spTransform(sp, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  
  plot(ras[[1]])
  points(sp)
  output$rasPlot <- renderPlot({
    plot(ras[[input$layer]])
  }, height = 400)
  
  output$rasProj <- renderText(projection(ras))
  output$rasRes <- renderText(res(ras))
  output$rasDim <- renderText(dim(ras))
  output$rasNlayers <- renderText(nlayers(ras))
  output$cellnumber <- renderText(round(Coords(), 4))
  output$rasvalue <- renderText(value())
  
  Coords <- reactive({
    req(input$rasPlot_click$x)
    c(input$rasPlot_click$x, input$rasPlot_click$y)
  })
  
  output$df <- renderTable({
    valdf <- data.frame("Layer" = names(ras), "Value" = unlist(value())[1,])
    colnames(valdf) <- c("Name", "Value")
    rownames(valdf) <- 1:nlayers(ras)
    valdf 
  })
  
  value  <- eventReactive(input$rasPlot_click$x,{
    extract(ras,cellFromXY(ras, Coords()))
  })
  
  output$TSplot <- renderPlot({
    req(input$rasPlot_click$x)
    plot(1:nlayers(ras),value(), type = "l", xlab = "Time", ylab = "Values")
    if(input$filterCheckSav) {
      lines(1:nlayers(ras),savgol(value(),5), col = "red")
    }
    if(input$filterCheckWhit) {
      lines(1:nlayers(ras),whit2(value(),5), col = "green")
    }
  })
  
  output$Map <- renderLeaflet({
    leaflet() %>% 
      setView(lng = sp@coords[1], lat = sp@coords[2], zoom = 6) %>% 
      addProviderTiles("Esri.WorldImagery") 
  })
  
  #output$Map <- renderLeaflet({
  #leaflet() %>%
  #  addProviderTiles(providers$Esri.WorldImagery) %>%
  #  setView(lng = 108.384, lat = 13.794, zoom = 6)
  #})
}