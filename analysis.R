library(ggplot2) 
library(readr)

honey <- read_csv('FAOSTAT_data_6-5-2020.csv') 

volume <- honey %>% 
  dplyr::filter(`Partner Countries` == "New Zealand") %>% dplyr::filter(`Element` == "Import Quantity") %>% 
  dplyr::select(Year, Value, `Reporter Countries`)

value <- honey %>% 
  dplyr::filter(`Partner Countries` == "New Zealand") %>% dplyr::filter(`Element` == "Import Value") %>% 
  dplyr::select(Year, Value, `Reporter Countries`)

ggplot(value, aes(x = Year, y= Value)) + geom_line() + facet_wrap(~ `Reporter Countries`)
ggplot(volume, aes(x = Year, y= Value)) + geom_line() + facet_wrap(~ `Reporter Countries`)
