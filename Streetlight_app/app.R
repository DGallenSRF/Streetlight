
library(shiny)
library(data.table)


ui <- fluidPage(
  titlePanel("Multiple file uploads"),
  sidebarLayout(
    sidebarPanel(
      fileInput("csvs",
                label="Upload CSVs here",
                multiple = TRUE),
      actionButton('plotButton','Plot!')
    ),
    mainPanel(
      plotOutput('hist1'),
      plotOutput('hist2')
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
  
}

shinyApp(ui = ui, server = server)
