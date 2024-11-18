source("../exportMySQLData.R")

query <- "
  SELECT 
    CAST(JSON_EXTRACT(where_from, '$.latitude') AS DOUBLE) AS from_lat,
    CAST(JSON_EXTRACT(where_from, '$.longitude') AS DOUBLE) AS from_lon,
    CAST(JSON_EXTRACT(where_to, '$.latitude') AS DOUBLE) AS to_lat,
    CAST(JSON_EXTRACT(where_to, '$.longitude') AS DOUBLE) AS to_lon,
    rec_tariff,
    create_date
  FROM orders
  WHERE status = 'done' 
  AND from_city_id = 2561 
  AND create_date BETWEEN UNIX_TIMESTAMP('2022-01-01 00:00:00') 
                            AND UNIX_TIMESTAMP('2022-12-31 23:59:59')
  AND where_to IS NOT NULL 
  AND rec_tariff > 0;
"

transfer_data_to_sqlite(query, 'orders', 'orders.db')

# test orders count
db <- dbConnect(SQLite(), dbname = "orders.db")
query <- "SELECT * FROM orders"
data <- dbGetQuery(db, query)
cat("Кількість записів у data:", nrow(data), "\n")
dbDisconnect(db)
