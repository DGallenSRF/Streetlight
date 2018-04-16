
library(shiny)
library(data.table)
library(leaflet)
library(maptools)
library(DT)
library(tidyverse)


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
           fluidRow(
             column(4,
                    selectInput('Day_Typeper',"Day_Type",'')),
             column(4,
                    selectInput('Day_Partper','Day_Part','')),
             column(4,
                    selectInput('Middle_filterper','Middle_filter',''))
           ),
           hr(),
           fluidRow(
             column(12,
                    tags$div(
                      HTML("<h3 align='center'>Avg OD Trip Duration (seconds)</h3>")
                    ),
                    tableOutput('per_table'))
           )
  ),
  tabPanel('Commercial',
           fluidRow(
             column(4,
                    selectInput('Day_Typecom',"Day_Type",'')),
             column(4,
                    selectInput('Day_Partcom','Day_Part','')),
             column(4,
                    selectInput('Middle_filtercom','Middle_filter',''))
           ),
           hr(),
           fluidRow(
             column(12,
                    tags$div(
                      HTML("<h3 align='center'>Avg OD Trip Duration (seconds)</h3>")
                    ),
                    tableOutput('com_table'))
           )
  ),
  tabPanel('Details',
           tableOutput('pro_detail')
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
  
  #PERSONAL
  
  mf_per_table <- eventReactive(input$csvs,{
    
    mf_per_names <- input$csvs$name[grep("*_mf_personal.csv",input$csvs$name)]
    
    mf_per_dat <- mf_per_names[!grepl('zone',mf_per_names)]
    input$csvs$datapath[input$csvs$name==mf_per_dat]
  })
  
  mf_per_dat_OD <- reactive({
    var <- read.csv(mf_per_table(),stringsAsFactors = FALSE)
    
    var$Avg.Trip.Duration..sec. <-  as.numeric(var$Avg.Trip.Duration..sec.)
    
    mf_per_dat_OD <- select(var,c("Origin.Zone.ID","Origin.Zone.Name","Middle.Filter.Zone.ID","Middle.Filter.Zone.Name","Destination.Zone.ID","Destination.Zone.Name","Device.Type","Day.Type","Day.Part","O.M.D.Traffic..StL.Index.","Origin.Zone.Traffic..StL.Index.","Middle.Filter.Zone.Traffic..StL.Index.","Destination.Zone.Traffic..StL.Index.","Avg.Trip.Duration..sec."))
    return(mf_per_dat_OD)
  })
  
  DayTypeper <- reactive({
    dat <- mf_per_dat_OD()
    return(levels(as.factor(dat$Day.Type)))
  })
  
  observe({
    updateSelectInput(session, "Day_Typeper",
                      choices = DayTypeper())
  })
  
  DayPartper <- reactive({
    dat <- mf_per_dat_OD()
    return(levels(as.factor(dat$Day.Part)))
  })
  
  observe({
    updateSelectInput(session, "Day_Partper",
                      choices = DayPartper())
  })
  
  
  MiddleFilterper <- reactive({
    dat <- mf_per_dat_OD()
    return(levels(as.factor(dat$Middle.Filter.Zone.Name)))
  })
  
  observe({
    updateSelectInput(session, "Middle_filterper",
                      choices = MiddleFilterper())
  })
  
  
  output$per_table <- renderDataTable({
    x <-  mf_per_dat_OD()%>%
      filter(Day.Type==input$Day_Typeper)%>%
      filter(Day.Part==input$Day_Partper)%>%
      filter(Middle.Filter.Zone.Name==input$Middle_filterper)%>%
      select(Origin.Zone.Name,Destination.Zone.Name,Avg.Trip.Duration..sec.)%>%
      dcast(formula = Origin.Zone.Name ~ Destination.Zone.Name)
    data.table(x)
    
  })
  
  
  #COMMERCIAL

  mf_com_table <- eventReactive(input$csvs,{
    
    mf_com_names <- input$csvs$name[grep("*_mf_commercial.csv",input$csvs$name)]
    
    mf_com_dat <- mf_com_names[!grepl('zone',mf_com_names)]
    input$csvs$datapath[input$csvs$name==mf_com_dat]
  })
  
  mf_com_dat_OD <- reactive({
    var <- read.csv(mf_com_table(),stringsAsFactors = FALSE)
    
    var$Avg.Trip.Duration..sec. <-  as.numeric(var$Avg.Trip.Duration..sec.)
    
    mf_com_dat_OD <- select(var,c("Origin.Zone.ID","Origin.Zone.Name","Middle.Filter.Zone.ID","Middle.Filter.Zone.Name","Destination.Zone.ID","Destination.Zone.Name","Device.Type","Day.Type","Day.Part","O.M.D.Traffic..StL.Index.","Origin.Zone.Traffic..StL.Index.","Middle.Filter.Zone.Traffic..StL.Index.","Destination.Zone.Traffic..StL.Index.","Avg.Trip.Duration..sec."))
    return(mf_com_dat_OD)
  })
  
  DayTypecom <- reactive({
    dat <- mf_com_dat_OD()
    return(levels(as.factor(dat$Day.Type)))
  })
  
  observe({
    updateSelectInput(session, "Day_Typecom",
                      choices = DayTypecom())
    })
  
  DayPartcom <- reactive({
    dat <- mf_com_dat_OD()
    return(levels(as.factor(dat$Day.Part)))
  })
  
  observe({
    updateSelectInput(session, "Day_Partcom",
                      choices = DayPartcom())
  })
  
  
  MiddleFiltercom <- reactive({
    dat <- mf_com_dat_OD()
    return(levels(as.factor(dat$Middle.Filter.Zone.Name)))
  })
  
  observe({
    updateSelectInput(session, "Middle_filtercom",
                      choices = MiddleFiltercom())
  })
  
  
  output$com_table <- renderDataTable({
    x <-  mf_com_dat_OD()%>%
      filter(Day.Type==input$Day_Typecom)%>%
      filter(Day.Part==input$Day_Partcom)%>%
      filter(Middle.Filter.Zone.Name==input$Middle_filtercom)%>%
      select(Origin.Zone.Name,Destination.Zone.Name,Avg.Trip.Duration..sec.)%>%
      dcast(formula = Origin.Zone.Name ~ Destination.Zone.Name)
    data.table(x)
    
  })
  
  
  #DETAILS
  details <- eventReactive(input$csvs,{
    
    det_name <-  input$csvs$name[grep("Project_OD_MF.txt",input$csvs$name)]
    
    input$csvs$datapath[input$csvs$name==det_name]
  })
  
  project_detail <- reactive({
    project <- read.table(details(),sep='\n',stringsAsFactors = FALSE)%>%
      separate(V1,c('variable','value'),':')
    
    project$Info <- ifelse(unlist(lapply(project$variable,function(x) any(x==c(0:10))))==TRUE,NA,project$variable)%>%
      na.locf()
    
    project_details <- select(project,Info,value)%>%
      filter(value!=' ')
  })
  output$pro_detail <- renderTable({
    project_detail()
    
  })
  
  
}

shinyApp(ui = ui, server = server)
