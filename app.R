#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
library(ggplot2) 
library(plotly)
library(dplyr)
library(readr)

honey <- read_csv('FAOSTAT_data_6-5-2020.csv') 

reporting_countries <- honey %>% distinct(`Reporter Countries`)

variables <- honey %>% distinct(Element) 

min_year <- min(honey$Year)
max_year <- max(honey$Year)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("FAO Honey Import/Export Data"),

    # Sidebar with a slider input for number of bins 
    tabsetPanel(
     
    tabPanel("Import/Export", {       
    sidebarLayout(
        sidebarPanel(
           selectInput("country", "Select Reporting Country", choices = reporting_countries),
           selectInput("measure", "Which measure?", choices = variables),
           sliderInput("years", "Years", min=min_year, max=max_year, step=1, value=c(min_year, max_year), sep="" )
        ),

        # Show a plot of the generated distribution
        mainPanel(
           sankeyNetworkOutput("sankey_plot", height = '900'),
        )
    )
    
    }),
    tabPanel("Table", {
        dataTableOutput("tabledata")
    })
    
    )
)

server <- function(input, output) {

    subset_data <- reactive({
        honey %>% 
            filter(`Reporter Countries` == input$country ) %>% 
            filter(`Element` == input$measure) %>% 
            filter(`Year` > input$years[1] ) %>% 
            filter(`Year` < input$years[2] ) %>% 
            select(Element, Year, `Partner Countries`, Value, Unit)

        
        })
    
    output$tabledata <- renderDataTable({
      subset_data()   
    })
    
    output$sankey_plot <- renderSankeyNetwork({
     
      plot_sankey(trade_net(input$country))
     
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
