source("../exportMySQLData.R")

query <- "
  SELECT create_date, tariff as total_price
  FROM orders
  WHERE status = 'done' 
  AND from_city_id = 2561 
  AND tariff > 0
"

transfer_data_to_sqlite(query, 'orders', 'orders.db')
