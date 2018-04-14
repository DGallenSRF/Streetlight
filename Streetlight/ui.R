library(shiny)
library(shinyFiles)
library(rgdal)
library(stringr)

navbarPage("Streetlight",
  tabPanel("Load Directory",
    sidebarLayout(
      sidebarPanel(
        fileInput("file1",label =  "Choose CSV File",multiple = TRUE,
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")
        )
      ),
      mainPanel(
        textOutput("count")
      )
    )
  )
)

