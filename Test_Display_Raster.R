library(shiny)
library(raster)

server <- shinyServer(function(input, output) {
  # stk_ras = stack()
  output$files <- renderTable(input$files)
  output$rasPlot <- renderPlot({
    plot(input$files)
  }, height = 400)
  
  files <- reactive({
    files <- input$files
    files$datapath <- gsub("\\\\", "/", files$datapath)
    # stk_ras = stack(files, stk_ras)
    files
  })
})

ui <- shinyUI(fluidPage(
  titlePanel("Uploading Files"),
  sidebarLayout(
    sidebarPanel(
      fileInput(inputId = 'files', 
                label = 'Select an Image',
                multiple = TRUE)
    ),
    mainPanel(
      tableOutput('files'),
      uiOutput('images')
    )
  )
))

shinyApp(ui=ui,server=server)