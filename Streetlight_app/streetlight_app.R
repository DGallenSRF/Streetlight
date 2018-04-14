
library(shiny)
library(data.table)
library(leaflet)
library(rgdal)


ui <- fluidPage(
  titlePanel("Multiple file uploads"),
  sidebarLayout(
    sidebarPanel(
      fileInput("csvs",
                label="Upload CSVs here",
                multiple = TRUE),
      actionButton('plotButton','Plot!'),
    textInput("path","Path","Path to File"),
    actionButton('plotButton1','Plot!')
    ),
    mainPanel(
      plotOutput('hist1'),
      plotOutput('hist2'),
      textOutput('path'),
      leafletOutput('shapefile')
    )
  )
)


server <- function(input, output) {
 
  
   mycsvs<-eventReactive(input$csvs,{
    lapply(input$csvs$datapath, fread)
  })
     
  output$hist1 <- renderPlot({
    
    input$plotButton
    mf_com <- isolate(as.data.frame(mycsvs()[[1]]))
    mf_com$`Avg Trip Duration (sec)` <-  as.numeric(mf_com$`Avg Trip Duration (sec)`)
    
    hist(mf_com$`Avg Trip Duration (sec)`,breaks = 200)
  }) 

  output$hist2 <- renderPlot({
    input$plotButton
    mf_com <- isolate(as.data.frame(mycsvs()[[2]]))
    mf_com$`Avg Trip Duration (sec)` <-  as.numeric(mf_com$`Avg Trip Duration (sec)`)
    
    hist(mf_com$`Avg Trip Duration (sec)`,breaks = 200)
  }) 
  
  pathtoshape <-  reactive({as.character(gsub("\\\\", "/", input$path))})

  output$path <- renderText({pathtoshape()})
 
  output$shapefile <- renderLeaflet({
    
    input$plotButton1

    shape <- isolate(readOGR(dsn=pathtoshape(),
                         layer = 'TH_36_Manning_Expanded_destination_zone_set'))
    
    leaflet(shape) %>%
      addTiles(group = "OSM (default)") %>%
      addPolygons(color = "red", weight = 1, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0.5,
                  highlightOptions = highlightOptions(color = "white", weight = 5,
                                                      bringToFront = TRUE))
    
    
    })
}

shinyApp(ui = ui, server = server)
