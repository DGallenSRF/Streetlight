
library(shiny)
library(data.table)
library(leaflet)
library(rgdal)


ui <- fluidPage(
  
  fluidRow(
    column(12,
           titlePanel("Multiple file uploads"),
           column(6,
                  fileInput("csvs",
                                label="Upload CSVs here",
                                multiple = TRUE),
                  hr(),
                  textOutput('csvs')
                  ),
           column(6,
                  textInput("path","Path to Shapefile"),
                  hr(),
                  textOutput('path')
                  )
    )
  )
  # fluidRow(
  #   column(12,
  # 
  #     textOutput('path'),
  #     leafletOutput('shapefile')
  #   )
  # )
)


server <- function(input, output) {
 
  
   mycsvs<-eventReactive(input$csvs,{
    lapply(input$csvs$datapath, fread)
  })
     
  output$csvs <- renderText({input$csvs$name}) 
  
  pathtoshape <-  reactive({as.character(gsub("\\\\", "/", input$path))})

  output$path <- renderText({dir(pathtoshape())[grepl('.shp',dir(pathtoshape()))]})
 
  output$shapefile <- renderLeaflet({
    
    input$plotButton2

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
