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
     
    tabPanel("Import/Export", {       
    sidebarLayout(
        sidebarPanel(
           pickerInput("country", "Select Reporting Country", choices = reporting_countries, options=pickerOptions(liveSearch=TRUE)),
           pickerInput("commodity", "Which commodity?", choices= commodities, options=pickerOptions(liveSearch=TRUE)), 
           pickerInput("measure", "Which measure?", choices = variables),
           sliderInput("quantity_filter", "Filter minimum quantity", min=0, max=10000, step=1, value=0), 
           sliderInput("year", "Years", min=min_year, max=max_year, step=1, value=max_year, sep="" )
        ),

        # Show a plot of the generated distribution
        mainPanel(
           htmlOutput("plot_title"),
           sankeyNetworkOutput("sankey_plot")
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
      
    df <- reactive({ 
      mydf <- subset_trade(trade_matrix, !!input$country, !!input$commodity, !!input$year, !!input$quantity_filter)
      validate(
          need(mydf, "That query returned no data, please try another combination")
      )
      mydf
    })
    
    output$plot_title <- renderText({
      rv <- reactiveValuesToList(input)     
      str_interp("<h2>Import/Export for ${rv$commodity} to/from ${rv$country} in ${rv$year}</h2>")
    
    })
    
    
    output$sankey_plot <- renderSankeyNetwork({
      
      plot_sankey(trade_net(df(), element=input$measure ))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
