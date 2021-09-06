library(dplyr)
library(stringr)
library(ggplot2) 

fancy_scientific <- function(l) {
  # turn in to character string in scientific notation
  l <- format(l, scientific = TRUE)
  # quote the part before the exponent to keep all the digits
  l <- gsub("^(.*)e", "'\\1'e", l)
  # turn the 'e+' into plotmath format
  l <- gsub("e", "%*%10^", l)
  # return this as an expression
  parse(text=l)
}

plot_theme <- function() { 
  ggplot2::theme_set(ggplot2::theme_bw(base_size=16))# , base_family="Barlow")) 
  ggplot2::theme_update(
    panel.background  = ggplot2::element_blank(),
    plot.background = ggplot2::element_rect(fill="gray96", colour=NA), 
    legend.background = ggplot2::element_rect(fill="transparent", colour=NA),
    legend.key = ggplot2::element_rect(fill="transparent", colour=NA),
    text= ggplot2::element_text(size=20)
  )
  
}

top_commodities <- function(country, element="expq", year=2017, n=20)  {

  element <- switch( element, 
          expv="Export Value",
          expq="Export Quantity",
          impv="Import Value",
          impq="Import Quantity"
          )
          
  trade_matrix %>% 
    filter(reporter_countries == {{ country }}) %>% 
    filter(year == {{ year }}) %>% 
    filter(element == {{ element }}) %>% 
    group_by(item) %>% 
    summarise(total = sum(value)) %>% 
    arrange(desc(total)) %>% 
    head(n) 
}

plot_top_commodities <- function(country = "New Zealand", element = "impq", year=2017, n=20) { 
  

      element_text <- switch(element, impq = "Import Quantities (tons)",
                       impv = "Import Values ($1000)",
                       expq = "Export Quantities (tons)", 
                       expv =  "Export Values ($1000)")
  
      title_text <- str_interp("${country} ${element_text}")
      subtitle_text <- str_interp("for top ${n} commodities in ${year}")

                       
  ggplot(top_commodities(country, element, year, n), 
    aes(y=total, x=reorder(item, total))) +  
    geom_col() + 
    coord_flip() + 
    xlab("Commodity") + 
    ylab(element_text) +
    labs(title=title_text, subtitle=subtitle_text) + 
    scale_y_continuous(labels=fancy_scientific) +
    plot_theme()
   

}

plot_all_elements <- function(country = "New Zealand", year=2017, n=10) { 
  elements <- c('impq','impv','expq','expv')
  plots <- furrr::future_map(elements, ~ plot_top_commodities(country, element =.x, year = year, n=n), .progress=TRUE )
  ggpubr::ggarrange(plots[[1]],plots[[2]],plots[[3]],plots[[4]], ncol=2, nrow=2) 
  
}
