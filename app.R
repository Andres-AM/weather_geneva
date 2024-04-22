
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
                        label = 'Select the month to display:',
                        choices =  unique(month(df$Date,label = T)),
                        selected = "Jan",
                        multiple = F),
                      
                      sliderInput(inputId = "val",label = "Grouped by (in years):",min = 1,max = 10,value = 1,step = 1), 
                      hr(),
                      checkboxInput('smooth', 'Add best regression fit to see trend over the years')

                    ),
                    dashboardBody(
                      # Boxes need to be put in a row (or column)
                      fluidRow(
                        box(
                          width = 12,
                          plotlyOutput(outputId = "plot1")
                          
                        ),
                      ),
                      
                      fluidRow(
                        
                        box(
                          h2("Weather in Geneva"),
                          "Analyzing weather patterns in Geneva from 1864 to 2024 for a particular month reveals significant fluctuations. By aggregating data into yearly averages, we can discern trends more clearly. This approach allows us to observe the evolution of weather conditions over time with greater precision. Furthermore, fitting the data points with a best-fit line provides a comprehensive representation of the overall trajectory of weather changes throughout the specified month."
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
  
  output$plot1 <- renderPlotly({
    
    p <- dataset() %>%
      ggplot(aes(x = DatePeriod, y = Temperature )) +
      geom_line() +
      scale_x_date(date_labels = "%Y", date_breaks = "10 years") +
      labs(title  = paste0("Average temperature for the month of ",input$month_val)) 
    
    if (input$smooth)
      p <- p + geom_smooth(se = F,method = "loess",formula = 'y ~ x')
    
    p <- ggplotly(p)%>%
      layout(xaxis = list(autorange = TRUE),
             yaxis = list(autorange = TRUE))
    
    p
    
  })
  
  
}

shinyApp(ui, server)

