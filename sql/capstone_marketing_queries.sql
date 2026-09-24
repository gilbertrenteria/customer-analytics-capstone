-- =====================================================================
-- Customer Analytics Capstone - Retail Campaign Study
-- MySQL queries by Gilbert Renteria (UT Dallas / Fullstack Academy, 2026)
--
-- What each block does:
--   1. Create the marketing_campaign table (Income kept as VARCHAR because
--      the source file stores it as text like "$58,138.00 ").
--   2. Task 1-4: row count, total spend by product category, count of
--      last-campaign responses, and customer counts by education x marital.
--   3. Cleaning: strip "$" and "," from Income so it can be cast to DECIMAL,
--      then compute the average income ignoring NULL / blank values.
--   4. Campaign totals: how many customers accepted each of the 5 campaigns.
--   5. Household: average number of children and teenagers at home.
--   6. Age: add Calculated_Age and Age_group columns, populate them, and
--      report average monthly web visits by age group.
--      (Age here is relative to 2026; the Python analysis and dashboard use
--      2014, the last year in the data, so ages there are 12 years lower.)
-- =====================================================================

USE retail_data;

CREATE TABLE marketing_campaign (
    ID INT PRIMARY KEY,
    Year_Birth INT,
    Age INT,
    Education VARCHAR(50),
    Marital_Status VARCHAR(50),
    Income VARCHAR(50),
    Kidhome INT,
    Teenhome INT,
    Dt_Customer VARCHAR(50),
    Recency INT,
    MntWines INT,
    MntFruits INT,
    MntMeatProducts INT,
    MntFishProducts INT,
    MntSweetProducts INT,
    MntGoldProds INT,
    NumDealsPurchases INT,
    NumWebPurchases INT,
    NumCatalogPurchases INT,
    NumStorePurchases INT,
    NumWebVisitsMonth INT,
    AcceptedCmp3 INT,
    AcceptedCmp4 INT,
    AcceptedCmp5 INT,
    AcceptedCmp1 INT,
    AcceptedCmp2 INT,
    Complain INT,
    Response INT
);

USE retail_data;

-- Task 1: Calculate total customer encounters
SELECT COUNT(*) AS total_customer_encounters 
FROM marketing_campaign;

-- Task 2: Identify the top 10 most purchased products by total volume
SELECT 'Wines' AS Product_Category, SUM(MntWines) AS Total_Purchased FROM marketing_campaign
UNION ALL
SELECT 'Fruits', SUM(MntFruits) FROM marketing_campaign
UNION ALL
SELECT 'Meat Products', SUM(MntMeatProducts) FROM marketing_campaign
UNION ALL
SELECT 'Fish Products', SUM(MntFishProducts) FROM marketing_campaign
UNION ALL
SELECT 'Sweet Products', SUM(MntSweetProducts) FROM marketing_campaign
UNION ALL
SELECT 'Gold Products', SUM(MntGoldProds) FROM marketing_campaign
ORDER BY Total_Purchased DESC 
LIMIT 10;

-- Task 3: Find the count of response values
SELECT Response, COUNT(*) AS Count 
FROM marketing_campaign 
GROUP BY Response;

-- Task 4: Distribution of customers based on education level and marital status
SELECT Education, Marital_Status, COUNT(*) AS Customer_Count
FROM marketing_campaign
GROUP BY Education, Marital_Status
ORDER BY Customer_Count DESC;

-- 1. Strip out the $ and , symbols using the ID key to bypass safe update mode
UPDATE marketing_campaign
SET Income = REPLACE(REPLACE(Income, '$', ''), ',', '')
WHERE ID > 0;

-- 2. Calculate the correct mathematical average
SELECT AVG(CAST(Income AS DECIMAL(12,2))) AS average_income 
FROM marketing_campaign 
WHERE ID > 0 AND Income IS NOT NULL AND Income != 'NULL' AND Income != '';

-- 2. Calculate the total number of promotions accepted by customers
SELECT 
    SUM(AcceptedCmp1) AS Total_Accepted_Cmp1,
    SUM(AcceptedCmp2) AS Total_Accepted_Cmp2,
    SUM(AcceptedCmp3) AS Total_Accepted_Cmp3,
    SUM(AcceptedCmp4) AS Total_Accepted_Cmp4,
    SUM(AcceptedCmp5) AS Total_Accepted_Cmp5
FROM marketing_campaign;

-- 3. Calculate the average number of children and teenagers in households
SELECT AVG(Kidhome) AS avg_children, AVG(Teenhome) AS avg_teenagers 
FROM marketing_campaign;

-- 4. Permanently add the Age and Age_group columns to your table
ALTER TABLE marketing_campaign ADD COLUMN Calculated_Age INT;
ALTER TABLE marketing_campaign ADD COLUMN Age_group VARCHAR(10);

-- 1. Update the age for ID 0
UPDATE marketing_campaign 
SET Calculated_Age = 2026 - Year_Birth
WHERE ID >= 0;

-- 2. Update the age group for ID 0
UPDATE marketing_campaign 
SET Age_group = CASE 
    WHEN Calculated_Age BETWEEN 18 AND 25 THEN '18-25'
    WHEN Calculated_Age BETWEEN 26 AND 35 THEN '26-35'
    WHEN Calculated_Age BETWEEN 36 AND 45 THEN '36-45'
    WHEN Calculated_Age BETWEEN 46 AND 55 THEN '46-55'
    ELSE '56+'
END
WHERE ID >= 0;

-- 3. View your finalized, clean results
SELECT Age_group, AVG(NumWebVisitsMonth) AS avg_visits_per_month
FROM marketing_campaign
GROUP BY Age_group
ORDER BY Age_group ASC;