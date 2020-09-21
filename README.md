# ~honey~world trade

The data come from the FAO trade matrix. This is a relatively large database ~4.5GB and needs to be imported into a queryable database. `data_load.R` shows the steps in this process. Once the data are loaded, you should consider indexing the columns used by the interface to select commodity, country and years. This will prevent full table-scans each time a user interacts with the Shiny app. This is mostly a proof-of-concept and is not what I would call 'production ready'. 

Using FAO's trade matrix data to better understand the international trade in food and food-related commoditites worldwide. Select a commodity and country to see the flows. Change between Value ($) and Quantity (metric tons) to see how these vary. 

## Sankey Diagram
![](img/sankey.png)

## Top Commodities
![](img/top_commodities.png)
