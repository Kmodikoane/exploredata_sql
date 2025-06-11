-- view the table in question
SELECT *
FROM employee;
/* commence the data cleaning process
	by assigning employees the company emails */
SELECT
	concat(lower(replace(employee_name," ",".")),
    "@ndogowater.gov") AS new_email
FROM employee;
-- set and update changes, set sql update to = 0, if query oesn't run
UPDATE employee
SET email = concat(lower(replace(employee_name," ",".")),
			"@ndogowater.gov");
SELECT
	length(phone_number) -- check that the phone number is 12 characters long
FROM
	employee;
UPDATE employee
 SET phone_number = trim(phone_number); -- remove the whitespace from the phone column
SELECT -- count how many employees live in each town using the employee table
	town_name,
    count(employee_name) AS num_of_employee
FROM employee
GROUP BY town_name;
SELECT *
FROM visits;
/* count the number of visits each empoyee conducted, 
	order it from highest to lowest and find who are the top 3 performer */
SELECT
	assigned_employee_id,
	sum(visit_count) AS number_of_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY number_of_visits DESC
LIMIT 3;
SELECT *
FROM employee
WHERE assigned_employee_id IN (1,30,42);-- Get the top 3 performers contact details in the employee table
SELECT *
FROM location;

SELECT
	town_name,
	count(location_id) AS records_per_town -- count the nunmber of records in each town
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC;
SELECT
	province_name,
	count(location_id) AS records_per_province
FROM location
GROUP BY province_name
ORDER BY records_per_province DESC;
SELECT
	town_name,
    province_name,
	count(location_id) AS records_per_town
FROM location
GROUP BY town_name, province_name
ORDER BY province_name, records_per_town DESC;
-- count how many records ae there per location type
SELECT
	location_type,
	count(location_id)
FROM location
GROUP BY location_type;
-- calculate the percentage of water sources per location type
SELECT 
	round(15910/(15910 + 23740)*100) AS urban_percentage,
    ceiling((23470/(15910 + 23740)*100)) AS rural_percentage;

-- Exploratory data analysis
SELECT *
FROM water_source;
SELECT 
	sum(number_of_people_served) AS total_people_served
 FROM water_source;
SELECT -- -- How many wells, taps and rivers are there?
	type_of_water_source,
	count(type_of_water_source) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source;
SELECT 
	type_of_water_source,
	count(type_of_water_source) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source;
-- find the average number of people served by each type of water source?
SELECT
	type_of_water_source,
	round(avg(number_of_people_served)) AS ave_people_per_source
FROM water_source
GROUP BY type_of_water_source;
/* find the number of people served by each source 
and rank from highest to lowest */
SELECT
	type_of_water_source,
	SUM(number_of_people_served) AS people_served, 
    RANK() OVER(
			ORDER BY SUM(number_of_people_served)DESC)  AS rank_by_population
FROM water_source
WHERE type_of_water_source <> "tap_in_home"
GROUP BY type_of_water_source;
SELECT source_id, -- rank the popuation served by each water source in desc order
  type_of_water_source,
  number_of_people_served,
  RANK() OVER (PARTITION BY type_of_water_source 
		ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source
WHERE type_of_water_source <> "tap_in_home";
/* the benefit of a dense rank, will water source types 
	serving the same number of will be given the same priority rank
    making it easer to identify water_source_types with equal importance */
SELECT source_id,
  type_of_water_source,
  number_of_people_served,
  DENSE_RANK() OVER (PARTITION BY type_of_water_source 
		ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('river','shared_tap','river');

SELECT
	*
FROM visits;
SELECT -- How long did the survey take?
	datediff(max(time_of_record), min(time_of_record)) AS survey_duration
FROM visits;
SELECT -- What is the average total queue time for water?
   round(nullif(avg(time_in_queue),0)) AS ave_time_queue
FROM visits;
SELECT dayname(time_of_record) AS day_of_week, -- What is the average queue time on different days?
       ROUND(AVG(NULLIF(time_in_queue,0))) AS ave_time_queue
FROM visits
GROUP BY day_of_week;
SELECT round(avg(nullif(time_in_queue,0))) -- What time is the average time spent in queuing for water
FROM visits;
SELECT -- communicate all this time reated info into a table
	dayname(time_of_record) AS day_of_week,
    datediff(max(time_of_record), min(time_of_record)) AS survey_duration,
    ROUND(AVG(NULLIF(time_in_queue,0))) AS ave_time_queue
FROM visits
GROUP BY dayname(time_of_record);
SELECT -- Average hourly queue each day of the week (pivot table)
	time_format(time(time_of_record), "%H") AS Hour_of_day,
	round(nullif(avg(time_in_queue),0)) AS ave_time_queue
FROM visits
GROUP BY hour_of_day
ORDER BY hour_of_day DESC;

-- average queue time for each day
SELECT
	time_format(time(time_of_record), "%H") AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
-- Thursday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
-- Friday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,
-- Saturday 
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;

-- create a pivot table
DROP TABLE IF EXISTS md_water_services.weekly_ave_queue_time_pivot;
CREATE TABLE md_water_services.weekly_ave_queue_time_pivot AS
SELECT
	TIME_FORMAT(TIME(time_of_record), "%H") AS hour_of_day,
-- Sunday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' 
	THEN time_in_queue
	ELSE NULL END),0) AS Sunday,
-- Monday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' 
	THEN time_in_queue
	ELSE NULL END),0) AS Monday,
-- Tuesday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' 
	THEN time_in_queue
	ELSE NULL END),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE WHEN DAYNAME(time_of_record) = 'Wednesday' 
	THEN time_in_queue
	ELSE NULL END),0) AS Wednesday,
-- Thursday
ROUND(AVG(
CASE WHEN DAYNAME(time_of_record) = 'Thursday' 
	THEN time_in_queue
	ELSE NULL END),0) AS Thursday,
-- Friday
ROUND(AVG(
CASE WHEN DAYNAME(time_of_record) = 'Friday' 
	THEN time_in_queue
	ELSE NULL END),0) AS Friday,
-- Saturday 
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL END),0) AS Saturday
FROM visits
WHERE time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY hour_of_day
ORDER BY hour_of_day;