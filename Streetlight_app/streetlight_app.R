
library(shiny)
library(data.table)
library(leaflet)
library(rgdal)


ui <- navbarPage(
  title = 'Streetlight!',
  tabPanel('Load Data',
           fluidRow(
             column(12,
                    column(6,
                           fileInput("csvs",
                                     label="Upload CSVs here",
                                     multiple = TRUE),
                           hr(),
                           tableOutput('csvs')
                    ),
                    column(6,
                           textInput("path","Path to Shapefile"),
                           hr(),
                           tableOutput('Shapefile_names')
                    )
             )
           )
  ),
  tabPanel("Shapefiles",
           fluidRow(
             column(12,
                    selectInput('Shapefile_dropdown', 'Select Shapefile', '',width = 1000),
                    # allows for long texts to not be wrapped, and sets width of drop-down
                    hr(),
                    leafletOutput('shapefile'),
                    hr(),
                    tableOutput('shape_table')
             )
           )
  )
)



server <- function(input, output,session) {
  
  
  mycsvs<-eventReactive(input$csvs,{
    lapply(input$csvs$datapath, fread)
  })
  
  output$csvs <- renderTable({
    data.frame(CSVs = input$csvs$name)
    }) 
  
  output$Shapefile_names <- renderTable({
    data.frame(Shapefiles=dir(pathtoshape())[grepl('.shp',dir(pathtoshape()))])
  })
  
  pathtoshape <-  reactive({as.character(gsub("\\\\", "/", input$path))})
  
  Shapefile_IDs <- reactive({
    vars <- dir(pathtoshape())[grepl('.shp',dir(pathtoshape()))]
    return(vars)
  })
  
  observe({
    updateSelectInput(session,'Shapefile_dropdown',
                      choices = Shapefile_IDs()
    )
  })
  
  layers <- reactive({
    name <- input$Shapefile_dropdown
    fixed_name <- gsub('.shp','',name)
    return(fixed_name)
  })
  
  #Leaflet
  output$shapefile <- renderLeaflet({
    
    shape <- readOGR(dsn=pathtoshape(),
                     layer = layers())
    
    leaflet(shape) %>%
      addTiles(group = "OSM (default)") %>%
      addPolygons(color = "red", weight = 1, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0.5,
                  highlightOptions = highlightOptions(color = "white", weight = 5,
                                                      bringToFront = TRUE))
    
    
  })
  
  output$shape_table <- renderTable({
    
    shape <- readOGR(dsn=pathtoshape(),
                     layer = layers())
    data.frame(shape)
  })
}

shinyApp(ui = ui, server = server)
