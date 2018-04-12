
library(shiny)
library(data.table)

pathx <-"C:/Users/dgallen/Desktop/Streetlight/TH_36_Manning_Expanded_Updated_8041_Travel"

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
      plotOutput('shapefile')
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
  
  pathtoshape <-  reactive({as.character(input$path)})

  output$path <- renderText({pathtoshape()})
 
  output$shapefile <- renderPlot({
    
    input$plotButton1

    isolate(plot(readOGR(dsn=pathtoshape(),
                         layer = 'TH_36_Manning_Expanded_destination_zone_set')))
    })
}

shinyApp(ui = ui, server = server)
