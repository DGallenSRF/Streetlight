library(shiny)
library(shinyFiles)
library(rgdal)
library(stringr)

shinyServer(function(input, output, session) {
  
  # dir
  shinyDirChoose(input, 'dir', roots = c(roots="~"), filetypes = c('', 'txt'))
  dir <- reactive(input$dir)
  output$dir <- renderPrint(dir())
  
  # path
  path <- reactive({
    home <- normalizePath("~")
    file.path(home, paste(unlist(dir()$path[-1]), collapse = .Platform$file.sep))
  })
  
  # files
  output$files <- renderPrint(list.files(path()))
  output$dropdown <- list.files(path())
  
  shape_org_name <- grepl("*_origin_zone_set.cpg*",dir)
  shape_org_name <- substr(shape_org_name,1,nchar(shape_org_name)-4)
  
  output$plot1 <- renderPlot{(rgdal::readOGR(dsn='.',layer = shape_org_name))}

}) 

