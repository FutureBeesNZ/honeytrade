library(pool) 
library(shiny)
library(shinyWidgets)
library(ggplot2) 
library(plotly)
library(dplyr)
library(readr)
library(janitor)

#honey <- janitor::clean_names(read_csv('FAOSTAT_data_6-5-2020.csv') )

pool <- pool::dbPool(drv = RPostgres::Postgres(), 
               dbname="geodata", host="40.115.76.146") 

trade_matrix <- tbl(pool, "fao_trade_detailedtradematrix")

reporting_countries <- tbl(pool, "fao_countries") %>% select(reporter_countries) %>%  collect() 

variables <- c("Quantity", "Value") 

years <- tbl(pool, "fao_years") %>% collect() 
min_year <- min(years)
max_year <- max(years)

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
           sliderInput("quantity_filter", "Filter minimum quantity", min=0, max=10000, step=1, value=0), 
           sliderInput("year", "Years", min=min_year, max=max_year, step=1, value=max_year, sep="" )
          # plotlyOutput("world", "World Honey") 
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

      
    
    output$world <- renderPlot({
      
      
      ggplot2( honey, aes())
    })
  
    output$sankey_plot <- renderSankeyNetwork({
    
      mydf <- subset_trade(trade_matrix, !!input$country, "Honey, natural", !!input$year, !!input$quantity_filter)
      plot_sankey(trade_net(mydf, element=input$measure ))
     
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
