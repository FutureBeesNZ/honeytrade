countryplotsUI <- function(id, panel_name="Top Commodities") {

  ns <- NS(id)
  
  tabPanel(panel_name, {
    sidebarLayout(
      sidebarPanel(
     
        pickerInput(ns("country"), "Select Reporting Country", 
                    choices = reporting_countries, 
                    options=pickerOptions(liveSearch=TRUE)),
        sliderInput(ns("year"), "Year", min=min_year, max=max_year, step=1, value=max_year, sep="" )
         
      ),
      mainPanel(
        plotOutput(ns("expq")),
        plotOutput(ns("expv")),
        plotOutput(ns("impq")),
        plotOutput(ns("impv"))
      )
    )
  })
    
}

sankeyPanelUI <- function(id, panel_name="Sankey Diagrams")  {
 ns <- NS(id)
  
    tabPanel(panel_name, {       
      sidebarLayout(
        sidebarPanel(
          pickerInput(ns("country"), "Select Reporting Country", choices = reporting_countries, options=pickerOptions(liveSearch=TRUE)),
          pickerInput(ns("commodity"), "Which commodity?", choices= commodities, options=pickerOptions(liveSearch=TRUE)), 
          pickerInput(ns("measure"), "Which measure?", choices = variables),
          sliderInput(ns("quantity_filter"), "Filter minimum quantity", min=0, max=10000, step=1, value=0), 
          sliderInput(ns("year"), "Years", min=min_year, max=max_year, step=1, value=max_year, sep="" )
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
          htmlOutput(ns("plot_title")),
          sankeyNetworkOutput(ns("sankey_plot"))
        )
      )
      
    })
   
}

sankeyPanel <- function(input, output, session) {
  
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







