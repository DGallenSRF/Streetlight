library(shiny)
library(shinyFiles)
library(rgdal)
library(stringr)

navbarPage("Streetlight",
  tabPanel("Load Directory",
    sidebarLayout(
      sidebarPanel(
        shinyDirButton("dir", "Chose directory", "Upload")
  ),
  mainPanel(
    h4("output$dir"),
    verbatimTextOutput("dir"), br(),
    h4("Files in that dir"),
    verbatimTextOutput("files")
    )
  )
  ),
  tabPanel("Shapefiles",
             mainPanel(
               plotOutput("plot1")
  )
)

