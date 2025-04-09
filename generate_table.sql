-- extract 2014 data


CREATE TABLE complaints_2014 AS
SELECT *
FROM consumer_compliant_new
WHERE EXTRACT(YEAR FROM date_received) = 2014;

-- extract 2024 data

CREATE TABLE complaints_2024 AS
SELECT *
FROM consumer_compliant_2025
WHERE EXTRACT(YEAR FROM date_received) = 2024;



-- combine two tables


CREATE TABLE complaints AS
SELECT *, '2014' AS complaint_year FROM complaints_2014
UNION ALL
SELECT *, '2024' AS complaint_year FROM complaints_2024;



SELECT *
FROM complaints
LIMIT 30;




-- Top 5 product
(
SELECT  product_name, '2014' AS year,
        COUNT(*) AS total_complaints
FROM complaints
WHERE complaint_year = '2014'
GROUP BY product_name
ORDER BY total_complaints DESC
LIMIT 5
)
UNION ALL
(
SELECT  product_name, '2024' AS year,
        COUNT(*) AS total_complaints
FROM complaints
WHERE complaint_year = '2024'
GROUP BY product_name
ORDER BY total_complaints DESC
LIMIT 5
)

-- new product which is not in 2014

SELECT DISTINCT product_name
FROM complaints
WHERE complaint_year = '2024'
AND product_name NOT IN (
    SELECT product_name
    FROM complaints
    WHERE complaint_year = '2014'
);




-- Top 10 companies with highest complaints in 2014
(
    SELECT company, COUNT(*) AS total_complaints, '2014' AS year
    FROM complaints
    WHERE complaint_year = '2014'
    GROUP BY company
    ORDER BY total_complaints DESC
    LIMIT 10
)

UNION ALL

-- Top 10 companies with highest complaints in 2024
(
    SELECT company, COUNT(*) AS total_complaints, '2024' AS year
    FROM complaints
    WHERE complaint_year = '2024'
    GROUP BY company
    ORDER BY total_complaints DESC
    LIMIT 10
);


-- change the format of column
ALTER TABLE complaints
    ALTER COLUMN complaint_year TYPE DATE
    USING TO_DATE(complaint_year || '-01-01', 'YYYY-MM-DD');




-- Which states had the highest complaint growth
SELECT 
    state_name AS state,
    SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2024 THEN 1 ELSE 0 END) AS complaints_2024,
    SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2014 THEN 1 ELSE 0 END) AS complaints_2014,
    SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2024 THEN 1 ELSE 0 END) - SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2014 THEN 1 ELSE 0 END) AS growth,
    CASE 
        WHEN SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2014 THEN 1 ELSE 0 END) = 0 THEN 100 -- Prevent division by zero
        ELSE (SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2024 THEN 1 ELSE 0 END) - SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2014 THEN 1 ELSE 0 END)) 
            / CAST(SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2014 THEN 1 ELSE 0 END) AS FLOAT) * 100 
    END AS growth_percentage
FROM complaints
GROUP BY state
ORDER BY growth_percentage DESC
LIMIT 10;

-- most complaints in 2024 and compare with 2014
SELECT 
    product_name,
    SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2024 THEN 1 ELSE 0 END) AS complaints_2024,
    SUM(CASE WHEN EXTRACT(YEAR FROM complaint_year) = 2014 THEN 1 ELSE 0 END) AS complaints_2014
FROM complaints

GROUP BY product_name
ORDER BY complaints_2024 DESC
LIMIT 10;
