SELECT customer_state AS state, AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)))/86400 as avg_delivery_days, COUNT(DISTINCT order_id) as total_orders
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY total_orders DESC;

SELECT COUNT(*) AS total_delivered, SUM(CASE WHEN order_delivered_customer_date >= order_estimated_delivery_date THEN 1 ELSE 0 END) as late,SUM(CASE WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 1 ELSE 0 END) as ontime, ROUND(100*SUM((CASE WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 1 ELSE 0 END))/COUNT(*),2) as ontime_pct
FROM orders
WHERE orders.order_delivered_customer_date IS NOT NULL
AND orders.order_estimated_delivery_date IS NOT NULL;