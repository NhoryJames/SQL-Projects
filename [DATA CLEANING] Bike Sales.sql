/*

	Practice Data Cleaning for Bike Sales Data from December 2021

*/

------------ Checking for row duplications and deleting it using CTE ----------

SELECT[Sales_Order #], Customer_Age, Customer_Gender, COUNT(*) num_of_row
FROM bike_sales
GROUP BY [Sales_Order #], Customer_Age, Customer_Gender
HAVING COUNT(*) > 1 


WITH duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY [Sales_Order #], Customer_Age, Customer_Gender ORDER BY [Sales_Order #]) AS RowNumber
    FROM bike_sales
)
DELETE FROM duplicates
WHERE RowNumber > 1

------------ Standardizing date values ----------

SELECT Date
FROM bike_sales

ALTER TABLE bike_sales
ALTER COLUMN Date Date

------------ Inserting values in rows with nulls ----------

-- Null in Day

UPDATE bike_sales
SET Day = DAY(Date)
WHERE Day is NULL

-- Null in Age_Group

UPDATE bike_sales
SET Age_Group = 
	CASE
		WHEN Customer_Age BETWEEN 25 AND 34 THEN 'Young Adults (25-34)'
		WHEN Customer_Age BETWEEN 35 AND 64 THEN 'Adults (25-34)'
		ELSE 'Young (<25)' 
	END
WHERE Age_Group is NULL

-- Null in Product_Description

SELECT Product_Description, [Unit_Cost ], Customer_Gender, COUNT(*)
FROM bike_sales
WHERE [Unit_Cost ] = 1252 AND Customer_Gender = 'F'
GROUP BY  Product_Description, [Unit_Cost ], Customer_Gender

UPDATE bike_sales
SET Product_Description = 'Mountain-200 Black, 46'
WHERE [Unit_Cost ] = 1252 AND Product_Description is NULL

-- Null in Order_Quantity

UPDATE bike_sales
SET Order_Quantity = 1
WHERE Order_Quantity is NULL AND Product_Description = 'Mountain-500 Black, 42'

------------ Separating Product Model, Color and Size from Product_Description ----------

SELECT Product_Description,
SUBSTRING(Product_Description, 1, CHARINDEX(' ', Product_Description) - 1) Product_Model,
SUBSTRING(Product_Description, CHARINDEX(' ', Product_Description) + 1, CHARINDEX(',', Product_Description) - CHARINDEX(' ', Product_Description) - 1) Product_Color,
SUBSTRING(Product_Description, CHARINDEX(',', Product_Description) + 1, LEN(Product_Description)) Product_Size
FROM bike_sales

-- Product_Model
ALTER TABLE bike_sales
ADD Product_Model nvarchar(50)

UPDATE bike_sales
SET Product_Model = SUBSTRING(Product_Description, 1, CHARINDEX(' ', Product_Description) - 1)

-- Product_Color
ALTER TABLE bike_sales
ADD Product_Color nvarchar(50)

UPDATE bike_sales
SET Product_Color = SUBSTRING(Product_Description, CHARINDEX(' ', Product_Description) + 1, CHARINDEX(',', Product_Description) - CHARINDEX(' ', Product_Description) - 1)

-- Product_Size
ALTER TABLE bike_sales
ADD Product_Size nvarchar(50)

UPDATE bike_sales
SET Product_Size = SUBSTRING(Product_Description, CHARINDEX(',', Product_Description) + 1, LEN(Product_Description))

------------ Fixing inaccurate data in Unit Price, Cost, Revenue ----------

SELECT *
FROM bike_sales

-- Unit_Cost

SELECT DISTINCT Product_Description, [Unit_Cost ]
FROM bike_sales

UPDATE bike_sales
SET [Unit_Cost ] = 1252
WHERE [Unit_Cost ] = 0.00 AND Product_Model = 'Mountain-200'

-- Unit_Price

SELECT DISTINCT Product_Description, [Unit_Price ]
FROM bike_sales

UPDATE bike_sales
SET [Unit_Price ] = 769
WHERE [Unit_Price ] = 0.00 AND Product_Model = 'Mountain-400-W'

-- Cost

SELECT Product_Description, Order_Quantity, Unit_Cost, Cost
FROM bike_sales
WHERE Cost <> Order_Quantity * [Unit_Cost ]

UPDATE bike_sales
SET Cost = Order_Quantity*[Unit_Cost ]
WHERE Cost = 0

-- Profit

SELECT Product_Description, Order_Quantity, Unit_Cost, Unit_Price, Cost, Profit, Revenue
FROM bike_sales
WHERE Profit <> (Unit_Price - Unit_Cost) * Order_Quantity 

-- Revenue

SELECT Product_Description, Order_Quantity, Unit_Cost, Unit_Price, Cost, Profit, Revenue
FROM bike_sales
WHERE Revenue <> Cost + Profit

UPDATE bike_sales
SET Revenue = Cost + Profit
WHERE Revenue = 0