
library(shiny)
library(data.table)
library(leaflet)
library(maptools)


ui <- navbarPage(
  title = 'Streetlight!',
  tabPanel('Load Data',
           fluidRow(
             column(12,
                    fileInput("csvs",
                              label="Upload all files in folder",
                              multiple = TRUE),
                    hr(),
                    column(6,
                           tableOutput('csvs')
                    ),
                    column(6,
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
  ),
  tabPanel('Personnal'
           ),
  tabPanel('Commercial'
           ),
  tabPanel('Details'
           )
)



server <- function(input, output,session) {
  
  #read the selected csvs
  mycsvs<-eventReactive(input$csvs,{
    lapply(input$csvs$datapath, fread)
  })
  
  #show list of csv files
  output$csvs <- renderTable({
    
    toMatch <- c(".txt",'.csv')
    
    data.frame(Files =
                 unique(grep(paste(toMatch,collapse = '|'),
                             input$csvs$name,value = TRUE)))
  }) 
  
  #return a list of the shapefiles in the path in table format
  output$Shapefile_names <- renderTable({
    data.frame(Shapefiles=input$csvs$name[grepl('.shp',input$csvs$name)])
  })
  
  #return list of shapefiles in the folder
  Shapefile_IDs <- reactive({
    vars <- input$csvs$name[grepl('.shp',input$csvs$name)]
    return(vars)
  })
  
  ##update drop down menu for shapefiles in folder path
  observe({
    updateSelectInput(session,'Shapefile_dropdown',
                      choices = Shapefile_IDs()
    )
  })
  
  
  uploadShpfile <- reactive({
    if (!is.null(input$csvs)){
      shpDF <- input$csvs
      prevWD <- getwd()
      uploadDirectory <- dirname(shpDF$datapath[1])
      setwd(uploadDirectory)
      for (i in 1:nrow(shpDF)){
        file.rename(shpDF$datapath[i], shpDF$name[i])
      }
      shpName <- shpDF$name[grep(x=shpDF$name, pattern="*.shp")]
      shpPath <- paste(uploadDirectory, input$Shapefile_dropdown, sep="/")
      setwd(prevWD)
      shpFile <- readShapePoly(shpPath)
      return(shpFile)
    } else {
      return()
    }
  })
  
  


  
  #  #Leaflet
  output$shapefile <- renderLeaflet({
    
    shape <- uploadShpfile()
    
    labels_org <- paste('ID:',shape$id,', ', shape$name,sep='')
    
    leaflet(shape) %>%
      addTiles(group = "OSM (default)") %>%
      addPolygons(color = "red", weight = 1, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0.5,
                  highlightOptions = highlightOptions(color = "white", weight = 5,
                                                      bringToFront = TRUE),label=labels_org)
    
    
  })
  
  #show attributes for the shapefile
  output$shape_table <- renderTable({
    
    shape <- uploadShpfile()
    data.frame(shape)
  })
  
  #personnal
  
}

shinyApp(ui = ui, server = server)
