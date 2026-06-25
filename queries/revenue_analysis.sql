SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month, ROUND(SUM(oi.price)::numeric,2) AS total_revenue, COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;

SELECT COALESCE(category_translation.product_category_name_english, 'Uncategorized') AS category,ROUND(SUM(price)::numeric,2) AS total_revenue, COUNT(DISTINCT order_id) as total_orders
FROM order_items LEFT JOIN products ON order_items.product_id = products.product_id
LEFT JOIN category_translation on products.product_category_name = category_translation.product_category_name
GROUP BY COALESCE(category_translation.product_category_name_english, 'Uncategorized')
ORDER BY SUM(price) DESC;

Select SUM(price) / COUNT(DISTINCT order_id)
FROM order_items;

SELECT AVG(order_total) AS avg_order_value
FROM (
    SELECT order_id, SUM(price) AS order_total
    FROM order_items
    GROUP BY order_id
);