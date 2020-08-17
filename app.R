library(pool) 
library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(ggplot2) 
library(plotly)
library(dplyr)
library(readr)
library(janitor)

# Setup a .pgpass file in the home directory of the shiny server to save the password for the DB connection
pool <- pool::dbPool(drv = RPostgres::Postgres(),
               dbname="geodata", 
               host="40.115.76.146") 

onStop(function() {
  poolClose(pool)
}) 

trade_matrix <- pool %>% tbl("fao_trade_detailedtradematrix")

reporting_countries <- pool %>% tbl("fao_countries") %>% select(reporter_countries) %>%  collect() 
commodities <- pool %>% tbl("fao_items") %>% collect() 

variables <- c("Quantity", "Value") 

years <- tbl(pool, "fao_years") %>% collect() 
min_year <- min(years)
max_year <- max(years)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title

    titlePanel("FAO Agricultural Commodity Import/Export Data"),

    # Sidebar with a slider input for number of bins 
    tabsetPanel(
     
    sankeyPanelUI("sankey_panel"),
    countryPlotsUI("country_plots"),
    
    tabPanel("Table", {
        dataTableOutput("tabledata")
    })
    
    )
)

server <- function(input, output) {

 
  
  callModule(sankeyPanel, "sankey_panel")
  callModule(countryPlots, "country_plots")
    
}

# Run the application 
shinyApp(ui = ui, server = server)
