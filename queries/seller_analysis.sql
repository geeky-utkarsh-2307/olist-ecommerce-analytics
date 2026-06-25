SELECT oi.seller_id, s.seller_state ,s.seller_city, SUM(oi.price) AS total_revenue, COUNT(DISTINCT oi.order_id) AS total_orders, RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_state ,s.seller_city
ORDER BY SUM(oi.price) DESC;