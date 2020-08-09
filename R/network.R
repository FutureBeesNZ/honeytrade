library(networkD3)
library(stringr)
library(dplyr)

trade_net <- function(df, country="New Zealand", year=2017, var="Quantity", min_val=0) { 
  
  # Prepare data for visualizing as a Sankey Diagram of import/export flow.
  
  # Compute 0-based country ids for the Sankey Network Diagram
  country_ids_exp <- df %>% 
    filter(year== {{ year }}) %>%  
    filter(element == switch(var,Quantity="Export Quantity", Value="Export Value") ) %>% 
    filter(reporter_countries == {{ country }}) %>% 
    filter(value > 0) %>% 
    filter(value > min_val) %>% 
    select(partner_countries) %>% 
    distinct() %>% 
    mutate(country_id = group_indices(., partner_countries)) %>% 
    mutate(country_id = country_id - 1) %>% 
    rbind(c({{ country }}, nrow(.))) 
  
  # Start numbering export countries from last row of export countries 
  country_ids_imp <- df %>% 
    filter(year == {{ year }}) %>%  
    filter(element == switch(var,Quantity="Import Quantity", Value="Import Value")) %>% 
    filter(reporter_countries == {{ country }}) %>% 
    filter(value > 0) %>% 
    filter(value > min_val) %>% 
    select(partner_countries) %>% 
    distinct() %>% 
    mutate(country_id = group_indices(., partner_countries) + nrow(country_ids_exp) ) %>% 
    mutate(country_id = country_id - 1)
  
  exports <- df %>% 
    filter(year == {{ year }}) %>% 
    filter(element == switch(var,Quantity="Export Quantity", Value="Export Value") ) %>% 
    filter(reporter_countries == {{ country }}) %>% 
    filter(value > 0) %>% 
    filter(value > min_val) %>% 
    select(reporter_countries, partner_countries, value) %>% 
    left_join(country_ids_exp) %>% 
    mutate(country_id = as.numeric(country_id)) %>% 
    rename(target = country_id) %>% 
    mutate(source = nrow(.))  %>% 
    select(source, target, value) %>% 
    arrange(value)
  
  imports <- df %>% 
    filter(year ==  {{ year }}) %>% 
    filter(element == switch(var,Quantity="Import Quantity", Value="Import Value")) %>% 
    filter(reporter_countries == {{ country }}) %>% 
    filter(value > 0) %>% 
    filter(value > min_val) %>% 
    select(reporter_countries, partner_countries, value) %>% 
    left_join(country_ids_imp) %>% 
    mutate(country_id = as.numeric(country_id) ) %>% 
    rename(source = country_id) %>% 
    mutate(target = nrow(country_ids_exp) - 1)  %>% 
    select(source, target, value) %>% 
    arrange(value)
  
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
                fontSize=20, 
                fontFamily="sans-serif")
}

