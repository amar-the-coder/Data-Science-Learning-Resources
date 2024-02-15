SELECT * from insurance;

# Problem 1: What are the top 5 patients who claimed the highest insurance amounts?
SELECT * FROM (
			Select PatientID,
			DENSE_RANK() OVER(ORDER BY claim DESC) AS Patient_rank
			FROM insurance) T
WHERE t.Patient_rank <6;

# Problem 2: What is the average insurance claimed by patients based on the number of children they have?
SELECT distinct children,round(Avg(claim) OVER(PARTITION BY children),2) AS avg_on_num_of_child 
FROM insurance;

# Problem 3: What is the highest and lowest claimed amount by patients in each region?

SELECT 
DISTINCT region,
max(claim) OVER(PARTITION BY region) 'Max_of_region',
min(claim) OVER(PARTITION BY region) 'Min_of_region'
FROM insurance;

# Problem 4: What is the percentage of smokers in each age group?

-- Method 1 - using groupby
SELECT age, count(CASE WHEN smoker='YES' THEN 1 END )/count(*) * 100 AS Percentage_Smokers
FROM insurance
GROUP BY age
ORDER BY age;

-- method 2 Using win func
SELECT DISTINCT age,
count(CASE WHEN smoker='YES' THEN 1 END) Over (PARTITION BY age) / count(*) Over(PARTITION BY age) * 100 'percentage_of_smokers'
FROM insurance
ORDER BY age;

# problem 5: What is the difference between the claimed amount of each patient and the first claimed amount of that patient?

SELECT
    PatientID,
    claim,
    claim - FIRST_VALUE(claim) OVER (PARTITION BY PatientID) AS difference
FROM
    insurance;

# Problem 6: For each patient, calculate the difference between their claimed amount and the average claimed 
-- amount of patients with the same number of children.

SELECT 
PatientID, children, claim,round(Avg(claim) OVER(PARTITION BY children),2) 'avg_claim_child_wise_' ,abs(round(claim - round(AVG(claim) OVER(PARTITION BY children),2),2)) 'difference' 
FROM insurance;

# Problem 7: Show the patient with the highest BMI in each region and their respective rank.

SELECT PatientID,region,bmi,Rank_OF_Highest_Bmi FROM (
SELECT PatientID,Region,bmi,
DENSE_RANK() OVER(PARTITION BY region ORDER BY bmi DESC) 'Rank_OF_Highest_Bmi'
FROM insurance) t
WHERE Rank_OF_Highest_Bmi<2;

# Problem 8: Calculate the difference between the claimed amount of each patient
--  and the claimed amount of the patient who has the highest BMI in their region.

SELECT PatientID,region,bmi,claim,
max(claim) OVER (PARTITION BY region) 'max_claim_of_that_branch',
(claim- FIRST_VALUE(claim) OVER( PARTITION BY region ORDER BY bmi DESC)) 'Diff'
FROM insurance
ORDER BY PatientID;

# Problem 9: For each patient, calculate the difference in claim amount between the patient and the patient with the highest claim 
-- amount among patients with the same bmi and smoker status, within the same region. Return the result in descending order difference.

SELECT PatientID,region,round(bmi),smoker,claim,
MAX(claim) OVER (PARTITION BY region,smoker, round(bmi)) 'MAx_claim', 
round(claim-MAX(claim) OVER (PARTITION BY region,smoker,round(bmi)),2) 'Diff' FROM insurance;

# Problem 10: For each patient, find the maximum BMI value among their next three records (ordered by age).
SELECT
    PatientID,
    age,
    bmi,
    MAX(bmi) OVER (ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING) AS max_bmi_next_three
FROM insurance
ORDER BY
    PatientID,age;

# Problem 11: For each patient, find the rolling average of the last 2 claims.
SELECT PatientID,claim,
claim + lead(claim) OVER (ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING)/2 'Avg_of_claim'
FROM insurance;

# Problem 12: Find the first claimed insurance value for male and female patients, within each region order the data
--  by patient age in ascending order, and only include patients who are non-diabetic and have a bmi value between 25 and 30.

SELECT  
PatientID, region,gender, diabetic, bmi,
FIRST_VALUE(claim) OVER (PARTITION BY gender,region) 'first_claimed_value'
FROM insurance
WHERE bmi BETWEEN 25 and 30 and diabetic='No'
ORDER BY age
