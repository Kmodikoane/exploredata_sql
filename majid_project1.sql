-- Task 1: Get to know our data
-- Show all of the tables
SHOW TABLES;

SELECT
	*
FROM 
	data_dictionary;

SELECT
	*
FROM 
	location;
    
SELECT
	*
FROM 
	visits;
    
-- Task 2: Dive into the water sources
-- explore the water source table
SELECT
	*
FROM
	water_source;
   
-- Determine the different types of water sources in the 
SELECT DISTINCT
	type_of_water_source
FROM 
	water_source;
  
-- Task 3: Unpack the visits to water sources
SELECT 
	*
FROM 
	visits
LIMIT 1000;

-- Fnd water sources where users waited more than 500hours in queuee
SELECT 
    *
FROM
    visits
WHERE
    time_in_queue > 500;
    
-- what kind of water sources have people in queues 500hour?
SELECT 
	*
FROM 
	water_source;
    
/* copy source ids from visits table
where time_queue > 500 mins
to find what types of ater sources have queues > 500 mins */ 
SELECT 
	*
FROM 
    water_source
WHERE 
    source_id 
IN ('SoRu35083224',
	'SoKo33124224',
	'KiRu26095224',
	'KiRu29348224',
	'HaRu17375224',
	'AmBe11134224',
	'AkRu08167224',
	'KiRu25391224',
	'AkRu04807224',
	'KiRu30657224',
	'KiRu27098224',
	'HaRu19412224',
	'AkRu07801224',
	'KiRu25672224',
	'SoRu36934224',
	'KiZu31252224',
	'AmAs10315224',
	'AkRu06817224',
	'KiRu25801224'
	)
;
-- therefore shared  taps have queues where queue times are > 500 mins
    
-- explore water quality table
SELECT 
	*
FROM
	water_quality
WHERE 
	subjective_quality_score = 10
AND
	visit_count = 2;
	
SELECT 
	*
FROM 
	well_pollution;
	
SELECT 
	*
FROM 
	well_pollution
WHERE 
	results = 'Clean' AND biological > 0.01;

Set sql_safe_updates =0;
    
-- Task 5: Investigate any pollution issues
-- Does the well description match the biological value 
SELECT 
	*
FROM 
	well_pollution
WHERE description LIKE "Clean%" 
AND biological > 0.01;

UPDATE 
	well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution
SET 
	results = 'Contaminated: Biological'
WHERE
	biological > 0.01 and results = 'Clean';

/* check if data is clear of errors.
	Check if there records that return a clean result for biological reading greater than 0.01
    If any records are returned then those records are inccorrect*/
SELECT
*
FROM 
	well_pollution
WHERE results = 'Clean'
AND biological > 0.01
;