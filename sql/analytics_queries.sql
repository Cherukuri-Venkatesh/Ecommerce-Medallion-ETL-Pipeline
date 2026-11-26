-- 1. Top 10 High-Value Customers Ranked by Spend (CTE + Window Function)
WITH ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        customer_segment,
        country,
        total_orders,
        total_spent_usd,
        RANK() OVER (PARTITION BY country ORDER BY total_spent_usd DESC) AS country_rank
    FROM ecommerce_ops.gold.customer_spending
)
SELECT * FROM ranked_customers WHERE country_rank <= 3 ORDER BY total_spent_usd DESC LIMIT 10;

-- 2. Monthly Revenue Growth % (LAG Window Function)
WITH monthly_totals AS (
    SELECT
        order_year,
        order_month,
        SUM(monthly_revenue_usd) AS total_revenue,
        SUM(high_risk_orders) AS total_fraud_flagged
    FROM ecommerce_ops.gold.monthly_sales_summary
    GROUP BY order_year, order_month
)
SELECT
    order_year,
    order_month,
    ROUND(total_revenue, 2) AS revenue_usd,
    total_fraud_flagged,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_year, order_month))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY order_year, order_month), 0) * 100, 2
    ) AS mom_growth_pct
FROM monthly_totals
ORDER BY order_year, order_month;

-- 3. Top Performing Product Categories by Net Profit
SELECT
    category,
    SUM(units_sold) AS total_units,
    ROUND(SUM(gross_revenue_usd), 2) AS total_revenue_usd,
    ROUND(SUM(net_profit_usd), 2) AS total_profit_usd
FROM ecommerce_ops.gold.product_performance
GROUP BY category
ORDER BY total_profit_usd DESC;
