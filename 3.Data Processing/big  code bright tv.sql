-- Databricks notebook source
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
WITH Base_viewership AS
(SELECT
COALESCE(UserID0, userid4) AS User_id,
FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg') AS RecordDate_SAST,
Channel2,
`Duration 2`
FROM brightdataset.viewers.viewership_info
),

Cleaned_viewership AS
(SELECT

User_id,
RecordDate_SAST,
TO_DATE(RecordDate_SAST) AS watch_date, 
DAYNAME(TO_DATE(RecordDate_SAST)) AS day_name,
MONTHNAME(TO_DATE(RecordDate_SAST)) AS month_name, 
YEAR(TO_DATE(RecordDate_SAST)) AS event_year, 
DAY(TO_DATE(RecordDate_SAST)) AS event_day, 
HOUR(RecordDate_SAST) AS Hour_of_day,

CASE
WHEN DAYNAME(TO_DATE(RecordDate_SAST)) IN ('Sat','Sun') THEN '02.weekend'
ELSE '01.weekday'
END AS day_classification,

DATE_FORMAT(RecordDate_SAST,'HH:mm:ss') AS Watch_time,
CASE
WHEN DATE_FORMAT(RecordDate_SAST,'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01.Midnight'
WHEN DATE_FORMAT(RecordDate_SAST,'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02.Morning'
WHEN DATE_FORMAT(RecordDate_SAST,'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03.Afternoon'
WHEN DATE_FORMAT(RecordDate_SAST,'HH:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
END AS Time_of_day,

`Duration 2`,
DATE_FORMAT(`Duration 2`,'HH:mm:ss') AS Duration,
(
HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 +
MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 +
SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
) AS Duration_seconds,
CASE
WHEN (HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 + MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 + SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))) BETWEEN 300 AND 1800 THEN '01. Low Usage'
WHEN (HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 + MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 + SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))) BETWEEN 1801 AND 3599 THEN '02. Medium Usage'
WHEN (HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 + MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 + SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))) >= 3600 THEN '03. High Usage'
ELSE '04. No Usage'
END AS Screen_time_bucket,
CASE
WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','Supersport Live Events','DStv Events') THEN 'Live Events'
ELSE Channel2
END AS Tv_channel
FROM Base_viewership
)
SELECT * FROM Cleaned_viewership;
