SELECT * FROM coffee_sales;
--1.CREATING KPIS

/*1.1Total Sales Analysis*/

--1.1.1Total Sales for each respective month
SELECT ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
--SELECT CONCAT(ROUND(SUM(unit_price * transaction_qty)))/1000 , "K" AS Total_Sales-- to adjust p.ex 98.835K

FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 3;  -- March Month

--1.1.2 Determinate the month-on-month increase or decrease in sales 
--1.1.3 Calculate the difference in sales between the selected month and the previous month
WITH monthly_sales AS (
    SELECT
        EXTRACT(MONTH FROM transaction_date) AS month, -- number of the month 
        SUM(unit_price * transaction_qty) AS total_sales -- total sales column 
    FROM coffee_sales
    WHERE EXTRACT(MONTH FROM transaction_date) IN (4, 5) -- for months of April and May 
    GROUP BY EXTRACT(MONTH FROM transaction_date)
)

SELECT
	month,
	Total_sales,
    ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY month)) 
        / LAG(total_sales) OVER (ORDER BY month)::NUMERIC) * 100,2) AS mom_order_increase_percentage
FROM monthly_sales
ORDER BY month;   

-- Month sales division% = CM-PM/PM*100

/*1.2. Total orders analysis*/

--1.2.1 Calculate total number of orders for each respective month
SELECT COUNT(transaction_id) AS Total_orders
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5;  -- May Month

--1.2.2 Determinate the mom increase or decrease in the number of orders
--1.2.3 Calculate the difference in the number of orders between the selected month and previous month 
WITH monthly_orders AS (
    SELECT
        EXTRACT(MONTH FROM transaction_date) AS month, -- number of the months 
        COUNT(transaction_id) AS total_orders -- total orders
    FROM coffee_sales
    WHERE EXTRACT(MONTH FROM transaction_date) IN (4, 5) -- april and may
    GROUP BY EXTRACT(MONTH FROM transaction_date)
)

SELECT
    month,
    total_orders,
    ROUND(((total_orders - LAG(total_orders) OVER (ORDER BY month)) 
        / LAG(total_orders) OVER (ORDER BY month)::NUMERIC) * 100,2) AS mom_order_increase_percentage
FROM monthly_orders
ORDER BY month;

/*1.3.Total Quantity Sold Analysis*/

--1.3.1 Calculate the total quantity sold for each respective month 

SELECT SUM(transaction_qty) AS Total_Quantaty_Sold
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5;  -- May Month

--1.3.2 Determinate the month-on-month increase or decrease in the total quantity sold
--1.3.3 Calculate the difference in the total sold between the selected month and the previous month
WITH monthly_orders AS (
    SELECT
        EXTRACT(MONTH FROM transaction_date) AS month, -- number of the months 
        SUM(transaction_qty) AS total_quantity_sold -- total quantity sold
    FROM coffee_sales
    WHERE EXTRACT(MONTH FROM transaction_date) IN (4, 5) -- april and may
    GROUP BY EXTRACT(MONTH FROM transaction_date)
)

SELECT

    month,
    total_quantity_sold,
    ROUND(((total_quantity_sold - LAG(total_quantity_sold) OVER (ORDER BY month)) 
        / LAG(total_quantity_sold) OVER (ORDER BY month)::NUMERIC) * 100,2) AS mom_quantity_increase_percentage
FROM monthly_orders
ORDER BY month;

--2.CHARTS REQUIREMENTS 

/*1.Calendar Heat Map

To do in PBI:
1.1 Implement a calendar heat map that dynamically adjusts based on the select month from a slicer
1.2 Each day on the calendar will be color-coded to represent sales volume, with darker shades indicating higher sales
1.3 Implemt tooltips to display detailed metrics (sales,orders,quantity) qhen hovering over a specific day

Creating the three metrics*/
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000.0, 1), 'K') AS Total_Sales, -- 1000.0 forces the division to be decimal, avoiding truncation due to integer division.
    CONCAT(ROUND(SUM(transaction_qty)/1000.0,1), 'K') AS Total_Qty_Sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000.0,1), 'K') AS Total_Orders
FROM coffee_sales
WHERE transaction_date = '2023-03-27';
	
/*2.2.Sales Analysis by Weekdays and Weekends 

2.2.1 Segment sales data into weekdays and weekend to analyze performance variations*/

--Note:EXTRACT(DOW FROM date) → retorns 0=Sunday, 1=Monday, ..., 6=Saturday in PostgreSQL

WITH sales_with_day_type AS (
    SELECT
        CASE 
            WHEN EXTRACT(DOW FROM transaction_date) IN (0,6) THEN 'Weekends'
            ELSE 'Weekdays'
        END AS day_type,
        unit_price * transaction_qty AS sales
    FROM coffee_sales
    WHERE EXTRACT(MONTH FROM transaction_date) = 2  -- Feb
)
SELECT
    day_type,
    CONCAT(ROUND(SUM(sales)/1000.0, 1), 'K') AS total_sales
FROM sales_with_day_type
GROUP BY day_type
ORDER BY day_type;

--2.3. Sales analysis by Store Location
--2.3.1 Visualize sales data by different store locations 

SELECT 
    store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000.0, 1), 'K') AS total_sales
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5  -- May
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

--2.3.2Calculate increase or decrease between each month and percentage - sales, quantity and orders 
WITH monthly_by_store AS (
    SELECT
        store_location,
        EXTRACT(MONTH FROM transaction_date) AS month,
        SUM(unit_price * transaction_qty) AS total_sales,
        SUM(transaction_qty) AS total_quantity_sold,
        COUNT(transaction_id) AS total_orders
    FROM coffee_sales
    WHERE EXTRACT(MONTH FROM transaction_date) IN (4, 5)  -- April and May
    GROUP BY store_location, EXTRACT(MONTH FROM transaction_date)
)
SELECT
    store_location,
    month,
    total_sales,
    total_quantity_sold,
    total_orders,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (PARTITION BY store_location ORDER BY month))
         / LAG(total_sales) OVER (PARTITION BY store_location ORDER BY month)::NUMERIC) * 100, 2
    ) AS mom_sales_percentage,
    ROUND(
        ((total_quantity_sold - LAG(total_quantity_sold) OVER (PARTITION BY store_location ORDER BY month))
         / LAG(total_quantity_sold) OVER (PARTITION BY store_location ORDER BY month)::NUMERIC) * 100, 2
    ) AS mom_qty_percentage,
    ROUND(
        ((total_orders - LAG(total_orders) OVER (PARTITION BY store_location ORDER BY month))
         / LAG(total_orders) OVER (PARTITION BY store_location ORDER BY month)::NUMERIC) * 100, 2
    ) AS mom_orders_percentage
FROM monthly_by_store
ORDER BY store_location, month;

/* 2.4.Average sales 
2.4.1 Display daily sales for the selected month with a line chart (below and above avg)*/

--first, only calculating total AVG

SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000.0,1), 'K') AS Avg_sales
FROM
	(
	SELECT 
	SUM(transaction_qty * unit_price) AS total_sales
	FROM coffee_sales
	WHERE EXTRACT(MONTH FROM transaction_date) = 4 -- april
	GROUP BY transaction_date
	) AS Internal_query;


-- AVG Total sales by Day of month 

SELECT 
    EXTRACT(DAY FROM transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 4
GROUP BY EXTRACT(DAY FROM transaction_date)
ORDER BY day_of_month;

WITH daily_sales AS (
    SELECT 
        EXTRACT(DAY FROM transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM coffee_sales
    WHERE EXTRACT(MONTH FROM transaction_date) = 4
    GROUP BY EXTRACT(DAY FROM transaction_date)
),
average_sales AS (
    SELECT AVG(total_sales) AS avg_sales
    FROM daily_sales
)
SELECT 
    ds.day_of_month,
    ds.total_sales,
    CASE 
        WHEN ds.total_sales > a.avg_sales THEN 'Above Average'
        WHEN ds.total_sales < a.avg_sales THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS sales_status
FROM daily_sales ds, average_sales a
ORDER BY ds.day_of_month;

/*2.5. Sales analysis by product category 
2.5.1 Analyze sales performance across different product categories to provide insights into wich product categories contribute the most to overall sales*/

SELECT 
	product_category,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

/*2.6. Top 10 products by sales 
2.6.1 identify and display the top 10 products based on sales volume and allow user to quicly visualize the best-performing products interms of sales*/

SELECT 
	product_type,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_sales 
WHERE EXTRACT(MONTH FROM transaction_date) = 5 AND product_category = 'Coffee' -- for especific product_category
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10; -- to limit top 10

/*2.7. Sales analysis by days and hours 
2.7.1 Utilize a heat map to visualize sales patterns by days and hours*/

SELECT 
	SUM(unit_price * transaction_qty) AS total_sales,
	SUM(transaction_qty) AS total_qty_sold,
	COUNT(*) AS total_orders
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5 -- May
AND EXTRACT(DOW FROM transaction_date) = 0 -- sunday 
AND EXTRACT(HOUR FROM transaction_time) = 14; -- hour No 14

-- Total sales by hours 
SELECT 
	EXTRACT(HOUR FROM transaction_time) AS hour_of_day,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5 -- May
GROUP BY EXTRACT(HOUR FROM transaction_time)
ORDER BY EXTRACT(HOUR FROM transaction_time);

-- + By store_location
SELECT 
	store_location,
	EXTRACT(HOUR FROM transaction_time) AS hour_of_day,
	SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5 -- May
GROUP BY store_location, EXTRACT(HOUR FROM transaction_time)
ORDER BY store_location, EXTRACT(HOUR FROM transaction_time);

--Total sales by day of week

-- Using TO_CHAR - more simple 
SELECT 
    TO_CHAR(transaction_date, 'Day') AS day_of_week,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM coffee_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY TO_CHAR(transaction_date, 'Day')
ORDER BY total_sales DESC;

-- + by store_id
SELECT 
    TRIM(TO_CHAR(transaction_date, 'Day')) AS day_of_week,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_sales
WHERE store_id = 3
  AND EXTRACT(MONTH FROM transaction_date) = 2
GROUP BY TRIM(TO_CHAR(transaction_date, 'Day'))
ORDER BY total_sales DESC;

--Using CASE if needed, to personalize or especify
SELECT 
	CASE
		WHEN EXTRACT(DOW FROM transaction_date) = 1 THEN 'Monday'
		WHEN EXTRACT(DOW FROM transaction_date) = 2 THEN 'Tuesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 3 THEN 'Wednesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 4 THEN 'Thursday'
		WHEN EXTRACT(DOW FROM transaction_date) = 5 THEN 'Friday'
		WHEN EXTRACT(DOW FROM transaction_date) = 6 THEN 'Saturday'
		ELSE 'Sunday'
	END AS Day_of_week,
	ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
FROM coffee_sales
WHERE store_id=4 AND EXTRACT (MONTH FROM transaction_date) = 5 -- May
GROUP BY 
	CASE
		WHEN EXTRACT(DOW FROM transaction_date) = 1 THEN 'Monday'
		WHEN EXTRACT(DOW FROM transaction_date) = 2 THEN 'Tuesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 3 THEN 'Wednesday'
		WHEN EXTRACT(DOW FROM transaction_date) = 4 THEN 'Thursday'
		WHEN EXTRACT(DOW FROM transaction_date) = 5 THEN 'Friday'
		WHEN EXTRACT(DOW FROM transaction_date) = 6 THEN 'Saturday'
		ELSE 'Sunday'
	END
ORDER BY ROUND(SUM(unit_price * transaction_qty)) DESC;

