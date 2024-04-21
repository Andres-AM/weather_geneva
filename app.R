
## app.R ##
source("libraries.R")
df <- read.table("data/climate-reports-tables-homogenized_GVE.txt",skip = 26,header = T) %>%   
  mutate( Date = as.Date(paste(Year, Month,"01",sep = "-"))) %>%
  as_tibble


ui <- dashboardPage(skin = "blue",
                    dashboardHeader(title = "Weather"),
                    dashboardSidebar(
                      
                      selectInput(
                        inputId = 'month_val', 
                        label = 'Select the month',
                        choices =  unique(month(df$Date,label = T)),
                        selected = "Jan",
                        multiple = F),
                      
                      sliderInput(inputId = "val",label = "Grouped by :",min = 1,max = 100,value = 1,step = 1), 
                      hr(),
                      checkboxInput('smooth', 'Smooth (see trend over the years)')
                      
                      
                      
                    ),
                    dashboardBody(
                      # Boxes need to be put in a row (or column)
                      fluidRow(
                        

                        box(
                          
                          plotOutput('plot1')
                          
                        ),
                        
                        box(
                          h2("Weather in Geneva"),
                          "Weather"
                        ),
                        
                        box(
                          h2("Output table"),
                          DT::dataTableOutput(outputId = "table1", width = "100%", height = "auto", fill = TRUE)
                        ),
                      )
                    )
)

server <- function(input, output,session) {
  
  dataset <- reactive({
    
    df %>%
      mutate(DatePeriod = as.Date(paste(input$val * floor(year(Date)/input$val), Month,"01",sep = "-"))) %>%
      filter( month(Date,label = T) == input$month_val) %>%
      group_by(DatePeriod) %>%
      summarise(Temperature  = mean(Temperature)) %>%
      ungroup()
    
  })
  
  output$table1 <- DT::renderDataTable(
    
    dataset() %>%
      arrange(desc(DatePeriod)) %>%
      mutate(Temperature= round(Temperature,2)) %>%
      select(DatePeriod,Temperature)
  )
  
  output$plot1 <- renderPlot({
    
    p <- dataset() %>%
      ggplot(aes(x = DatePeriod, y = Temperature )) +
      geom_line() +
      scale_x_date(date_labels = "%Y", date_breaks = "10 years") +
      labs(title  = paste0("Temperature for the month : ",input$month_val)) +
      theme(legend.position = "None")
    
    if (input$smooth)
      p <- p + geom_smooth(se = F,method = "loess",formula = 'y ~ x')
    
    print(p)
    
  })
  
  
}

shinyApp(ui, server)

