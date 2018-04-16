
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
  tabPanel('Personnal',
           tableOutput('table')

           ),
  tabPanel('Commercial'
           ),
  tabPanel('Details'
           )
)



server <- function(input, output,session) {
  
  #LOAD
  #read the selected files
  mycsvs<-eventReactive(input$csvs,{
    lapply(input$csvs$datapath, fread)
  })
  
  #LOAD
  #show list of csv + txt files
  output$csvs <- renderTable({
    
    toMatch <- c(".txt",'.csv')
    
    data.frame(Files =
                 unique(grep(paste(toMatch,collapse = '|'),
                             input$csvs$name,value = TRUE)))
  }) 
  
  #LOAD
  #return a list of the shapefiles in the path in table format
  output$Shapefile_names <- renderTable({
    data.frame(Shapefiles=input$csvs$name[grepl('.shp',input$csvs$name)])
  })
  
  #LOAD
  #return list of shapefiles in the folder
  Shapefile_IDs <- reactive({
    vars <- input$csvs$name[grepl('.shp',input$csvs$name)]
    return(vars)
  })
  
  #LOAD
  ##update drop down menu for shapefiles in folder path
  observe({
    updateSelectInput(session,'Shapefile_dropdown',
                      choices = Shapefile_IDs()
    )
  })
  
  ##SHAPEFILES
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
  
  ##SHAPEFILES
  #Leaflet
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
  
  ##SHAPEFILES
  #show attributes for the shapefile
  output$shape_table <- renderTable({
    
    shape <- uploadShpfile()
    data.frame(shape)
  })
  
  #COMMERCIAL

  mf_com_table <- reactive({
    
    mf_com_names <- input$csvs$name[grep("*_mf_commercial.csv",input$csvs$name)]
    
    mf_com_dat <- mf_com_names[!grepl('zone',mf_com_names)]
    input$csvs$datapath[input$csvs$name==mf_com_dat]
  })

  output$table <- renderTable({
    var <- read.csv(mf_com_table(),stringsAsFactors = FALSE)

    
    mf_com_dat_melt <- melt(mf_com_dat,
                            measure.vars = c("Origin.Zone.ID","Origin.Zone.Name",
                                             "Middle.Filter.Zone.ID","Middle.Filter.Zone.Name",
                                             "Destination.Zone.ID","Destination.Zone.Name"),
                            id.vars = c("Device.Type","Day.Type",
                                        "Day.Part","O.M.D.Traffic..StL.Index.",
                                        "Origin.Zone.Traffic..StL.Index.","Middle.Filter.Zone.Traffic..StL.Index.",
                                        "Destination.Zone.Traffic..StL.Index.","Avg.Trip.Duration..sec."))
    
    mf_com_dat_melt$group <- ifelse(grepl("Origin",mf_com_dat_melt$variable),"From",
                                    ifelse(grepl("Middle",mf_com_dat_melt$variable),"Through",
                                           ifelse(grepl("Destination",mf_com_dat_melt$variable),"To",NA)))
    
    return(data.table(select(mf_com_dat_melt,Day.Type,Day.Part,Avg.Trip.Duration..sec.)))
  })
  
  
  # output$table <- renderTable({
  #   read.csv(mf_com_table(),stringsAsFactors = FALSE)
  # })

  
}

shinyApp(ui = ui, server = server)
