select * from insurance_data;

-- -- Practice Questions -- --

-- 1. Show records of 'male' patient from 'southwest' region.

SELECT * FROM insurance_data 
WHERE gender = 'male' and region = 'southeast';

-- 2. Show all records having bmi in range 30 to 45 both inclusive.

SELECT * FROM insurance_data 
WHERE bmi >=30 and bmi <=45 ;
-- -- -- or 
SELECT * FROM insurance_data
WHERE bmi BETWEEN 30 and 45;

-- 3. Show minimum and maximum bloodpressure of diabetic patient who smokes. Make column names as MinBP and MaxBP respectively.
SELECT MAX(bloodpressure) AS MaxBP, MIN(bloodpressure) as MinBP 
FROM insurance_data
WHERE smoker = 'Yes';

-- 4. Find no of unique patients who are not from southwest region.
SELECT count(*) As Count_of_Patients 
FROM insurance_data
WHERE region NOT IN ('southeast');

-- 5.Total claim amount from male smoker.
SELECT round(SUM(claim),1) AS Total_Claim_Amount 
FROM insurance_data
WHERE gender = 'male' and smoker='Yes';

-- 6. Select all records of south region.
SELECT * 
FROM insurance_data
WHERE region LIKE 'south%';

-- 7.No of patient having normal blood pressure. Normal range[90-120]
SELECT count(*) AS Count_of_Patients_with_normal_BP
FROM insurance_data
WHERE bloodpressure BETWEEN 90 and 120;

-- 8. No of pateint belo 17 years of age having normal blood pressure as per below formula -
-- BP normal range = 80+(age in years × 2) to 100 + (age in years × 2)
-- Note: Formula taken just for practice, don't take in real sense.

SELECT * 
FROM insurance_data
WHERE age < 17; --  and bloodpressure BETWEEN (80+(age*2)) and (100+(age*2));
 
-- 9.What is the average claim amount for non-smoking female patients who are diabetes

SELECT round(avg(claim),2) AS Average_Claim_Amount
FROM insurance_data
WHERE gender="female" and smoker= "No" and diabetic = 'Yes';

-- 10. Write a SQL query to update the claim amount for the patient with PatientID = 1234 to 5000.
UPDATE insurance_data
SET Claim = 5000
WHERE PatientID = 1234;

## for checking the update

Select * from insurance_data
WHERE PatientID = 1234;

-- 11. Write a SQL query to delete all records for patients who are smokers and have no children.
DELETE FROM insurance_data
WHERE smoker='Yes' and children='0'

