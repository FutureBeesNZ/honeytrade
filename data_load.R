#!/usr/bin/env Rscript
# Run as: 
# Rscript data_load.R
# or ./data_load.R
library(vroom)  # Fast CSV processing
library(RSQLite) # Read/write SQLite dbs
library(dplyr) # Pipes and data processing
library(janitor) # Clean up/simplify column names

# Create connection to file database "FAOTRADE.sqlite"
con <- dbConnect(RSQLite::SQLite(), "FAOTRADE.sqlite")

# Don't download again if clean.csv.gz already exists.
if(!file.exists('clean.csv.gz')) { 
	URL="http://fenixservices.fao.org/faostat/static/bulkdownloads/Trade_DetailedTradeMatrix_E_All_Data_(Normalized).zip"
        # Download
	download.file(URL, 'TradeMatrix.zip') 
        # Uncompress
	system('unzip TradeMatrix.zip')
        # Convert to UTF8 encoding
	system('iconv -c -t utf8 "Trade_DetailedTradeMatrix_E_All_Data_(Normalized).csv"> clean.csv ')
        # Zip outputs
	system('gzip clean.csv')
        # Cleanup 
        system('rm TradeMatrix.zip "Trade_DetailedTradeMatrix_E_All_Data_(Normalized).csv" Trade_DetailedTradeMatrix_E_Flags.csv')
}

data <- vroom::vroom('clean.csv.gz') %>% 
        janitor::clean_names()

# Push to database and create indexes
copy_to(con, data, "fao_trade_detailedtradematrix", temporary = FALSE, 
        overwrite = TRUE, 
        indexes=list(
                     c('reporter_countries', 'item', 'element'), 
                     c('reporter_country_code', 'item_code', 'element_code') 
                    )
         )

# Create summary tables used to drive app
dbExecute(con, "create table if not exists fao_countries as select distinct reporter_countries from fao_trade_detailedtradematrix;")
dbExecute(con, "create table if not exists fao_items as select distinct item from fao_trade_detailedtradematrix order by item;") 
dbExecute(con, "create table if not exists fao_ctry_lookup as select distinct ctry, ctry_code from (select distinct reporter_countries as ctry, reporter_country_code as ctry_code, 'from' as type from fao_trade_detailedtradematrix union select distinct partner_countries as ctry, partner_country_code as ctry_code, 'to' as type from fao_trade_detailedtradematrix);")
dbExecute(con, "create table if not exists fao_item_lookup as select distinct item, item_code from fao_trade_detailedtradematrix order by item;")
dbExecute(con, "create table if not exists fao_element_lookup as select distinct element, element_code from fao_trade_detailedtradematrix order by element;")
dbExecute(con, "create table if not exists fao_years as select distinct year from fao_trade_detailedtradematrix;")
dbExecute(con, "VACUUM;") # make sure db uses disk efficiently


