library(vroom) 
library(RPostgres) 
library(pool)

pool <- pool::dbPool(drv = RPostgres::Postgres(), 
                     dbname="geodata", 
                     host="40.115.76.146") 

URL="http://fenixservices.fao.org/faostat/static/bulkdownloads/Trade_DetailedTradeMatrix_E_All_Data_(Normalized).zip"
download.file(URL, 'TradeMatrix.zip') 
system('unzip TradeMatrix.zip')
system('iconv -c -t utf8 "Trade_DetailedTradeMatrix_E_All_Data_(Normalized).csv"> clean.csv ')
data <- vroom::vroom('clean.csv')

# Push to database
data %>% copy_to(pool, "fao_trade_detailedtradematrix") 

# Cleanup 
system('rm TradeMatrix.zip "Trade_DetailedTradeMatrix_E_All_Data_(Normalized).csv" clean.csv Trade_DetailedTradeMatrix_E_Flags.csv')

# Also need to add indexes and compute summary tables that drive the app
