source("../exportMySQLData.R")

query <- "
  SELECT o.id, o.create_date, o.create_from, o.where_from, o.where_to, o.inside_distance, o.outside_distance,
	  o.from_city_id,
    o.rec_tariff, 
    l1.date AS finish_date, 
    l2.date AS start_pickup_date, 
    l3.date AS finish_pickup_date,
	  offers.type_tariff

  FROM orders as o
  INNER JOIN log_status_order l1 ON o.id = l1.order_id AND o.driver_id = l1.driver_id AND l1.after_status = 'done'
  INNER JOIN log_status_order l2 ON o.id = l2.order_id AND o.driver_id = l2.driver_id AND l2.user_type = 'client' AND l2.after_status = 'accepted' 
  INNER JOIN log_status_order l3 ON o.id = l3.order_id AND o.driver_id = l3.driver_id AND l3.after_status = 'arrived'

  INNER JOIN offers ON offers.order_id = o.id
  					AND offers.driver_id = o.driver_id
                      AND offers.status = 'accept'

  WHERE o.from_city_id = 2561 AND o.status = 'done' AND
	o.create_date BETWEEN UNIX_TIMESTAMP('2019-01-01 00:00:00') 
                        AND UNIX_TIMESTAMP('2019-12-31 23:59:59');
"

transfer_data_to_sqlite(query, 'orders', 'orders.db')

query <- "
  SELECT 
      client_id,
      COUNT(*) AS trip_count,
      SUM(tariff) AS total_spent,
      MIN(FROM_UNIXTIME(create_date)) AS first_trip_date,
      DATEDIFF('2023-01-10', MIN(FROM_UNIXTIME(create_date))) AS days_since_first_trip
  FROM 
      orders
  WHERE 
      status = 'done' 
      AND client_id IS NOT NULL 
      AND from_city_id = 2561 
      AND create_date BETWEEN UNIX_TIMESTAMP('2019-01-01 00:00:00') 
                            AND UNIX_TIMESTAMP('2019-12-31 23:59:59')
  GROUP BY 
      client_id
  HAVING 
      trip_count > 1
"

transfer_data_to_sqlite(query, 'orders_stat', 'orders_stat.db')
