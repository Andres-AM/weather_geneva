
source("libraries.R")

## Data Import 
dr <- read.table("data/climate-reports-tables-homogenized_GVE.txt",skip = 26,header = T) %>% 
  as_tibble()

val = 5

df <- dr %>% 
  mutate( Date = as.Date(paste(Year, Month,"01",sep = "-")), 
          DatePeriod = as.Date(paste(val * floor(year(Date)/val), Month,"01",sep = "-"))
  ) %>% 
  filter( month(DatePeriod,label = T) == "Feb") %>% 
  group_by(DatePeriod) %>% 
  summarise(Temperature  = mean(Temperature)) %>% ungroup()

p <- df %>%
  ggplot(aes(x = DatePeriod, y = Temperature , color= month(DatePeriod,label = T))) +
  # geom_point() +
  geom_line() +
  # scale_x_continuous(n.breaks = 15)+
  # labs(title  = paste0("Temperature for the month :",input$month_val)) +
  theme(legend.position = "None")  

# if (input$smooth)
  p <- p + geom_smooth(se = F,method = "loess",formula = 'y ~ x')

print(p)
  
t <- df %>% 
  arrange(desc(DatePeriod)) %>% 
  select(DatePeriod,Temperature)

print(t)
