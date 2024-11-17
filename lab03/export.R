source("../exportMySQLData.R")

query <- "
SELECT
  o.id AS order_id,
  o.create_date,
  o.create_from,
  o.where_from,
  o.where_to,
  o.rec_tariff,
  o.tariff,
  o.status,
  ts.total_price,
  ts.distance_inside,
  ts.distance_outside,
  ts.distance_slowly_inside,
  ts.distance_slowly_outside,
  ts.duration_inside,
  ts.duration_slowly_inside,
  ts.duration_outside,
  ts.duration_slowly_outside,
  ts.duration_stand_before_moving,
  ts.duration_stand
FROM orders o
JOIN taxometer_session ts ON o.id = ts.order_id
WHERE o.from_city_id = 2561 AND o.status = 'done' AND
	o.create_date BETWEEN UNIX_TIMESTAMP('2021-01-01 00:00:00') 
                        AND UNIX_TIMESTAMP('2021-12-31 23:59:59');
"

transfer_data_to_sqlite(query, 'orders', 'orders.db')
