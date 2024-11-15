

-- Exploratory Data Analysis




SELECT * FROM layoffs_staging2;




-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;


-- Look for companies with the biggest single layoffs

SELECT company, MAX(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 5;

-- Look for companies with the biggest total layoffs

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


-- by industry

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- by country

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- by year

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- by stage

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


SELECT * FROM layoffs_staging2;


-- Rolling Total of Layoffs Per Month


SELECT SUBSTRING(date,1,7) AS `Month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month` ASC;


-- now use it in a CTE so we can query off of it


WITH Rolling_Total AS 
(
SELECT SUBSTRING(date,1,7) AS `Month`, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month` ASC
)
SELECT `Month`, total_layoffs, SUM(total_layoffs) OVER (ORDER BY `Month` ASC) as rolling_total_layoffs
FROM Rolling_Total
ORDER BY 1 ASC;


-- Total layoffs rank per year


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

WITH Company_Year(company, Years, total_laid_off) AS (
  SELECT 
    company, 
    YEAR(`date`) AS Years, 
    SUM(total_laid_off) 
  FROM 
    layoffs_staging2 
  GROUP BY company, Years 
  ORDER BY 3 DESC
),
Company_Rank AS (
  SELECT *, 
    DENSE_RANK() OVER(
      PARTITION BY Years ORDER BY total_laid_off DESC
    ) AS Ranking 
  FROM 
    Company_Year 
  WHERE 
    Years IS NOT NULL 
  ORDER BY 
    Ranking ASC
)
SELECT * 
FROM Company_Rank
WHERE ranking <= 5;








