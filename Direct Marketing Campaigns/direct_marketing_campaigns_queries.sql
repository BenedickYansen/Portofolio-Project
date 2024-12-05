
-- Bank Marketing Campaign Analysis--
-- Source : https://archive.ics.uci.edu/dataset/222/bank+marketing

--------------------------------------------------------------------

-------------------- DATA PREPARATION ------------------------------

--------------------------------------------------------------------

-- DROP DATABASE IF EXISTS `bank_marketing`;
-- CREATE DATABASE `bank_marketing`;
-- USE `bank_marketing`;

DESCRIBE marketing_campaign;

-- CREATE A STAGING TABLE
 
CREATE TABLE mcampaign_staging LIKE marketing_campaign;

SELECT *
FROM mcampaign_staging;

INSERT INTO mcampaign_staging
SELECT * FROM marketing_campaign;

-- Count the total number of rows and columns
SELECT COUNT(*) AS total_rows FROM mcampaign_staging;

-- Check for duplicates
WITH duplicate_cte AS
(
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY age, job, marital, education, balance, `day`, `month`, duration, campaign) AS Row_Num
	FROM mcampaign_staging
)
SELECT *
FROM duplicate_cte
WHERE Row_Num > 1;

SELECT * FROM mcampaign_staging;

-- Check for null value
SELECT * 
FROM mcampaign_staging
WHERE job IS NULL OR marital IS NULL OR education IS NULL;

-- Renaming the column 'y' to 'target_response' to make it more descriptive
ALTER TABLE mcampaign_staging RENAME COLUMN y TO target_response;


--------------------------------------------------------------
----------------- Exploratory Data Analysis-------------------
--------------------------------------------------------------


-- Viewing the first 50 rows
SELECT * FROM mcampaign_staging
LIMIT 100;

-- Count the number of clients based on job type
SELECT job, COUNT(*) AS total_clients
FROM mcampaign_staging
GROUP BY job
ORDER BY total_clients DESC;

-- Client Age Distribution
SELECT age, COUNT(*) age_total
FROM mcampaign_staging
GROUP BY age
ORDER BY age_total DESC;

-- Identifying how many clients have defaulted credit
SELECT `default`, COUNT(*) AS total_default
FROM mcampaign_staging
GROUP BY `default`;

-- Identifying how many clients have housing credit
SELECT housing, COUNT(*) AS total_housing
FROM mcampaign_staging
GROUP BY housing;

-- Identifying the relationship between balance and defaulted credit
SELECT `default`, AVG(balance) AS average_balance
FROM mcampaign_staging
GROUP BY `default`;

-- Identifying relationship between balance dan housing credit
SELECT housing, AVG(balance) AS average_balance
FROM mcampaign_staging
GROUP BY housing;

-- Identifying relationship between balance dan housing credit
SELECT housing, AVG(balance) AS average_balance
FROM mcampaign_staging
GROUP BY housing;

-- Examining whether the duration of contact influences the success of the campaign
SELECT target_response, AVG(duration) AS avg_contact_duration
FROM mcampaign_staging
GROUP BY target_response;

-- Evaluating the campaign results based on the outcome of the previous marketing campaign (poutcome)
SELECT poutcome, COUNT(*) AS total_success_poutcome	,
SUM(CASE WHEN target_response = 'yes' THEN 1 ELSE 0 END ) AS successful_subscription
FROM mcampaign_staging 
GROUP BY poutcome;

-- Correlation between credit status and campaign outcomes
SELECT `default`, target_response, COUNT(*) AS total
FROM mcampaign_staging
GROUP BY 1, 2;

-- Analyzing the success rate of the campaign based on clients job
SELECT job, target_response, COUNT(*) AS total
FROM mcampaign_staging
GROUP BY 1, 2
ORDER BY target_response DESC, total DESC;

-- Correlation between number of contacts performed during this campaign and for this client with campaign's success
SELECT campaign, COUNT(*) AS total, 
SUM(CASE WHEN target_response = 'yes' THEN 1 ELSE 0 END) AS successful_subscriptions
FROM mcampaign_staging
GROUP BY campaign;

-- Are clients with higher balances and longer contact durations more likely to subscribe to term deposit products?
SELECT age, job, balance, duration, target_response
FROM mcampaign_staging
WHERE balance > 1000 AND duration > 100
ORDER BY balance DESC, duration DESC;



