# Перевірка та встановлення необхідних пакетів
if (!require(DBI)) install.packages("DBI")
if (!require(RMySQL)) install.packages("RMySQL")
if (!require(RSQLite)) install.packages("RSQLite")

# Підключення бібліотек
library(DBI)
library(RMySQL)
library(RSQLite)

params <- list(
  dbname = "iq_by",
  host = "localhost",
  port = 3306,
  user = "root",
  password = "12345678"
)

# transfer_data_to_sqlite: Універсальна функція для переносу даних з MySQL до SQLite

transfer_data_to_sqlite <- function(sql_query, output_table_name, sqlite_db_path) {
  # Підключення до бази даних MySQL
  mysql_conn <- do.call(dbConnect, c(MySQL(), params))
  
  # Виконання SQL-запиту та отримання даних
  data <- dbGetQuery(mysql_conn, sql_query)
  
  # Закриття з'єднання з MySQL
  dbDisconnect(mysql_conn)
  
  # Перевірка: чи запит повернув дані
  if (nrow(data) == 0) {
    stop("Запит не повернув даних. Перевірте SQL-запит або параметри.")
  }
  
  # Підключення до бази даних SQLite
  sqlite_conn <- dbConnect(SQLite(), dbname = sqlite_db_path)
  
  # Запис даних у таблицю SQLite 
  dbWriteTable(sqlite_conn, output_table_name, data, overwrite = TRUE)
  
  # Закриття з'єднання з SQLite
  dbDisconnect(sqlite_conn)
  
  # Повідомлення про успішне завершення
  message("Дані успішно збережені в SQLite базі даних: ", sqlite_db_path)
}