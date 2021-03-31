# ~honey~world trade

The data come from the FAO trade matrix. This is a relatively large database ~6GB which is stored in sqlite. `data_load.R` downloads and prepares the data and indexes for the application. 

Using FAO's trade matrix data to better understand the international trade in food and food-related commoditites worldwide. Select a commodity and country to see the flows. Change between Value ($) and Quantity (metric tons) to see how these vary. 

# Dependecies 

* R dependecies handled by `renv`
* `iconv` to convert to UTF-8 character set as data from FAO are not encoded as UTF-8
  * Mac: `brew install libiconv`
  * Linux: `apt install libiconv`  


## Sankey Diagram
![](img/sankey.png)

## Top Commodities
![](img/top_commodities.png)
