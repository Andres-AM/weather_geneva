

source("libraries.R")

## Data Import 
dr <- read.table("data/climate-reports-tables-homogenized_GVE.txt",skip = 26,header = T) %>% 
  as_tibble()


df <- dr %>% 
  mutate( date_val = paste0(Year,Month,1), Month = month(Month));df
 

df %>% 
  ggplot() +
  geom_jitter(aes(x = Month, y = Temperature,color= Year))


df %>% 
  ggplot() +
  geom_line(aes(x = Month, y = Temperature,color= as_factor(Year)))



df %>% 
  filter( Month == 7) %>% 
  ggplot(aes(x = Year, y = Temperature ,color= as_factor(Month))) +
  # scale_y_continuous(n.breaks = 10,limits = c(-10,10)) +
  geom_point() +
  geom_line()
  



