
use Target_sales

--Creating Table 01-Customers

CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);


--Insert data from CSV file to 01-Customer table

BULK INSERT customers
FROM 'D:\projects\Target sales (SQL)\customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

select * from customers;

-----------------------------------------------

--Create table 02-Geolocation

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

--Insert data from CSV file to 02-Geolocation

BULK INSERT geolocation
FROM 'D:\projects\Target sales (SQL)\geolocation.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

select * from geolocation

----------------------------------------------

--Create table 03-order_items

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

--Insert data from CSV file to 03-Orders_items

BULK INSERT order_items
FROM 'D:\projects\Target sales (SQL)\order_items.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

select * from order_items

-----------------------------------------------------------

--Create table 04-order_reviews

CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

--Insert data from CSV file to 04-Order_reviews

BULK INSERT order_reviews
FROM 'D:\projects\Target sales (SQL)\order_reviews.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

select * from order_reviews

----------------------------------------------

--Create table 05-orders
CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

--Insert data from CSV file to 05-Orders

BULK INSERT orders
FROM 'D:\projects\Target sales (SQL)\orders.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

select * from orders

---------------------------------------------

--Create table 06-payments
CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

--Insert data from CSV file to 06-payments

BULK INSERT payments
FROM 'D:\projects\Target sales (SQL)\payments.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

Select * from payments

-----------------------------------------------

--Create table 07-Products
CREATE TABLE products (
    product_id VARCHAR(50),
    product_category VARCHAR(100),
    product_name_length FLOAT,
    product_description_length FLOAT,
    product_photos_qty FLOAT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

--Insert data from CSV file to 07-products

BULK INSERT products
FROM 'D:\projects\Target sales (SQL)\products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

select * from products

-----------------------------------------------

--Create table 08-sellers

CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

--Insert data from CSV file to 08-sellers

BULK INSERT sellers
FROM 'D:\projects\Target sales (SQL)\sellers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

select * from sellers

-------------------------------------------------------------

--Problems statments for Target_sales_analysis:-

--1. Get the time range between which the orders were place?
SELECT
    MIN(order_purchase_timestamp) AS First_Order_Date,
    MAX(order_purchase_timestamp) AS Last_Order_Date
FROM orders;

--alternatetive questions:-
--A) If you want to know the duration between the first and last order in days:
SELECT
	Min(order_purchase_timestamp) as First_order_date,
	Max(order_purchase_timestamp) as End_order_date,
	DATEDIFF(
		day,
		min(order_purchase_timestamp),
		max(order_purchase_timestamp)
	) as Total_days
	from orders

--B) If you want to know the duration between the first and last orders in months:
Select
	min(order_purchase_timestamp) as First_order_date,
	max(order_purchase_timestamp) as End_order_date,
	DATEDIFF(
		month,
		min(order_purchase_timestamp),
		max(order_purchase_timestamp)
	) as Total_months
from orders

--C) If you want to know the duration between the first and last orders in years:
Select
	min(order_purchase_timestamp),
	max(order_purchase_timestamp),
	DATEDIFF(
		year,
		min(order_purchase_timestamp),
		max(order_purchase_timestamp)
	) as Total_years
from orders

------------------------------------------------------------------

--2. Count the Cities & States of customers who ordered during the given period.

Select
	c.customer_state,
	c.customer_city,
	COUNT (*) as Total_orders
from orders o
INNER JOIN customers c
	on o.customer_id = c.customer_id
GROUP BY
	c.customer_state,
	c.customer_city
ORDER by Total_orders DESC

---------------------------------------------------

--2. In depth exploration

--a) Is there a growing trend in the no. of orders placed over the past year?

SELECT
    YEAR(order_purchase_timestamp) AS Order_Year,
    COUNT(order_id) AS Total_Orders
FROM orders
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY Order_Year;


---------------------------------------------------------------------------------------

--b) Can we see some kind of monthly seasonality in terms of the no. of orders being placed?

Select
	Format(order_purchase_timestamp, 'yyyy-MM') as Orders_monthly,
	Count(order_id) as Total_orders
From orders
Group by Format(order_purchase_timestamp, 'yyyy-MM')
Order by Orders_monthly

--Extra analysis
--Same thing but with month name.

Select
	Datename(Month,order_purchase_timestamp) as Month_name,
	Month(order_purchase_timestamp) as Month_number,
	Count(order_id) as Total_orders
from orders
Group by Datename(Month,order_purchase_timestamp),
	Month(order_purchase_timestamp)
Order by Month_number

------------------------------------------------------------------------------

--c)During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
	--i) 0-6 hrs : Dawn
	--ii) 7-12 hrs : Mornings
	--iii) 13-18 hrs : Afternoon
	--iv) 19-23 hrs : Night

SELECT
    CASE
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
    END AS Time_of_Day,
    COUNT(*) AS Total_Orders
FROM orders
GROUP BY
    CASE
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
        WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
    END
ORDER BY Total_Orders DESC;


-----------------------------------------------------------------------------
--3. Evolution of E-commerce orders in the Brazil region:

--a) Get the month on month no. of orders placed in each state.

select
	c.customer_state,
	Format(o.order_purchase_timestamp, 'yyyy-MM') as Order_month,
	count(o.order_id) as Total_orders
from orders o
Inner join customers c
	on o.customer_id = c.customer_id
Group by 
	c.customer_state,
	Format(o.order_purchase_timestamp, 'yyyy-MM')
Order by
	c.customer_state,
	Order_month

--b) How are the customers distributed across all the states?

Select
	customer_state,
	Count(customer_id) as Total_customers
From customers
Group by customer_state
Order by Total_customers DESC

---------------------------------------------------------------
--4. Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.

--a) Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only). You can use the "payment_value" column in the payments table to get the cost of orders.

WITH Revenue AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS Order_Year,
        SUM(p.payment_value) AS Revenue
    FROM orders o
    JOIN payments p
        ON o.order_id = p.order_id
    WHERE MONTH(o.order_purchase_timestamp) BETWEEN 1 AND 8
      AND YEAR(o.order_purchase_timestamp) IN (2017, 2018)
    GROUP BY YEAR(o.order_purchase_timestamp)
)
SELECT
    *,
    ROUND(
        (Revenue - LAG(Revenue) OVER(ORDER BY Order_Year))
        * 100.0
        / LAG(Revenue) OVER(ORDER BY Order_Year),
        2
    ) AS Percentage_Increase
FROM Revenue;

--b) Calculate the Total & Average value of order price for each state.

WITH Order_Value AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.price) AS Order_Total
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        c.customer_state
)
SELECT
    customer_state,
    ROUND(SUM(Order_Total), 2) AS Total_Order_Value,
    ROUND(AVG(Order_Total), 2) AS Average_Order_Value
FROM Order_Value
GROUP BY customer_state
ORDER BY Total_Order_Value DESC;

--c) Calculate the Total & Average value of order freight for each state.

WITH Freight_Value AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.freight_value) AS Order_Freight
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        c.customer_state
)
SELECT
    customer_state,
    ROUND(SUM(Order_Freight), 2) AS Total_Freight_Value,
    ROUND(AVG(Order_Freight), 2) AS Average_Freight_Value
FROM Freight_Value
GROUP BY customer_state
ORDER BY Total_Freight_Value DESC;

----------------------------------------------------------------------------

--5) Analysis based on sales, freight and delivery time.
--a) Find the no. of days taken to deliver each order from the order’s purchase date as delivery time. Also, calculate the difference (in days) between the estimated & actual delivery date of an order. Do this in a single query. You can calculate the delivery time and the difference between the estimated & actual delivery date using the given formula:
--i) time_to_deliver = order_delivered_customer_date - order_purchase_timestamp
--ii) diff_estimated_delivery = order_delivered_customer_date - order_estimated_delivery_date

SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    DATEDIFF(
        DAY,
        order_purchase_timestamp,
        order_delivered_customer_date
    ) AS time_to_deliver,

    DATEDIFF(
        DAY,
        order_estimated_delivery_date,
        order_delivered_customer_date
    ) AS diff_estimated_delivery

FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

--b) Find out the top 5 states with the highest & lowest average freight value.

--Highest average freight value
SELECT TOP 5
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS Avg_Freight_Value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY Avg_Freight_Value DESC;

--Lowest average freight value

SELECT TOP 5
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS Avg_Freight_Value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY Avg_Freight_Value ASC;

--Combine Query of highest and lowest average freight value

WITH Freight_Data AS (
    SELECT
        c.customer_state,
        ROUND(AVG(oi.freight_value), 2) AS Avg_Freight_Value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_state
)

SELECT 'Highest' AS Category, *
FROM (
    SELECT TOP 5 *
    FROM Freight_Data
    ORDER BY Avg_Freight_Value DESC
) H

UNION ALL

SELECT 'Lowest' AS Category, *
FROM (
    SELECT TOP 5 *
    FROM Freight_Data
    ORDER BY Avg_Freight_Value ASC
) L;

--c) Find out the top 5 states with the highest & lowest average delivery time.

WITH Delivery_Time AS (
    SELECT
        c.customer_state,
        AVG(
            DATEDIFF(
                DAY,
                o.order_purchase_timestamp,
                o.order_delivered_customer_date
            )
        ) AS Avg_Delivery_Time
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY c.customer_state
)

SELECT 'Highest' AS Category, *
FROM (
    SELECT TOP 5 *
    FROM Delivery_Time
    ORDER BY Avg_Delivery_Time DESC
) H

UNION ALL

SELECT 'Lowest' AS Category, *
FROM (
    SELECT TOP 5 *
    FROM Delivery_Time
    ORDER BY Avg_Delivery_Time ASC
) L;

--d) Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery. You can use the difference between the averages of actual & estimated delivery date to fi gure out how fast the delivery was for each state.

SELECT TOP 5
    c.customer_state,
    ROUND(
        AVG(
            DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            )
        ),
        2
    ) AS Avg_Delivery_Difference
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY Avg_Delivery_Difference ASC;

-------------------------------------------------------------------------------------------------

--6) Analysis based on the payments:
--a) Find the month on month no. of orders placed using different payment types.

SELECT
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS Order_Month,
    p.payment_type,
    COUNT(DISTINCT o.order_id) AS Total_Orders
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM'),
    p.payment_type
ORDER BY
    Order_Month,
    p.payment_type;


--b) Find the no. of orders placed on the basis of the payment installments that have been paid.

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS Total_Orders
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;
