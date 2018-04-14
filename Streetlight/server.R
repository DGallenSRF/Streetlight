library(shiny)
library(shinyFiles)
library(rgdal)
library(stringr)
library(data.table)

function(input, output) {
  
  mycsvs<-reactive({
    rbindlist(lapply(input$file1$datapath, fread),
              use.names = TRUE, fill = TRUE)
  })
  
  output$count <- renderText(nrow(mycsvs()))
}


