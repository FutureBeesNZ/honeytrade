# library(networkD3)
library(sankeyD3)
library(stringr)
library(dplyr)


## Heper function to subset just the data we need for a particular:
# Country
# Commodity
# Measure
# Year and 
# Filter by values. 
subset_trade <- function(df, country, item ="Honey, natural", year = 2017, value_filter = 0) {

  out <- df %>% 
    filter(reporter_countries == {{ country }} ) %>% 
    filter(item == {{ item }}  ) %>% 
    filter(year ==  {{ year }} ) %>% 
    filter(value > {{ value_filter }} ) %>% 
    collect()
  if (nrow(out) > 0) { 
  return(out) 
  }
  else{ 
    return(FALSE) 
  }
}

trade_net <- function(df, element="Quantity") { 

  el_import <- switch( element , Quantity="Import Quantity", Value="Import Value")
  el_export <- switch( element , Quantity="Export Quantity", Value="Export Value")
  
  country <- df %>% select(reporter_countries) %>% distinct() %>% pull(reporter_countries)
  
  # Compute 0-based country ids for the Sankey Network Diagram
  country_ids_exp <- df %>% 
    filter(element == {{ el_export }}) %>% 
    select(partner_countries) %>% 
    distinct() %>% 
    mutate(country_id = group_indices(., partner_countries)) %>% 
    mutate(country_id = country_id - 1) %>% 
    rbind(c( country, nrow(.))) 
  
  # Start numbering export countries from last row of export countries 
  country_ids_imp <- df %>% 
    filter(element == {{ el_import }}) %>% 
    select(partner_countries) %>% 
    distinct() %>% 
    mutate(country_id = group_indices(., partner_countries) + nrow(country_ids_exp) ) %>% 
    mutate(country_id = country_id - 1)
  
  exports <- df %>% 
    filter(element == {{ el_export }}) %>% 
    select(reporter_countries, partner_countries, value) %>% 
    left_join(country_ids_exp) %>% 
    mutate(country_id = as.numeric(country_id)) %>% 
    rename(target = country_id) %>% 
    mutate(source = nrow(.))  %>% 
    select(source, target, value) %>% 
    arrange(value)
  
  imports <- df %>% 
    filter(element == {{ el_import }}) %>% 
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
                fontSize=18, 
                fontFamily="sans-serif", 
                height = 1000, 
                width=1000,
                curvature=0.2,
                zoom=TRUE,
                nodeCornerRadius = 5,
                numberFormat = ".2s",
                nodeStrokeWidth = 2
                )
}

