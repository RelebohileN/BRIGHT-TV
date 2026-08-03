-- Databricks notebook source

---viewing the whole table
SELECT * FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles` LIMIT 10;

---checking duplicates
SELECT UserID,
COUNT (*)AS DUPLICATE_COUNT
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
GROUP BY UserID
HAVING COUNT (*)>1;

---checking how many rows exist in my table 
SELECT COUNT(*) AS number_of_rows
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

---checking the number of unique subcribers
SELECT COUNT(DISTINCT UserID) AS number_of_subs
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

---checking missing values in the UserID column
SELECT COUNT (*) AS cnt
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
WHERE UserID is NULL;

---checking for unique values in the UserID column
SELECT DISTINCT UserID
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

--- gender checks

SELECT DISTINCT gender
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

SELECT COUNT(*)
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
WHERE gender = '';

SELECT
COUNT(DISTINCT UserID) AS subs,
CASE 
WHEN gender = '' THEN 'NONE'
ELSE gender
END AS Gender 
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
GROUP BY Gender;

-- Race checks

SELECT COUNT(*)AS `num-rows`
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
WHERE Race IS NULL;

SELECT DISTINCT Race
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

SELECT DISTINCT
  CASE 
  WHEN Race ='other' THEN 'None'
  WHEN Race='' THEN 'None'
  ELSE Race
  END AS Race
  FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

-- Province checks
   
   SELECT DISTINCT Province
   FROM`brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

   SELECT DISTINCT
     CASE
     WHEN Province =''THEN 'Uncategorized'
     WHEN Province = 'None' THEN 'Uncategorized'
     ELSE Province
     END AS Region
     FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

-- Age checks

     SELECT MIN (Age) AS min_age,-- = 0
     MAX (Age) AS max_age-- = 114
     FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

     SELECT COUNT (*) AS cnt
     FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
     WHERE age IS NULL;

WITH user_profiles AS(
  SELECT UserID,
  CASE  
  WHEN Gender = 'None' THEN 'unknown'
  WHEN Gender = '' THEN 'unknown'
  WHEN Gender IS NULL THEN 'unknown'
  ELSE Gender
  END AS Sex,

  CASE
  WHEN Race = 'None' THEN 'unknown'
  WHEN Race = '' THEN 'unknown'
  WHEN Race IS NULL THEN 'unknown'
  ELSE Race
  END AS Ethnicity,

  CASE 
  WHEN Age = 0 THEN 'infant'
  WHEN Age BETWEEN 1 AND 12 THEN 'kids'
  WHEN Age BETWEEN 13 AND 17 THEN 'youth'
  WHEN Age BETWEEN 18 AND 35 THEN 'young adults'
  WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
  WHEN Age > 50 AND Age <= 60 THEN 'Elder'
  WHEN Age > 60 THEN 'Pensioner'
  END AS Age_group,

  CASE 
  WHEN Province = 'None' THEN 'Uncategorized'
  WHEN Province = ' ' THEN 'Uncategorized'
  WHEN Province = 'other' THEN 'Uncategorized'
  WHEN Province IS NULL THEN 'Uncategorized'
  ELSE Province
  END AS Regions,

  CASE 
  WHEN Email IS NOT NULL AND Email <> '' THEN 1
  ELSE 0
  END AS Email_flag,

  CASE 
  WHEN `Social Media Handle` IS NOT NULL AND `Social Media Handle` <> '' THEN 1
  ELSE 0
  END AS Social_media_handle_flag
  FROM brightdataset.viewers.bright_tv_dataset_userprofiles
)
SELECT * FROM user_profiles;



-- COMMAND ----------


