-- We create a dabase
CREATE DATABASE IF NOT EXISTS data_sets_clean;

-- Select the dabase we are going to use
USE data_sets_clean;

-- We create a copy of the dataset
CREATE TABLE enterprise_cleaning AS
SELECT * FROM enterprise;

SELECT * FROM enterprise_cleaning;

-- We rename the columns

ALTER TABLE enterprise_cleaning RENAME COLUMN `ï»¿Id?empleado` TO `employee_ID`;
ALTER TABLE enterprise_cleaning RENAME COLUMN `Name` TO `name`;
ALTER TABLE enterprise_cleaning RENAME COLUMN `Apellido` TO `last_name`;
ALTER TABLE enterprise_cleaning RENAME COLUMN `gÃ©nero` TO `gender`;
ALTER TABLE enterprise_cleaning RENAME COLUMN `star_date` TO `start_date`;

-- We check for duplicates
SELECT employee_ID, COUNT(*)
FROM enterprise_cleaning
GROUP BY employee_ID;

-- Create a temporary table containing no duplicates
CREATE TEMPORARY TABLE tem_clean AS
SELECT DISTINCT * FROM enterprise_cleaning;

-- We check the number of rows in the two tables
SELECT COUNT(*) AS ORIGINAL FROM enterprise_cleaning;
SELECT COUNT(*) AS DUPLI FROM tem_clean;

SELECT * FROM enter_clean_dupli;

-- Rename the main cleaning table
RENAME TABLE enterprise_cleaning TO enterprise_cleaning_dupli;

-- Create a new table without duplicates
CREATE TABLE enterprise_cleaning AS
SELECT DISTINCT * FROM enterprise_cleaning_dupli;

-- We check the number of rows
SELECT COUNT(*) AS 'new' FROM enterprise_cleaning;
SELECT COUNT(*) AS DUPLI FROM enterprise_cleaning_dupli;

-- Delete the table with duplicates
DROP TABLE enterprise_cleaning_dupli;

-- We check if there are spaces
SELECT name, last_name
FROM enterprise_cleaning
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0 OR LENGTH(last_name) - LENGTH(TRIM(last_name)) > 0;

SELECT * FROM enterprise_cleaning;

-- Remove the spaces
UPDATE enterprise_cleaning
SET name = TRIM(name);
UPDATE enterprise_cleaning
SET last_name = TRIM(last_name);

-- Date format
UPDATE enterprise_cleaning
SET birth_date = STR_TO_DATE(birth_date, '%m/%d/%Y');

UPDATE enterprise_cleaning
SET start_date = STR_TO_DATE(start_date, '%m/%d/%Y');

ALTER TABLE enterprise_cleaning
MODIFY COLUMN birth_date DATE;

ALTER TABLE enterprise_cleaning
MODIFY COLUMN `start_date` DATE;

-- Check if there are two or more spaces in a string in row
SELECT area FROM enterprise_cleaning 
WHERE area REGEXP '\\s{2,}';
-- Searches for and changes the spaces greater than one and replaces them with a one
UPDATE enterprise_cleaning SET area = TRIM(REGEXP_REPLACE(area, '\\s+', ' ')); 

SELECT * FROM enterprise_cleaning;

-- Standardazing values
-- area
SELECT area 
FROM enterprise_cleaning
GROUP BY area 
ORDER BY area ASC;

-- gender
SELECT gender,  
CASE
    WHEN gender = 'hombre' THEN 'Male'
    WHEN gender = 'mujer' THEN 'Female'
    ELSE 'Other'
END as gender1
FROM enterprise_cleaning;

UPDATE enterprise_cleaning
SET gender = CASE
    WHEN gender = 'hombre' THEN 'Male'
    WHEN gender = 'mujer' THEN 'Female'
    ELSE 'Other'
END;

-- I make a mistake, the previous query was made twice, so all the values of the 'gender' coulmn are 'other'
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* --
ALTER TABLE enterprise_cleaning DROP COLUMN gender;
ALTER TABLE enterprise_cleaning ADD COLUMN gender text;

SELECT ec.employee_ID, ec.gender AS current_gender, e.`gÃ©nero` AS new_gender
FROM enterprise_cleaning AS ec
JOIN enterprise AS e ON ec.employee_ID = e.`ï»¿Id?empleado`;

UPDATE enterprise_cleaning AS ec
JOIN enterprise AS e ON ec.employee_ID = e.`ï»¿Id?empleado`
SET ec.gender = e.`gÃ©nero`;

SELECT ec.employee_ID, ec.gender, e.`gÃ©nero`, e.`ï»¿Id?empleado`
FROM enterprise_cleaning AS ec
JOIN enterprise AS e ON ec.employee_ID = e.`ï»¿Id?empleado`;

SELECT * FROM enterprise_cleaning;
SELECT * FROM enterprise;
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* --
-- salary

SELECT salary,  CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',', '')) AS DECIMAL(15, 2)) AS salary_clean
FROM enterprise_cleaning;

UPDATE enterprise_cleaning SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',', '')) AS DECIMAL(15, 2));

ALTER TABLE enterprise_cleaning
MODIFY COLUMN `salary` INT;

-- finish_date
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d') AS fd 
FROM enterprise_cleaning; -- Separate only the date
SELECT finish_date, date_format(finish_date, '%H:%i:%s') AS hour_stamp 
FROM enterprise_cleaning; -- Separate only the hour

 Select finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')  AS `format` 
 FROM enterprise_cleaning;
 
 UPDATE enterprise_cleaning
	SET finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC') 
	WHERE finish_date <> '';

ALTER TABLE enterprise_cleaning ADD COLUMN `date_part` DATE;
ALTER TABLE enterprise_cleaning ADD COLUMN `time_part` TIME;

UPDATE enterprise_cleaning
SET date_part = DATE(finish_date),
    time_part = TIME(finish_date)
WHERE finish_date IS NOT NULL AND finish_date <> '';

SELECT *
FROM enterprise_cleaning;

-- I don't see the time table useful, so I will remove the column

ALTER TABLE enterprise_cleaning DROP COLUMN `finish_date`;
ALTER TABLE enterprise_cleaning RENAME COLUMN `date_part` TO finish_date;
ALTER TABLE enterprise_cleaning RENAME COLUMN `time_part` TO finish_time;

-- Also the column `promotion_date`
ALTER TABLE enterprise_cleaning DROP COLUMN `promotion_date`;


-- type

DESCRIBE enterprise_cleaning;
ALTER TABLE enterprise_cleaning MODIFY COLUMN `type` TEXT;

SELECT `type`,  
CASE
    WHEN `type` = '0' THEN 'Hybrid'
    WHEN `type` = '1' THEN 'Remote'
    ELSE 'Other'
END as `type_1`
FROM enterprise_cleaning;

UPDATE enterprise_cleaning
SET `type`= CASE
    WHEN `type` = 0 THEN 'Hybrid'
    WHEN `type` = 1 THEN 'Remote'
    ELSE 'Other'
END;

SELECT *
FROM enterprise_cleaning;

-- New columns (age, email)

ALTER TABLE enterprise_cleaning ADD COLUMN `age` INT;
ALTER TABLE enterprise_cleaning ADD COLUMN `email` VARCHAR(100);

-- The data were created randomly, so there are inconsistencies in the ages and the start_date.

SELECT name, birth_date, start_date, TIMESTAMPDIFF(YEAR, birth_date, start_date) AS edad_de_ingreso
FROM enterprise_cleaning;

UPDATE enterprise_cleaning
SET age = timestampdiff(YEAR, birth_date, CURDATE()); 

SELECT CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@example.com') as email FROM enterprise_cleaning;

UPDATE enterprise_cleaning 
SET email = CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@example.com'); 

SELECT *
FROM enterprise_cleaning;

-- Select the columns we want to use for our data analysis and export them

SELECT employee_ID, name, last_name, area, salary, gender, age, type, finish_time, email FROM enterprise_cleaning
WHERE finish_date <= CURDATE() OR finish_date IS NULL
ORDER BY area, Name;
