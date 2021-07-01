library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(ggplot2) 
library(plotly)
library(dplyr)
library(tidyr)
library(readr)
library(janitor)
library(here)
library(DBI)

# File database using sqlite
DB <- here("FAOTRADE.sqlite")
con <- dbConnect(RSQLite::SQLite(), DB)


trade_matrix <- con %>% tbl("fao_trade_detailedtradematrix")
reporting_countries <- con %>% tbl("fao_countries") %>% select(reporter_countries) %>% collect() 
commodities <- con %>% tbl("fao_items") %>% collect() 

variables <- c("Quantity", "Value") 

years <- tbl(con, "fao_years") %>% collect() 
min_year <- min(years)
max_year <- max(years)
