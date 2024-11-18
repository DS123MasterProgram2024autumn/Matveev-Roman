source("../exportMySQLData.R")

query <- "
  SELECT create_date, create_from, rec_tariff, status, outside_distance as distance_outside, where_from
  FROM orders
  WHERE status IN ('done', 'cancel', 'prepare_remove', 'removed', 'timeout')
  AND from_city_id = 2561 
  AND create_date BETWEEN UNIX_TIMESTAMP('2019-01-01 00:00:00') 
                            AND UNIX_TIMESTAMP('2019-12-31 23:59:59')
"

transfer_data_to_sqlite(query, 'orders', 'orders.db')
