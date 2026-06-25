WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price)::numeric, 2) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY last_order_date DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT *,
        (r_score + f_score + m_score) AS rfm_total,
        CASE
            WHEN (r_score + f_score + m_score) >= 13 THEN 'Champion'
            WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customer'
            WHEN (r_score + f_score + m_score) >= 7  THEN 'At Risk'
            ELSE 'Lost'
        END AS customer_segment
    FROM rfm_scored
)
-- Raw scores 
SELECT
    customer_unique_id,
    last_order_date,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_total,
    customer_segment
FROM rfm_segmented
ORDER BY rfm_total DESC;

-- Segment summary 
-- SELECT
--     customer_segment,
--     COUNT(*) AS customer_count,
--     ROUND(AVG(monetary)::numeric, 2) AS avg_spend,
--     ROUND(AVG(frequency)::numeric, 2) AS avg_orders
-- FROM rfm_segmented
-- GROUP BY customer_segment
-- ORDER BY avg_spend DESC;