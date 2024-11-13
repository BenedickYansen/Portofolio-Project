SELECT * FROM london_merged;

-----------------------------------
-- create staging table
CREATE TABLE london_merged_staging
like london_merged;

INSERT INTO london_merged_staging
SELECT * FROM london_merged;

SELECT * FROM london_merged_staging;

------------------------------------
-- standardizing data

DESCRIBE london_merged_staging;

ALTER TABLE london_merged_staging
MODIFY COLUMN t1 float;

ALTER TABLE london_merged_staging
MODIFY COLUMN t2 float;

ALTER TABLE london_merged_staging
MODIFY COLUMN hum float;

ALTER TABLE london_merged_staging
MODIFY COLUMN wind_speed float;

ALTER TABLE london_merged_staging
MODIFY COLUMN weather_code float;

ALTER TABLE london_merged_staging
MODIFY COLUMN is_holiday float;

ALTER TABLE london_merged_staging
MODIFY COLUMN is_weekend float;

ALTER TABLE london_merged_staging
MODIFY COLUMN season float;

-------------------------------------------------------
-- count the unique value in the weather_code column

SELECT * FROM london_merged_staging;

SELECT weather_code, COUNT(weather_code) AS unique_value
FROM london_merged_staging
GROUP BY weather_code
ORDER BY 1;

-------------------------------------------------------
-- count the unique value in the season column

SELECT season, COUNT(season) AS unique_value
FROM london_merged_staging
GROUP BY season
ORDER BY 1;

--------------------------------------------------------------
-- Mapping the values in the season and weather_code column

SELECT 
    timestamp AS time,
    cnt AS count,
    CAST(t1 AS DECIMAL(10,1)) AS temp_real_C,
    CAST(T2 AS DECIMAL(10,1)) AS temp_feels_like_C,
    CAST(hum/100 AS DECIMAL(10,3)) AS Humidity_Percentage,
    CAST(wind_speed AS DECIMAL(10,1)) AS wind_speed_kph,
    CASE
        WHEN weather_code = 1.0 THEN 'Clear'
        WHEN weather_code = 2.0 THEN 'Scattered clouds'
        WHEN weather_code = 3.0 THEN 'Broken clouds'
        WHEN weather_code = 4.0 THEN 'Cloudy'
        WHEN weather_code = 7.0 THEN 'Rain'
        WHEN weather_code = 10.0 THEN 'Rain with thunderstorm'
        WHEN weather_code = 26.0 THEN 'Snowfall'
    END AS weather_mapped,
    is_holiday,
    is_weekend,
    CASE
        WHEN season = 0.0 THEN 'spring'
        WHEN season = 1.0 THEN 'summer'
        WHEN season = 2.0 THEN 'autumn'
        WHEN season = 3.0 THEN 'winter'
    END AS season_mapped
FROM
    london_merged_staging;

    



