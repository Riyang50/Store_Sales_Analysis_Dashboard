-- =====================================================================
-- Store Sales Analysis Dashboard - Database Setup
-- =====================================================================
-- Creates the store_sales_db database and the core sales table,
-- with constraints and indexes for query performance.
--
-- Load data with (adjust path to your local Cleaned_Data.csv):
--   LOAD DATA LOCAL INFILE '/path/to/Dataset/Cleaned_Data.csv'
--   INTO TABLE sales
--   FIELDS TERMINATED BY ',' ENCLOSED BY '"'
--   LINES TERMINATED BY '\n'
--   IGNORE 1 ROWS
--   (order_id, order_date, ship_date, customer_id, customer_name, segment,
--    city, state, region, product_category, sub_category, product_name,
--    sales, quantity, discount, profit, shipping_cost, payment_mode,
--    order_priority, is_profit_outlier, order_year, order_month,
--    order_month_name, order_quarter, shipping_days, profit_margin,
--    discount_band, order_value_tier);
-- =====================================================================

DROP DATABASE IF EXISTS store_sales_db;
CREATE DATABASE store_sales_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE store_sales_db;

-- ---------------------------------------------------------------------
-- Customers dimension (normalized for CLV / join demonstrations)
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    customer_id     VARCHAR(20)  NOT NULL,
    customer_name   VARCHAR(150) NOT NULL,
    segment         VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

-- ---------------------------------------------------------------------
-- Main sales fact table
-- ---------------------------------------------------------------------
CREATE TABLE sales (
    row_id              INT AUTO_INCREMENT,
    order_id            VARCHAR(20)   NOT NULL,
    order_date          DATE          NOT NULL,
    ship_date           DATE          NOT NULL,
    customer_id         VARCHAR(20)   NOT NULL,
    customer_name       VARCHAR(150)  NOT NULL,
    segment             VARCHAR(50)   NOT NULL,
    city                VARCHAR(100)  NOT NULL,
    state               VARCHAR(100)  NOT NULL,
    region              VARCHAR(50)   NOT NULL,
    product_category    VARCHAR(50)   NOT NULL,
    sub_category        VARCHAR(50)   NOT NULL,
    product_name        VARCHAR(150)  NOT NULL,
    sales               DECIMAL(12,2) NOT NULL CHECK (sales >= 0),
    quantity            INT           NOT NULL CHECK (quantity > 0),
    discount            DECIMAL(4,2)  NOT NULL DEFAULT 0 CHECK (discount BETWEEN 0 AND 1),
    profit              DECIMAL(12,2) NOT NULL,
    shipping_cost       DECIMAL(10,2) NOT NULL CHECK (shipping_cost >= 0),
    payment_mode        VARCHAR(50)   NOT NULL,
    order_priority      VARCHAR(20)   NOT NULL,
    is_profit_outlier   TINYINT(1)    NOT NULL DEFAULT 0,
    order_year          INT           NOT NULL,
    order_month         INT           NOT NULL,
    order_month_name    VARCHAR(10)   NOT NULL,
    order_quarter       INT           NOT NULL,
    shipping_days       INT           NOT NULL,
    profit_margin       DECIMAL(6,4),
    discount_band       VARCHAR(30),
    order_value_tier    VARCHAR(30),
    CONSTRAINT pk_sales PRIMARY KEY (row_id),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
);

-- ---------------------------------------------------------------------
-- Indexes to speed up common analytical filters
-- ---------------------------------------------------------------------
CREATE INDEX idx_sales_order_date ON sales (order_date);
CREATE INDEX idx_sales_region     ON sales (region);
CREATE INDEX idx_sales_category   ON sales (product_category);
CREATE INDEX idx_sales_customer   ON sales (customer_id);
CREATE UNIQUE INDEX idx_sales_order_product ON sales (order_id, product_name, customer_id);
