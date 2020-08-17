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

shinyApp(ui = ui, server = server)
