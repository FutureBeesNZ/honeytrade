library(pool) 
library(shiny)
library(shinyWidgets)
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


trade_matrix <- tbl(pool, "fao_trade_detailedtradematrix")

reporting_countries <- tbl(pool, "fao_countries") %>% select(reporter_countries) %>%  collect() 
commodities <- tbl(pool, "fao_items") %>% collect() 

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
    tabPanel("Table", {
        dataTableOutput("tabledata")
    })
    
    )
)

server <- function(input, output) {

   callModule(sankeyPanel, "sankey_panel")
    
}

# Run the application 
shinyApp(ui = ui, server = server)
