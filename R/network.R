library(networkD3)
library(stringr)
library(dplyr)

trade_net <- function(df, country, year=2017, var="quantity") { 
  
  honey <- df 
  
  country_ids_exp <- honey %>% filter(year== {{ year }}) %>%  filter(element == switch(var,Quantity="Export Quantity", Value="Export Value") ) %>% 
    filter(reporter_countries == {{ country }}) %>% filter(value > 0) %>% 
    select(partner_countries) %>% 
    distinct() %>% 
    mutate(country_id = group_indices(., partner_countries)) %>% 
    mutate(country_id = country_id - 1) %>% 
    rbind(c({{ country }}, nrow(.))) 
  
  exports <- honey %>% 
    filter(year == {{ year }}) %>% 
    filter(element == switch(var,Quantity="Export Quantity", Value="Export Value") ) %>% 
    filter(reporter_countries == {{ country }}) %>% filter(value > 0) %>% 
    select(reporter_countries, partner_countries, value) %>% 
    left_join(country_ids_exp) %>% 
    mutate(country_id = as.numeric(country_id)) %>% 
    rename(target = country_id) %>% 
    mutate(source = nrow(.))  %>% 
    select(source, target, value)
  
  country_ids_imp <- honey %>% filter(year== {{ year }}) %>%  filter(element == switch(var,Quantity="Import Quantity", Value="Import Value")) %>% 
    filter(reporter_countries == {{ country }}) %>% filter(value > 0) %>% 
    select(partner_countries) %>% 
    distinct() %>% 
    mutate(country_id = group_indices(., partner_countries) + nrow(country_ids_exp) ) %>% 
    mutate(country_id = country_id - 1)
  
  imports <- honey %>% 
    filter(year ==  {{ year }}) %>% 
    filter(element == switch(var,Quantity="Import Quantity", Value="Import Value")) %>% 
    filter(reporter_countries == {{ country }}) %>% filter(value > 0) %>% 
    select(reporter_countries, partner_countries, value) %>% 
    left_join(country_ids_imp) %>% 
    mutate(country_id = as.numeric(country_id) ) %>% 
    rename(source = country_id) %>% 
    mutate(target = nrow(country_ids_exp) - 1)  %>% 
    select(source, target, value)
  
  country_ids <- rbind(country_ids_exp, country_ids_imp)
  trade <- rbind(exports, imports) 
  
  return(list(ids=country_ids, trade=trade))
  
}

plot_sankey <- function(network) { 
  sankeyNetwork(Links = network$trade, 
                Nodes = network$ids , 
                Source = 'source', 
                Target = 'target', 
                Value = 'value', 
                NodeID = 'partner_countries',
                fontSize=18, 
                fontFamily="sans-serif")
}