source("../exportMySQLData.R")

# SQL-запит для отримання даних
query <- "
SELECT
    d.id AS driver_id,
    COALESCE(o.completed_orders, 0) AS completed_orders,
    COALESCE(o.canceled_orders, 0) AS canceled_orders,
    COALESCE(`of`.proposals_created, 0) AS proposals_created,
    COALESCE(o.total_earnings, 0) AS total_earnings
FROM
    (SELECT id FROM users WHERE type = 'driver') AS d

LEFT JOIN (
    SELECT driver_id,
           COUNT(CASE WHEN status = 'done' THEN 1 END) AS completed_orders,
           COUNT(CASE WHEN status = 'cancel' THEN 1 END) AS canceled_orders,
           SUM(tariff) AS total_earnings
    FROM orders
    GROUP BY driver_id
) o ON d.id = o.driver_id

LEFT JOIN (
    SELECT driver_id, COUNT(id) AS proposals_created
    FROM offers
    GROUP BY driver_id
) `of` ON d.id = `of`.driver_id
"

# Вказання шляху до бази даних SQLite
sqlite_db_path <- "driver_popularity.db"

transfer_data_to_sqlite(query, 'driver_popularity', sqlite_db_path)
