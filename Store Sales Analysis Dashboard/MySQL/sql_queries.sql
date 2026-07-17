-- =====================================================================
-- Store Sales Analysis Dashboard - SQL Analysis Queries
-- Run after database.sql and after loading Cleaned_Data.csv into `sales`.
-- =====================================================================
USE store_sales_db;

-- =====================================================================
-- SECTION 1: BASIC RETRIEVAL (SELECT, WHERE, ORDER BY, LIMIT, DISTINCT)
-- =====================================================================

-- 1. All columns for Technology orders, most recent first
SELECT * FROM sales
WHERE product_category = 'Technology'
ORDER BY order_date DESC
LIMIT 20;

-- 2. Distinct list of states we ship to
SELECT DISTINCT state FROM sales ORDER BY state;

-- 3. Orders with a high discount and low profit (compound WHERE)
SELECT order_id, product_name, discount, profit
FROM sales
WHERE discount >= 0.30 AND profit < 0
ORDER BY profit ASC
LIMIT 15;

-- 4. Orders placed in a date range
SELECT order_id, order_date, sales
FROM sales
WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31'
ORDER BY order_date;

-- 5. Orders from a specific set of states (IN)
SELECT order_id, state, sales
FROM sales
WHERE state IN ('California', 'Texas', 'New York')
ORDER BY sales DESC
LIMIT 20;

-- 6. Product names containing "Chair" (LIKE)
SELECT DISTINCT product_name
FROM sales
WHERE product_name LIKE '%Chair%';

-- =====================================================================
-- SECTION 2: AGGREGATES, GROUP BY, HAVING, CASE
-- =====================================================================

-- 7. Total sales, profit, and order count by category
SELECT product_category,
       COUNT(*)            AS total_orders,
       SUM(sales)           AS total_sales,
       SUM(profit)          AS total_profit,
       ROUND(AVG(sales), 2) AS avg_order_value
FROM sales
GROUP BY product_category
ORDER BY total_sales DESC;

-- 8. Regions where total profit exceeds a threshold (HAVING)
SELECT region, SUM(profit) AS total_profit
FROM sales
GROUP BY region
HAVING SUM(profit) > 100000
ORDER BY total_profit DESC;

-- 9. Sub-categories with more than 300 orders and average discount below 20%
SELECT sub_category,
       COUNT(*) AS order_count,
       ROUND(AVG(discount), 2) AS avg_discount
FROM sales
GROUP BY sub_category
HAVING order_count > 300 AND avg_discount < 0.20
ORDER BY order_count DESC;

-- 10. Order value tier bucketed with CASE (ad hoc, independent of stored column)
SELECT order_id,
       sales,
       CASE
           WHEN sales < 100  THEN 'Small'
           WHEN sales < 500  THEN 'Medium'
           WHEN sales < 1500 THEN 'Large'
           ELSE 'Very Large'
       END AS order_size
FROM sales
ORDER BY sales DESC
LIMIT 20;

-- 11. Monthly revenue trend
SELECT order_year, order_month, order_month_name,
       SUM(sales) AS monthly_revenue
FROM sales
GROUP BY order_year, order_month, order_month_name
ORDER BY order_year, order_month;

-- 12. Regional sales performance
SELECT region,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

-- 13. Best-selling city
SELECT city, state, SUM(sales) AS total_sales
FROM sales
GROUP BY city, state
ORDER BY total_sales DESC
LIMIT 1;

-- 14. Average order value overall
SELECT ROUND(AVG(sales), 2) AS avg_order_value FROM sales;

-- 15. Profit margin by category
SELECT product_category,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM sales
GROUP BY product_category
ORDER BY profit_margin_pct DESC;

-- 16. Lowest performing products by total profit
SELECT product_name, SUM(profit) AS total_profit
FROM sales
GROUP BY product_name
ORDER BY total_profit ASC
LIMIT 10;

-- 17. Top selling products by revenue
SELECT product_name, SUM(sales) AS total_sales, SUM(quantity) AS units_sold
FROM sales
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- =====================================================================
-- SECTION 3: JOINS
-- =====================================================================

-- 18. INNER JOIN sales with customers dimension
SELECT s.order_id, c.customer_name, c.segment, s.sales, s.profit
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
ORDER BY s.sales DESC
LIMIT 20;

-- 19. LEFT JOIN: every customer, with total sales (0 if none recorded yet)
SELECT c.customer_id, c.customer_name, COALESCE(SUM(s.sales), 0) AS total_sales
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_sales DESC;

-- 20. RIGHT JOIN: every sales row, with customer info if available
SELECT s.order_id, s.sales, c.customer_name
FROM customers c
RIGHT JOIN sales s ON c.customer_id = s.customer_id
ORDER BY s.order_date DESC
LIMIT 20;

-- =====================================================================
-- SECTION 4: SUBQUERIES & CTEs
-- =====================================================================

-- 21. Customers whose total spend is above the overall average customer spend (subquery)
SELECT customer_id, customer_name, total_spend
FROM (
    SELECT customer_id, customer_name, SUM(sales) AS total_spend
    FROM sales
    GROUP BY customer_id, customer_name
) AS customer_totals
WHERE total_spend > (
    SELECT AVG(total_spend) FROM (
        SELECT SUM(sales) AS total_spend
        FROM sales
        GROUP BY customer_id
    ) AS avg_calc
)
ORDER BY total_spend DESC;

-- 22. CTE: Top 10 customers by lifetime value (CLV)
WITH customer_ltv AS (
    SELECT customer_id, customer_name,
           SUM(sales) AS lifetime_sales,
           SUM(profit) AS lifetime_profit,
           COUNT(DISTINCT order_id) AS total_orders
    FROM sales
    GROUP BY customer_id, customer_name
)
SELECT *
FROM customer_ltv
ORDER BY lifetime_sales DESC
LIMIT 10;

-- 23. CTE: Category profit margin ranked
WITH category_profit AS (
    SELECT product_category,
           SUM(sales) AS total_sales,
           SUM(profit) AS total_profit
    FROM sales
    GROUP BY product_category
)
SELECT product_category, total_sales, total_profit,
       ROUND(total_profit / total_sales * 100, 2) AS margin_pct
FROM category_profit
ORDER BY margin_pct DESC;

-- =====================================================================
-- SECTION 5: WINDOW FUNCTIONS
-- =====================================================================

-- 24. Running monthly revenue total (window function)
SELECT order_year, order_month,
       SUM(sales) AS monthly_sales,
       SUM(SUM(sales)) OVER (ORDER BY order_year, order_month) AS running_total
FROM sales
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- 25. Rank products within each category by total sales
SELECT product_category, product_name, total_sales,
       RANK() OVER (PARTITION BY product_category ORDER BY total_sales DESC) AS category_rank
FROM (
    SELECT product_category, product_name, SUM(sales) AS total_sales
    FROM sales
    GROUP BY product_category, product_name
) t
QUALIFY category_rank <= 3;  -- Note: MySQL 8.0.31+ ; if unsupported, wrap in an outer SELECT ... WHERE category_rank <= 3

-- 25b. MySQL-safe equivalent of the above (no QUALIFY, works on all MySQL 8 versions)
SELECT * FROM (
    SELECT product_category, product_name, total_sales,
           RANK() OVER (PARTITION BY product_category ORDER BY total_sales DESC) AS category_rank
    FROM (
        SELECT product_category, product_name, SUM(sales) AS total_sales
        FROM sales
        GROUP BY product_category, product_name
    ) t
) ranked
WHERE category_rank <= 3;

-- 26. Month-over-month sales growth (LAG window function)
SELECT order_year, order_month, monthly_sales,
       LAG(monthly_sales) OVER (ORDER BY order_year, order_month) AS prev_month_sales,
       ROUND(
         (monthly_sales - LAG(monthly_sales) OVER (ORDER BY order_year, order_month))
         / LAG(monthly_sales) OVER (ORDER BY order_year, order_month) * 100, 2
       ) AS mom_growth_pct
FROM (
    SELECT order_year, order_month, SUM(sales) AS monthly_sales
    FROM sales
    GROUP BY order_year, order_month
) monthly
ORDER BY order_year, order_month;

-- =====================================================================
-- SECTION 6: VIEWS
-- =====================================================================

-- 27. View: Regional performance summary (reusable in Power BI / reporting)
CREATE OR REPLACE VIEW vw_regional_performance AS
SELECT region,
       COUNT(DISTINCT order_id) AS total_orders,
       SUM(sales)  AS total_sales,
       SUM(profit) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM sales
GROUP BY region;

SELECT * FROM vw_regional_performance ORDER BY total_sales DESC;

-- 28. View: Top customers
CREATE OR REPLACE VIEW vw_top_customers AS
SELECT customer_id, customer_name,
       SUM(sales) AS lifetime_sales,
       COUNT(DISTINCT order_id) AS total_orders
FROM sales
GROUP BY customer_id, customer_name
ORDER BY lifetime_sales DESC;

SELECT * FROM vw_top_customers LIMIT 10;

-- =====================================================================
-- SECTION 7: STORED PROCEDURES
-- =====================================================================

-- 29. Stored procedure: Sales summary for a given region and date range
DELIMITER $$
CREATE PROCEDURE sp_region_sales_summary(
    IN p_region VARCHAR(50),
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT product_category,
           COUNT(*) AS orders,
           SUM(sales) AS total_sales,
           SUM(profit) AS total_profit
    FROM sales
    WHERE region = p_region
      AND order_date BETWEEN p_start_date AND p_end_date
    GROUP BY product_category
    ORDER BY total_sales DESC;
END $$
DELIMITER ;

-- Example call:
-- CALL sp_region_sales_summary('West', '2024-01-01', '2024-12-31');

-- 30. Stored procedure: Top N products by profit
DELIMITER $$
CREATE PROCEDURE sp_top_products_by_profit(IN p_limit INT)
BEGIN
    SELECT product_name, SUM(profit) AS total_profit
    FROM sales
    GROUP BY product_name
    ORDER BY total_profit DESC
    LIMIT p_limit;
END $$
DELIMITER ;

-- Example call:
-- CALL sp_top_products_by_profit(10);

-- =====================================================================
-- SECTION 8: BUSINESS INSIGHT QUERIES
-- =====================================================================

-- 31. Customer lifetime value distribution by segment
SELECT segment,
       ROUND(AVG(customer_total), 2) AS avg_clv
FROM (
    SELECT customer_id, segment, SUM(sales) AS customer_total
    FROM sales
    GROUP BY customer_id, segment
) t
GROUP BY segment
ORDER BY avg_clv DESC;

-- 32. Which discount band is destroying the most profit?
SELECT discount_band,
       COUNT(*) AS orders,
       SUM(profit) AS total_profit,
       ROUND(AVG(profit), 2) AS avg_profit_per_order
FROM sales
GROUP BY discount_band
ORDER BY avg_profit_per_order ASC;

-- 33. Average shipping days by region (operational insight)
SELECT region, ROUND(AVG(shipping_days), 2) AS avg_shipping_days
FROM sales
GROUP BY region
ORDER BY avg_shipping_days DESC;

-- 34. Revenue concentration: % of revenue from top 10% of customers
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM sales
    GROUP BY customer_id
),
ranked AS (
    SELECT *, NTILE(10) OVER (ORDER BY total_sales DESC) AS decile
    FROM customer_totals
)
SELECT
    (SELECT SUM(total_sales) FROM ranked WHERE decile = 1)
    / (SELECT SUM(total_sales) FROM customer_totals) * 100 AS pct_revenue_from_top_decile;
