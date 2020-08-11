
top_commodities <- function(country, element="expq", year=2017, n=20)  {

  element <- switch( element, 
          expv="Export Value",
          expq="Export Quantity",
          impv="Import Value",
          impq="Import Quantity"
          )
          
  trade_matrix %>% 
    filter(country == {{ country }}) %>% 
    filter(year == {{ year }}) %>% 
    filter(element == {{ element }}) %>% 
    group_by(item) %>% 
    summarise(total = sum(value)) %>% 
    arrange(desc(total)) %>% 
    head(n) 
}

