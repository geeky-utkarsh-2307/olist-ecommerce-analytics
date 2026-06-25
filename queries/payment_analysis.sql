SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value)::numeric,2) AS total_value,
    ROUND(AVG(payment_value)::numeric,2) AS avg_value,
    ROUND(100 * COUNT(DISTINCT order_id)/ SUM(COUNT(DISTINCT order_id)) OVER(), 1) AS pct_of_orders
FROM order_payments
GROUP BY payment_type
ORDER BY total_orders DESC;

SELECT
    payment_installments,
    COUNT(*) AS total_orders,
    ROUND(AVG(payment_value)::numeric,2) AS avg_order_value
FROM order_payments
WHERE payment_type = 'credit_card'
GROUP BY payment_installments
ORDER BY payment_installments;
