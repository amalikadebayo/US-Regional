
-- EXPLORATORY SQL ANALYSIS (DATA FAMILIARITY)
  -- how many records of orders in the data
SELECT 
	COUNT(*) AS TOTAL_ORDERS
FROM sales_order_sheet;

  -- years/months of data available
SELECT 
	MIN(OrderDate) AS start_date, 
	MAX(OrderDate) AS end_date
FROM sales_order_sheet;

  -- sales channels present in dataset
SELECT 
	DISTINCT `Sales Channel`
FROM sales_order_sheet;

  -- regions present
SELECT 
	DISTINCT Region
FROM region_sheet;

-- SALES PERFORMANCE
  -- Total Revenue, profit amd cost across time  
SELECT
	YEAR(OrderDate) AS YEAR,
	CONCAT('$', FORMAT(SUM(`Unit Cost`*`Order Quantity`), '2')) AS TOTAL_COST,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
	CONCAT('$', FORMAT((SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)-(SUM(`Unit Cost`*`Order Quantity`))), '2')) AS TOTAL_PROFIT
FROM sales_order_sheet
GROUP BY YEAR;

  -- products that generated the most revenue and profit
SELECT
	DISTINCT P.`Product Name`,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
	CONCAT('$', FORMAT((SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)-(SUM(`Unit Cost`*`Order Quantity`))), '2')) AS TOTAL_PROFIT
FROM sales_order_sheet AS S
JOIN products_sheet AS P ON S._ProductID = P._ProductID
GROUP BY P.`Product Name`
ORDER BY 3 DESC;

  -- Sales channel that performed best (online, instore, distributor, whole sale)
SELECT 
	`Sales Channel`,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
	CONCAT('$', FORMAT((SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)-(SUM(`Unit Cost`*`Order Quantity`))), '2')) AS TOTAL_PROFIT
FROM sales_order_sheet
GROUP BY `Sales Channel`
ORDER BY 3 desc;

  -- Determine high-performing warehouses and their impact on delivery timelines.
SELECT 
	WarehouseCode,
    COUNT(`Order Quantity`) AS TOTAL_ORDERS,
    CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
    CONCAT(FORMAT(AVG(DATEDIFF(DeliveryDate, OrderDate)), '0'), ' days') AS AVG_DELIVERY_TIME
FROM sales_order_sheet
GROUP BY WarehouseCode
ORDER BY 2 DESC;

-- REGIONAL ANALYSIS
  -- Revenue by region (south west east etc)
SELECT
	r.Region,
    CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
	COUNT(`Order Quantity`) AS TOTAL_ORDERS
FROM sales_order_sheet AS s
JOIN store_location_sheet AS st ON st._StoreID = s._StoreID
JOIN  region_sheet AS r ON r.State = st.State
GROUP BY r.Region
ORDER BY TOTAL_ORDERS DESC;

  -- top 10 states and cities by revenue
SELECT
	st.state,
    st.`City Name`,
    ROUND(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)) AS REVENUE_ROUND_UP,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE
FROM sales_order_sheet AS s
JOIN store_location_sheet AS st ON st._StoreID = s._StoreID
GROUP BY st.state, st.`City Name`
ORDER BY 3 desc
LIMIT 10;

  -- how do population and household income in a store's city affect sales 
SELECT
	st.`City Name`,
	st.Population,
	ROUND(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)) AS REVENUE_ROUND_UP,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
    COUNT(`Order Quantity`) AS TOTAL_ORDERS
FROM sales_order_sheet AS s
JOIN store_location_sheet AS st ON st._StoreID = s._StoreID
GROUP BY st.`City Name`, st.Population
ORDER BY 3 desc;

SELECT
	st.`City Name`,
    st.`Household Income`,
	ROUND(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)) AS REVENUE_ROUND_UP,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
    COUNT(`Order Quantity`) AS TOTAL_ORDERS
FROM sales_order_sheet AS s
JOIN store_location_sheet AS st ON st._StoreID = s._StoreID
GROUP BY st.`City Name`, st.`Household Income`
ORDER BY 3 desc;

-- CUSTOMER INSIGHTS
  -- Top 10 customers by revenue
SELECT 
	c.`Customer Names`,
	ROUND(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)) AS REVENUE_ROUND_UP,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE
FROM sales_order_sheet AS s
JOIN customers_sheet AS c ON c.CustomerID = s._CustomerID
GROUP BY c.`Customer Names`
ORDER BY 2 desc
LIMIT 10;
  
  -- Customers with highest purchase frequency (which customers buys most frequently) and which customers bought the most products
SELECT 
	c.`Customer Names`,
	COUNT(_CustomerID) AS FREQUENCY
    -- SUM(`Order Quantity`) AS TOTAL_ORDERS
FROM sales_order_sheet AS s
JOIN customers_sheet AS c ON c.CustomerID = s._CustomerID
GROUP BY c.`Customer Names`
ORDER BY 2 desc
LIMIT 10;

SELECT 
	c.`Customer Names`,
	-- COUNT(_CustomerID) AS FREQUENCY,
    SUM(`Order Quantity`) AS TOTAL_ORDERS
FROM sales_order_sheet AS s
JOIN customers_sheet AS c ON c.CustomerID = s._CustomerID
GROUP BY c.`Customer Names`
ORDER BY 2 desc
LIMIT 10;

  -- average order size and discounts given per customer
SELECT 
	c.`Customer Names`,
	ROUND(SUM(`Order Quantity`)/COUNT(_CustomerID)) AS AVG_Order,
	ROUND(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)/COUNT(_CustomerID)) AS AVG_Value,
    ROUND(AVG(`Discount Applied`)*100) AS 'AVG_Discount (percentage)'
FROM sales_order_sheet AS s
JOIN customers_sheet AS c ON c.CustomerID = s._CustomerID
GROUP BY c.`Customer Names`
ORDER BY 4 desc;

-- SALES TEAM PERFORMANCE
  -- which sales rep/team closed the highest revenue  
SELECT
	sl.`Sales Team`,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE
FROM sales_order_sheet AS s
JOIN sales_team_sheet AS sl ON sl.SalesTeamID = s._SalesTeamID
GROUP BY sl.`Sales Team`
ORDER BY 2 DESC;

  -- which region has the strongest sales team
SELECT
    sl.Region,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE
FROM sales_order_sheet AS s
JOIN sales_team_sheet AS sl ON sl.SalesTeamID = s._SalesTeamID
GROUP BY sl.Region
ORDER BY 2 DESC;

SELECT
	COUNT(`Sales Team`),
    Region
FROM sales_team_sheet
GROUP BY Region
ORDER BY 1 DESC;


-- TIME BASED PERFORMANCE
  -- monthly/quarterly sales trends
SELECT
	MONTH(OrderDate) AS Month_Number,
	MONTHNAME(OrderDate) AS Month_Name,
    QUARTER(OrderDate) AS Quarter,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE
FROM sales_order_sheet
GROUP BY month_number, month_name, Quarter
ORDER BY 1 ASC;

  -- seasonal peaks in sales (e.g holiday surges)
SELECT
	MONTH(OrderDate) AS Month_Number,
	MONTHNAME(OrderDate) AS Month_Name,
    CASE
		WHEN MONTH(OrderDate) IN (12,1,2) THEN 'Winter / Christmas'
        WHEN MONTH(OrderDate) IN (3,4,5) THEN 'Spring'
        WHEN MONTH(OrderDate) IN (6,7,8) THEN 'Summer'
        WHEN MONTH(OrderDate) IN (9,10,11) THEN 'Fall / Autumn'
        END AS SEASON,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE
FROM sales_order_sheet
GROUP BY month_number, month_name, season
ORDER BY 4 desc;
  
SELECT
    QUARTER(OrderDate) AS Quarter,
    CASE QUARTER(OrderDate)
		WHEN 1 THEN 'Q1 (Winter/Spring)'
        WHEN 2 THEN 'Q2 (SPRING/Summer)'
        WHEN 3 THEN 'Q3 (Summer/Fall)'
        WHEN 4 THEN 'Q4 (Holiday Season/Christmas)'
        END AS SEASON,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE
FROM sales_order_sheet
GROUP BY Quarter, Season
ORDER BY 3 desc;
  
  -- average delivery times (order date to delivery date)
SELECT
	CONCAT(ROUND(AVG(DATEDIFF(DeliveryDate,OrderDate))), ' days') AS AVG_DELIVERY
FROM sales_order_sheet;

-- PROFITABILITY
  -- compute profit
SELECT 
	CONCAT('$', FORMAT(SUM(`Unit Cost`*`Order Quantity`), '2')) AS TOTAL_COST,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
	CONCAT('$', FORMAT((SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)-(SUM(`Unit Cost`*`Order Quantity`))), '2')) AS TOTAL_PROFIT
FROM sales_order_sheet;
	
  -- which products give then highest profit margin
SELECT 
	p.`Product Name`,
	CONCAT('$', FORMAT(SUM(`Unit Cost`*`Order Quantity`), '2')) AS TOTAL_COST,
	CONCAT('$', FORMAT(SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`), '2')) AS TOTAL_REVENUE,
	CONCAT('$', FORMAT((SUM(`Unit Price`*(1-`Discount Applied`)*`Order Quantity`)-(SUM(`Unit Cost`*`Order Quantity`))), '2')) AS TOTAL_PROFIT
FROM sales_order_sheet AS s
JOIN products_sheet AS p ON p._ProductID = s._ProductID
GROUP BY p.`Product Name`
ORDER BY TOTAL_PROFIT DESC;



  








