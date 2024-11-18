source("../exportMySQLData.R")

# this file require running from lab04 relation dir

# Шлях для нового файлу SQLite

db_path <- file.path(getwd(), "Taxi/taxi_orders.db")
cat("Повний шлях до бази даних:", db_path, "\n")

# Підключаємося до SQLite і створюємо нову базу даних
sqlite_conn <- dbConnect(SQLite(), dbname = db_path)

# SQL-запит для вибору даних із MySQL
query <- "SELECT id, 
    FROM_UNIXTIME(create_date) AS create_date, 
    create_from, 
    tariff 
  FROM orders o 
  WHERE o.from_city_id = 2561 AND 
    o.status = 'done' AND
  	o.create_date BETWEEN UNIX_TIMESTAMP('2019-01-01 00:00:00') 
                          AND UNIX_TIMESTAMP('2019-12-31 23:59:59')"


transfer_data_to_sqlite(query, 'orders', db_path)