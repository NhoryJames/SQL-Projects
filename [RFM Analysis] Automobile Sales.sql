/*

	RFM Analysis for Automobile Sales  

*/

DECLARE @today AS DATE = '2020-06-01';

WITH scores AS(
	SELECT 
		CUSTOMERNAME,
		-- Calculates how many day has passed since 2020-06-01. 
		DATEDIFF(Day, MAX(ORDERDATE), @today) recency_score,
		-- Counts all others of a customer.
		COUNT(ORDERNUMBER) frequency_score,
		-- Adds all the sales that the company had gained from the individual customer.
		SUM(QUANTITYORDERED * PRICEEACH) monetary_score
	FROM automobile_sales
	-- Orders with a cancelled status does not count in 
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved' 
	GROUP BY CUSTOMERNAME
),
rfm AS(
	SELECT 
		CUSTOMERNAME,
		NTILE(5) OVER (ORDER BY recency_score DESC) as R,
		NTILE(5) OVER (ORDER BY frequency_score ASC) as F,
		NTILE(5) OVER (ORDER BY monetary_score ASC) as M
	FROM scores
)
SELECT 
	CUSTOMERNAME,
	CONCAT_WS('-', R, F, M) rfm_cell
FROM rfm

-- 1. How many customers are there in each segment?
--SELECT 
--	(R + F + M) / 3 RFM_SEGMENT,
--	COUNT(rfm.CUSTOMERNAME) NUM_OF_CUSTOMER
--FROM rfm 
--INNER JOIN scores ON rfm.CUSTOMERNAME = scores.CUSTOMERNAME
--GROUP BY (R + F + M) / 3
--ORDER BY RFM_SEGMENT DESC

-- 2. How much sales do each segments generated?
--SELECT 
--	(R + F + M) / 3 RFM_SEGMENT,
--	SUM(monetary_score) TOTAL_SALES
--FROM rfm 
--INNER JOIN scores ON rfm.CUSTOMERNAME = scores.CUSTOMERNAME
--GROUP BY (R + F + M) / 3
--ORDER BY RFM_SEGMENT DESC

--3. What is the average recency score AND average frequency score for each segment?
--SELECT 
--	(R + F + M) / 3 RFM_SEGMENT,
--	AVG(recency_score) AVG_RECENCY_SCORE,
--	AVG(frequency_score) AVG_FREQUENCY_SCORE
--FROM rfm 
--INNER JOIN scores ON rfm.CUSTOMERNAME = scores.CUSTOMERNAME
--GROUP BY (R + F + M) / 3
--ORDER BY RFM_SEGMENT DESC

--4. How much sales do each customers generate in each section?
--SELECT 
--	(R + F + M) / 3 RFM_SEGMENT,
--	SUM(monetary_score) / COUNT(rfm.CUSTOMERNAME) SALES_PER_CUSTOMER
--FROM rfm 
--INNER JOIN scores ON rfm.CUSTOMERNAME = scores.CUSTOMERNAME
--GROUP BY (R + F + M) / 3
--ORDER BY RFM_SEGMENT DESC

-- 5. What is the average recency, frequency, and monetary score for each segments in a specific city?
--SELECT 	
--	auto.COUNTRY,
--	COUNT(DISTINCT(auto.CUSTOMERNAME)) NUM_OF_CUSTOMER,
--	AVG(scores.recency_score) AVG_RECENCY_SCORE,
--	AVG(scores.frequency_score) AVG_FREQUENCY_SCORE,
--	AVG(scores.monetary_score) AVG_MONETARY_SCORE
--FROM scores 
--FULL JOIN automobile_sales as auto ON scores.CUSTOMERNAME = auto.CUSTOMERNAME
--WHERE auto.STATUS = 'Shipped' OR auto.STATUS = 'Resolved' 
--GROUP BY auto.COUNTRY
--ORDER BY COUNTRY DESC

-- 6. How many customers have a recency score of less than 30 days?
--SELECT 
--	COUNT(CUSTOMERNAME) customer_count
--FROM scores
--WHERE recency_score < 30

-- 7. Which customer segment has the highest average sales volume per order? SUM(SALES) / SUM(QUANTITYORDERED)
--SELECT 
--	CUSTOMERNAME,
--	SUM(SALES)/SUM(QUANTITYORDERED) average_sales_volume_per_order
--FROM automobile_sales
--WHERE STATUS = 'Shipped' OR STATUS = 'Resolved' 
--GROUP BY CUSTOMERNAME

-- 8. Which is the top 10 customers who are the most valuable based on their monetary scores?
--SELECT TOP 10
--	CUSTOMERNAME,
--	monetary_score
--FROM scores
--ORDER BY monetary_score DESC