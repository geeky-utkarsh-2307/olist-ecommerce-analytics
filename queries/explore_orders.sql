SELECT COUNT(*) FROM orders;

SELECT order_status, COUNT(*) FROM orders
GROUP BY order_status
ORDER BY COUNT(*) DESC;

SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) FROM orders;