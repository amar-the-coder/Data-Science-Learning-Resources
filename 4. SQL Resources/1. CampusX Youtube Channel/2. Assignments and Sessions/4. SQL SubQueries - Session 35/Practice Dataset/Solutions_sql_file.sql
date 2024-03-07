## Problem 1
## Display the names of athletes who won a gold medal in the 2008 Olympics and
-- whose height is greater than the average height of all athletes in the 2008 Olympics.

SELECT name,medal,year,Height FROM olympics 
WHERE Year = 2008 and Medal = 'Gold' and (name,year,height) IN (SELECT Name, Year, Height FROM olympics
WHERE year = 2008 and Height > (SELECT avg(height) FROM olympics 
WHERE year = 2008)); 


## Problem 2
-- Display the names of athletes who won a medal in the sport of basketball in the 2016 Olympics and
 -- whose weight is less than the average weight of all athletes who won a medal in the 2016 Olympics.
 
 SELECT name,medal, sport,weight,year year FROM olympics
 WHERE year = 2016 and Medal = 'Gold' and Sport = 'basketball' and (name, medal, Weight,sport,year)IN
(SELECT name, medal, Weight,sport,year FROM olympics
 WHERE medal IN ('gold','silver','bronze') and year = 2016 and Weight < (SELECT avg(Weight) 
 FROM olympics WHERE year = 2016 and medal IN ('gold','silver','bronze'))
);

## Problem 3 
## Display the names of all athletes who have won a medal in the sport of swimming in both the 2008 and 2016 Olympics.
SELECT name,medal,sport,year FROM olympics
WHERE Year in (2008, 2016) and sport = 'swimming' and Medal IN ('gold','silver','bronze');

-- ------------------------ OR --------------------------------------------------------------
SELECT name, medal, sport, year FROM olympics 
WHERE Medal IN ('gold','silver','bronze') and Year IN (2016,2008)  and Name IN (
					SELECT name FROM olympics 
					Where sport='Swimming' and Year In (2008,2016));
                    

## Problem 4
## Display the names of all countries that have won more than 50 medals in a single year.
SELECT  DISTINCT(country) FROM olympics 
WHERE country IN (
		SELECT country FROM olympics
		WHERE Medal IN ('gold','silver','bronze')
		GROUP BY year,country
		HAVING COUNT(*)>50
		ORDER BY year ASC, Country ASC);
        
## Probelem 5:
## Display the names of all athletes who have won medals in more than one sport in the same year.
SELECT name From (
SELECT name,Year,Count(DISTINCT Sport) SportCount FROM olympics
WHERE Medal IN ('gold','silver','bronze')
GROUP BY name,year) as T1
WHERE SportCount > 1;

## Problem 6
## What is the average weight difference between male and female athletes in the Olympics who have won a medal in the same event?
SELECT ABS(AVG(Male.weight)-AVG(Female.Weight)) AS WEIGHT_DIFF FROM
(SELECT Name,Event,Weight FROM olympics
WHERE Medal IN ('Gold','Silver','Bronze')
AND Sex = 'M') AS MALE
JOIN 
(SELECT Name,Event,Weight FROM olympics
WHERE Medal IN ('Gold','Silver','Bronze')
AND Sex = 'F') AS FEMALE
ON MALE.event = FEMALE.event;


###################################################################################################################################

## Problem 7
## How many patients have claimed more than the average claim amount for patients who are smokers 
-- and have at least one child, and belong to the southeast region?

SELECT Count(*) Number_of_Patients FROM insurance_data
WHERE claim> (SELECT avg(claim) FROM insurance_data WHERE smoker= 'Yes' AND children >= 1 AND region = 'southeast');

## Problem 8:
## How many patients have claimed more than the average claim amount for patients who are not smokers and have a 
-- BMI greater than the average BMI for patients who have at least one child?

SELECT count(*) AS Count_of_Patients FROM insurance_data
WHERE claim > (
	SELECT round(avg(claim),2) Average_claim FROM insurance_data
	WHERE smoker='No' and
	BMI > (
				SELECT round(Avg(Bmi),2) Average_BMI FROM insurance_data
				WHERE children >=1));

## Problem 9
## How many patients have claimed more than the average claim amount for patients who have a BMI greater than the average BMI for 
-- patients who are diabetic, have at least one child, and are from the southwest region?

SELECT Count(*) AS Count_of_patients FROM insurance_data 
WHERE claim > (
SELECT round(avg(claim),2) FROM insurance_data
WHERE bmi > (
SELECT round(Avg(bmi),2) FROM insurance_data
WHERE diabetic= 'Yes' and children>=1 and region ='southwest'
));

## Problem 10:
## What is the difference in the average claim amount between patients who are smokers and patients who are non-smokers, 
-- and have the same BMI and number of children?

SELECT round(avg(abs(SMOKER.claim-NON_SMOKER.claim)),2) AS Claim_diff FROM (
(SELECT bmi,children,claim FROM insurance_data
WHERE smoker = 'Yes') AS SMOKER
JOIN
(SELECT bmi,children,claim FROM insurance_data
WHERE smoker = 'No') AS NON_SMOKER 
ON SMOKER.bmi = NON_SMOKER.bmi AND SMOKER.children = NON_SMOKER.Children )
