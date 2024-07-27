--Standardizing data types

ALTER TABLE healthcare
ALTER COLUMN [Billing Amount] float 

ALTER TABLE healthcare
ALTER COLUMN [Date of Admission] Date 

ALTER TABLE healthcare
ALTER COLUMN [Discharge Date] Date 

-- Exploratory Data Analysis

SELECT *
FROM healthcare

SELECT MIN([Age]) Youngest, MAX([Age]) Oldest
FROM healthcare

SELECT DISTINCT [Blood Type]
FROM healthcare

SELECT DISTINCT [Medical Condition]
FROM healthcare

SELECT DISTINCT [Insurance Provider]
FROM healthcare

SELECT DISTINCT [Admission Type]
FROM healthcare

SELECT DISTINCT [Test Results]
FROM healthcare



--What is the distribution of ages within the dataset?
SELECT 
    CASE 
        WHEN [Age] BETWEEN 18 AND 29 THEN '18-29'
        WHEN [Age] BETWEEN 30 AND 44 THEN '30-44'
		WHEN [Age] BETWEEN 45 AND 64 THEN '45-64'
		WHEN [Age] BETWEEN 65 AND 74 THEN '65-74'
        ELSE '75-89'
    END AS [Age Group],
	COUNT([Age]) Count,
	(COUNT([Age]) * 100) / (SELECT COUNT(*) FROM healthcare) AS Percentage
FROM healthcare
GROUP BY 
    CASE 
        WHEN [Age] BETWEEN 18 AND 29 THEN '18-29'
        WHEN [Age] BETWEEN 30 AND 44 THEN '30-44'
		WHEN [Age] BETWEEN 45 AND 64 THEN '45-64'
		WHEN [Age] BETWEEN 65 AND 74 THEN '65-74'
        ELSE '75-89'
    END
ORDER BY [Age Group] ASC

--How many male and female patients are there?

SELECT [Gender], COUNT([Gender]) Count
FROM healthcare
GROUP BY [Gender] 
ORDER BY Count DESC

--What is the distribution of blood type within the dataset?

SELECT [Blood Type], COUNT([Blood Type]) Count
FROM healthcare
GROUP BY [Blood Type]
ORDER BY Count DESC

--What are the most prevalent medical conditions among patients?

Select TOP 1 [Medical Condition], COUNT([Medical Condition]) Count
FROM healthcare
GROUP BY [Medical Condition]
ORDER BY Count DESC

--How many patients have been admitted for each medical condition?

Select [Medical Condition], COUNT([Medical Condition]) [Patients Admitted]
FROM healthcare
GROUP BY [Medical Condition]
ORDER BY [Patients Admitted] DESC

--What are the count of each admission types?

Select [Admission Type], COUNT(*) [Patients Admitted]
FROM healthcare
GROUP BY [Admission Type]
ORDER BY [Patients Admitted] DESC

--What is the average billing amount per admission?

Select [Admission Type], AVG([Billing Amount]) [Patients Admitted]
FROM healthcare
GROUP BY [Admission Type]
ORDER BY [Patients Admitted] DESC

--Which insurance provider covers the most patients?

SELECT TOP 1 [Insurance Provider], COUNT(*) [Patients Admitted]
FROM healthcare
GROUP BY [Insurance Provider]
ORDER BY [Patients Admitted] DESC

--Which are the top 10 hospital with highest billing amount gained?

SELECT TOP 10 [Hospital], SUM([Billing Amount]) [Total Billing Amount]
FROM healthcare
GROUP BY [Hospital]
ORDER BY [Total Billing Amount] DESC

--Who are the top 10 doctor who have the highest number of admissions?

SELECT TOP 10 [Doctor], COUNT(*) [Patients Admitted]
FROM healthcare
GROUP BY [Doctor]
ORDER BY [Patients Admitted] DESC

--Which are the top 10 doctors with highest billing amount?

SELECT TOP 10 [Doctor], COUNT(*) [Patients Admitted], SUM([Billing Amount]) [Total Billing Amount]
FROM healthcare
GROUP BY [Doctor]
ORDER BY  [Total Billing Amount] DESC

--What is the average length of stay for every admission type?

SELECT  [Admission Type], AVG(DATEDIFF(Day, [Date of Admission], [Discharge Date])) [Average Length of Stay] 
FROM healthcare
GROUP BY [Admission Type]
ORDER BY  [Average Length of Stay]  DESC

--What is the average length of stay for every medical condition?

SELECT  [Medical Condition], AVG(DATEDIFF(Day, [Date of Admission], [Discharge Date])) [Average Length of Stay] 
FROM healthcare
GROUP BY [Medical Condition]
ORDER BY  [Average Length of Stay]  DESC

--What is the average length of stay for age groups and medical condition?

SELECT  
	CASE 
        WHEN [Age] BETWEEN 18 AND 29 THEN '18-29'
        WHEN [Age] BETWEEN 30 AND 44 THEN '30-44'
		WHEN [Age] BETWEEN 45 AND 64 THEN '45-64'
		WHEN [Age] BETWEEN 65 AND 74 THEN '65-74'
        ELSE '75-89'
    END AS [Age Group], 
	[Medical Condition],
	AVG(DATEDIFF(Day, [Date of Admission], [Discharge Date])) [Average Length of Stay] 
FROM healthcare
GROUP BY CASE 
        WHEN [Age] BETWEEN 18 AND 29 THEN '18-29'
        WHEN [Age] BETWEEN 30 AND 44 THEN '30-44'
		WHEN [Age] BETWEEN 45 AND 64 THEN '45-64'
		WHEN [Age] BETWEEN 65 AND 74 THEN '65-74'
        ELSE '75-89'
    END,
	[Medical Condition]
ORDER BY [Medical Condition]  ASC

--What are the most commonly prescribed medications?

SELECT [Medication], COUNT([Medication]) Count
FROM healthcare
GROUP BY [Medication]
ORDER BY Count DESC

--What are the medications frequently associated with every medical conditions?
WITH Medications AS(
	SELECT [Medical Condition], [Medication], COUNT([Medication]) Count
	FROM healthcare
	GROUP BY [Medical Condition], [Medication]
),
MaxCounts AS (
    SELECT [Medical Condition], MAX(Count) AS MaxCount
    FROM Medications
    GROUP BY [Medical Condition]
)
SELECT med.[Medical Condition], med.[Medication], mc.MaxCount
FROM Medications med
INNER JOIN MaxCounts mc ON med.[Medical Condition] = mc.[Medical Condition] AND med.Count = mc.MaxCount;

--What is the distribution of medication for every gender?

SELECT [Gender], [Medication], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Female'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Female'
GROUP BY [Gender], [Medication]
ORDER BY Count DESC

SELECT [Gender], [Medication], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Male'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Male'
GROUP BY [Gender], [Medication]
ORDER BY Count DESC

--What is the distribution of test results for every gender?

SELECT [Gender], [Test Results], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Female'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Female'
GROUP BY [Gender], [Test Results]
ORDER BY Count DESC

SELECT [Gender], [Test Results], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Male'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Male'
GROUP BY [Gender], [Test Results]
ORDER BY Count DESC

--What is the distribution of Medical Condition for every gender?

SELECT [Gender], [Medical Condition], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Female'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Female'
GROUP BY [Gender], [Medical Condition]
ORDER BY Count DESC

SELECT [Gender], [Medical Condition], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Male'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Male'
GROUP BY [Gender], [Medical Condition]
ORDER BY Count DESC

--What is the distribution of Admission Type for every gender?

SELECT [Gender], [Admission Type], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Female'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Female'
GROUP BY [Gender], [Admission Type]
ORDER BY Count DESC

SELECT [Gender], [Admission Type], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Male'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Male'
GROUP BY [Gender], [Admission Type]
ORDER BY Count DESC

--What is the distribution of Admission Type for Medical Condition?
CREATE PROCEDURE GetAdmissionTypeDistributionForMedicalCondition @MedCondition varchar(50)
AS
SELECT [Medical Condition], [Admission Type], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Medical Condition] = @MedCondition), 0), 'N2') Percentage
FROM healthcare
WHERE [Medical Condition] = @MedCondition
GROUP BY [Medical Condition], [Admission Type]
ORDER BY Count DESC

/* POSSIBLE INPUTS
Diabetes
Cancer
Arthritis
Asthma
Hypertension
Obesity
*/

EXEC GetAdmissionTypeDistributionForMedicalCondition @MedCondition = 'Cancer'
EXEC GetAdmissionTypeDistributionForMedicalCondition @MedCondition = 'Diabetes'
EXEC GetAdmissionTypeDistributionForMedicalCondition @MedCondition = 'Arthritis'

--What is the distribution of Admission Type for every gender?

SELECT [Gender], [Blood Type], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Female'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Female'
GROUP BY [Gender], [Blood Type]
ORDER BY Count DESC

SELECT [Gender], [Blood Type], COUNT(*) Count, 
	FORMAT((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM healthcare WHERE [Gender] = 'Male'), 0), 'N2') Percentage
FROM healthcare
WHERE [Gender] = 'Male'
GROUP BY [Gender], [Blood Type]
ORDER BY Count DESC