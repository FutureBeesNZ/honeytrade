countryPlotsUI <- function(id, panel_name="Top Commodities") {

  ns <- NS(id)
  
  tabPanel(panel_name, {
    sidebarLayout(
      sidebarPanel(
     
        pickerInput(ns("country"), "Select Reporting Country", 
                    choices = reporting_countries, selected = "New Zealand",
                    options=pickerOptions(liveSearch=TRUE)),
        sliderInput(ns("n"), "Number of commodities", min=1, max=50, step=1, value=20),
        sliderInput(ns("year"), "Year", min=min_year, max=max_year, step=1, value=max_year, sep="" )
         
      ),
      mainPanel(
        plotOutput(ns("impexp"), height="900px") %>% withSpinner() 
      )
    )
  })
    
}

countryPlots <- function(input, output, session) { 
 
  output$impexp <- renderPlot({
    plot_all_elements(input$country, input$year, input$n)
  })
   
}


sankeyPanelUI <- function(id, panel_name="Sankey Diagrams")  {
 ns <- NS(id)
  
    tabPanel(panel_name, {       
      sidebarLayout(
        sidebarPanel(
          pickerInput(ns("commodity"), "Which commodity?", choices= commodities, selected = "Honey, natural", options=pickerOptions(liveSearch=TRUE)), 
          pickerInput(ns("country"), "Select Reporting Country", choices = reporting_countries, selected = "New Zealand", options=pickerOptions(liveSearch=TRUE)),
          pickerInput(ns("measure"), "Which measure?", choices = variables),
          sliderInput(ns("quantity_filter"), "Filter minimum quantity - IF THE PLOT LOOKS STRANGE, TRY FILTERING"), sep=" "), min=0, max=10000, step=1, value=0), 
          sliderInput(ns("year"), "Years", min=min_year, max=max_year, step=1, value=max_year, sep="" ),
          tableOutput(ns("exporters")),
          tableOutput(ns("importers"))
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
          htmlOutput(ns("plot_title")),
          sankeyNetworkOutput(ns("sankey_plot"), width="100%", height="1000px")
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
  
  output$exporters <- renderTable({ 
    df() %>% select(partner_countries, element, value, item) %>% 
      group_by(partner_countries) %>% 
      collect() %>% 
      tidyr::pivot_wider(names_from = element, values_from=value) %>% 
      arrange(desc(`Export Quantity`)) 
  }) 
    
    output$importers <- renderTable({ 
      
    })
  
  output$sankey_plot <- renderSankeyNetwork({
    plot_sankey(trade_net(df(), element=input$measure ))
  })
   
}







