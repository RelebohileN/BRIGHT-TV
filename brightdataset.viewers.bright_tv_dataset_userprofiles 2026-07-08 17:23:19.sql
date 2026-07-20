-- Databricks notebook source

SELECT * FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles` LIMIT 10;

SELECT UserID,
COUNT (*)AS DUPLICATE_COUNT
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
GROUP BY UserID
HAVING COUNT (*)>1;

SELECT COUNT(*) AS number_of_rows
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

SELECT COUNT(DISTINCT UserID) AS number_of_subs
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

SELECT COUNT (*) AS cnt
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
WHERE UserID is NULL;

SELECT DISTINCT UserID
FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`;

-- GENDER CHECKS

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

      WITH user_profiles AS (
        SELECT UserID,
        CASE
        WHEN Province = '' THEN 'Uncategorized'
        WHEN Province = 'None' THEN 'Uncategorized'
        ELSE Province 
        END AS Region,
          
          age,
          CASE
          WHEN age = 0 THEN 'Infants'
          WHEN age BETWEEN 1 AND 12 THEN 'kids'
          WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
          WHEN age BETWEEN 20 AND 35 THEN 'Youth'
          WHEN age BETWEEN 36 AND 50 THEN 'Adult'
          WHEN age BETWEEN 51 AND 65 THEN 'Elder'
          WHEN age >65 THEN 'Pensioner'
          END AS age_groups,

          CASE
          WHEN Email IS NOT NULL OR Email=''OR Email NOT IN ('None')
           THEN 1
          ELSE 0
          END AS email_flag,

          CASE
          WHEN `Social Media Handle` IS NOT NULL OR `Social Media Handle`='' OR `Social Media Handle` NOT IN ('None') THEN 1
          ELSE 0
          END AS Sm_flag,

          CASE 
          WHEN Race = 'other' THEN 'None'
          WHEN Race ='' THEN 'None'
          ELSE Race 
          END AS Race,

          CASE 
          WHEN gender = '' THEN 'None'
          ELSE gender 
          END AS Gender

          FROM `brightdataset`.`viewers`.`bright_tv_dataset_userprofiles`
     ),

     viewership AS(
      SELECT COALESCE(UserID0,userid4) AS userid,
      DATE_FORMAT(RecordDate2,'yyyyMM') AS month_id,
      TO_DATE(RecordDate2) AS watch_date,
      -- TIME (RecordDate2) AS watch_time,
      DATE_FORMAT(RecordDate2, 'DD') AS day_of_week,
      DAYNAME (RecordDate2) AS day_name,
      
      CASE 
      WHEN day_name IN ('Sat','Sun') THEN 'weekend'
      ELSE 'weekday'
      END AS day_classification,

      MONTHNAME (RecordDate2) AS month_name, 

      CASE
      WHEN Channel2 IN ('SawSee','Sawsee')THEN 'SawSee'
      WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
      ELSE Channel2
      END AS TV_channel,

      DATE_FORMAT(RecordDate2,'HH:mm:ss') AS watch_time,
      CASE
      WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01.Midnight'
      WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02.Morning'
      WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03.Afternoon'
      WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04.Evening'
      END AS time_of_day,

      DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,
      CASE
      WHEN duration BETWEEN '00:05:00' AND '03:30:00' THEN '01.Low Usage:<30 min'
      WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02.Med Usage:<60 min'
      ELSE '04.No Usage'
      END as screen_time_bucket,

      HOUR(RecordDate2) AS hour_of_day

      FROM `brightdataset`.`viewers`.`viewership_info`
      )
      SELECT
      COALESCE(A.userid,B.userid) AS sub_id,
      month_id,
      watch_date,
      day_of_week,
      day_name,
      TV_channel,
      time_of_day,
      hour_of_day,
      screen_time_bucket,
      --user_flag,
      duration,
      Region,
      age_groups,
      email_flag,
      Sm_flag,
      Race,
      Gender
      FROM viewership AS A
      LEFT JOIN user_profiles AS B
      ON A.userid = B.userid;


      


     

   

