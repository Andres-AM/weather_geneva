

source("libraries.R")

## Data Import 
dr <- read.table("data/climate-reports-tables-homogenized_GVE.txt",skip = 26,header = T) %>% 
  as_tibble()


df <- dr %>% 
  mutate( date_val = paste0(Year,Month,1), Month = month(Month));df

dr
ymd(paste0(1901,01,01))


df %>% 
  ggplot() +
  geom_jitter(aes(x = Month, y = Temperature,color= Year))


df %>% 
  ggplot() +
  geom_line(aes(x = Month, y = Temperature,color= as_factor(Year)))

