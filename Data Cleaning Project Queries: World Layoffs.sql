
-----------------------------------
-- Data Cleaning with SQL Queries--
-----------------------------------
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT * 
FROM world_layoffs.layoffs;


-- CREATE A STAGING TABLE (In case something happen, we still have table with raw data)
 
CREATE TABLE layoffs_staging LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;


-- 4 Steps that will be taken
-- 1. Check for the duplicates and removing them
-- 2. Standardizing the data and fix some errors
-- 3. Look at the null or blank values and see what we can do
-- 4. Removing any column and rows that aren't necessary


-- 1. Check and Removing Duplicates 

SELECT *,
	ROW_NUMBER() OVER(
			PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS Row_Num
FROM layoffs_staging;

WITH duplicate_cte AS
(
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
	FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE Row_Num > 1;

SELECT * FROM layoffs_staging
WHERE company = 'Casper';


-- crate second layoffs_staging table to delete the dupicates by deleting the data where row numbers are greater than 2

CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

DELETE FROM layoffs_staging2 
WHERE row_num > 1;



-- 2. Standardizing Data (Finding the issue with the data and then fixing it)

SELECT * FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT * FROM layoffs_staging2;

SELECT DISTINCT country
FROM layoffs_staging2;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM  layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT  `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` LIKE '%/%/%';

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;




-- 3. Working with null by populating the blank or null values if possible

SELECT  *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT  t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company
AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;





-- 4. Deleting or removing any column and rows that aren't necessary

SELECT  *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;



