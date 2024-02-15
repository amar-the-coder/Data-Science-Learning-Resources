-- Window Function Part 2

-- RUN THESE IN MYSQLWORKBENCH

-- Ranking 

-- Q1- Team Wise Top Batsmen
SELECT * FROM (
SELECT BattingTeam,batter, sum(batsman_run) Total_runs,
DENSE_RANK() OVER (PARTITION BY BattingTeam ORDER BY sum(batsman_run) DESC) Top_Batsmen_Rank 
FROM ipl 
GROUP BY BattingTeam,batter
) T
WHERE T.Top_Batsmen_Rank <6;

-- Cumulative Sum

-- Q2-  Find the runs of Kohli in 50th,100th and 200th

SELECT * FROM (
SELECT Concat('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID)AS CHAR)) AS Match_No,
Sum(batsman_run) AS Total_Runs,
Sum(sum(batsman_run)) OVER ( ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS Cumulative_Runs
FROM ipl
WHERE batter = 'V Kohli'
GROUP BY ID) T
WHERE Match_No = 'Match-50' OR Match_No = 'Match-100' OR Match_No = 'Match-200' ;

-- Cumulative Average

-- Q3- Cumulative Average of Virat Kohli
SELECT * FROM (
SELECT Concat('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID)AS CHAR)) AS Match_No,
Sum(batsman_run) AS Total_Runs,
Sum(sum(batsman_run)) OVER W  AS Cumulative_Runs,
Avg(sum(batsman_run))  OVER W AS Cumulative_Average
FROM ipl
WHERE batter = 'V Kohli'
GROUP BY ID 
WINDOW W AS (ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)) T;

-- RUNNING AVERAGE 

-- V kohli Performance last 10 matches 

SELECT Concat('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID)AS CHAR)) AS Match_No,
Sum(batsman_run) AS Total_Runs,
Sum(sum(batsman_run)) OVER ( ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS Cumulative_Runs,
Avg(sum(batsman_run)) OVER ( ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS Cumulative_Average,
Avg(sum(batsman_run)) OVER ( ROWS BETWEEN 9 PRECEDING AND CURRENT ROW ) AS Rolling_Average_of_last_Matches
FROM ipl 
WHERE batter = 'V Kohli'
GROUP BY ID;

-- Percent total

-- Resturant R1 Food contribution

SELECT f_name, Total_Value,
Total_Value/Sum(Total_Value) OVER() * 100 food_contribution
FROM (
SELECT t3.f_id,f_name,sum(amount) Total_Value FROM orders t1
JOIN order_details t2 ON t1.order_id = t2.order_id
JOIN food t3 ON t2.f_id = t3.f_id
WHERE r_id = 1
GROUP BY t3.f_id ,f_name) t
Order BY food_contribution DESC;

-- Percent Change 

-- formula - (current value  previous value)/ previous value * 100 

-- Resturant Wise monthly growth

SELECT t1.r_id,r_name ,monthname(date) Month,sum(amount) Total,
lag(sum(amount)) OVER(PARTITION BY r_name) 'previous_sales',
(sum(amount)-lag(sum(amount)) OVER(PARTITION BY r_name))/lag(sum(amount)) OVER(PARTITION BY r_name) * 100 AS 'MOM'
FROM orders t1
JOIN restaurants t2 ON t1.r_id = t2.r_id 
GROUP BY t1.r_id,r_name,monthname(date),month(date)
ORDER BY r_name, month(date);

-- Percentiles and Quantiles 

-- creating a new table 
CREATE TABLE student_marks (
  student_id int DEFAULT NULL,
  name varchar(8) DEFAULT NULL,
  branch varchar(4) DEFAULT NULL,
  marks int DEFAULT NULL
);

INSERT INTO student_marks (student_id, name, branch, marks) VALUES
(1, 'Nitish', 'EEE', 82),
(2, 'Rishabh', 'EEE', 91),
(3, 'Anukant', 'EEE', 69),
(4, 'Rupesh', 'EEE', 55),
(5, 'Shubham', 'CSE', 78),
(6, 'Ved', 'CSE', 43),
(7, 'Deepak', 'CSE', 98),
(8, 'Arpan', 'CSE', 95),
(9, 'Vinay', 'ECE', 95),
(10, 'Ankit', 'ECE', 88),
(11, 'Anand', 'ECE', 81),
(12, 'Rohit', 'ECE', 95),
(13, 'Prashant', 'MECH', 75),
(14, 'Amit', 'MECH', 69),
(15, 'Sunny', 'MECH', 39),
(16, 'Gautam', 'MECH', 51),
(17, 'Abhi', 'EEE', 1);

-- RUN THESE IN MICROSOFT SQL SERVER

-- Find the median marks of the students

SELECT * , Percentile_Disc(0.5) WITHIN GROUP(ORDER BY marks) OVER() Median_Marks
FROM student_marks

-- Find median marks branch Wise
SELECT * , Percentile_Disc(0.5) WITHIN GROUP( ORDER BY marks) OVER(PARTITION BY Branch) Median_Marks
FROM student_marks

SELECT * , Percentile_Cont(0.5) WITHIN GROUP( ORDER BY marks) OVER(PARTITION BY Branch) Median_Marks
FROM student_marks

-- Removing Outliers 
SELECT * FROM (
SELECT *, PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q3'
FROM student_marks
) t 
WHERE t.marks > t.Q1-(1.5*(t.Q3-t.q1)) and t.marks< t.Q3+(1.5*(t.Q3-t.q1)) 


-- SEGEMENTATION (Making Buckets)

SELECT *,Ntile(3) OVER(ORDER BY Marks DESC) AS 'Buckets' FROM student_marks ;

SELECT model,brand,price,
Case 
	When bucket =1 THEN 'budget' 
	When bucket =2 THEN 'mid-range'
	When bucket =3 THEN 'premimum'
	End as 'phone_type'  
FROM (
SELECT brand,model,price,
NTILE(3) OVER(PARTITION BY BRAND ORDER By price ) AS 'bucket'
FROM smartphones) t


-- What Percentage of the rows in the data set have less than or equal to the current row?

-- Cume_Dist = (no. of rows with a value less than or equal to the current row ) / ( total no. of rows) 

-- 99% se uper 

SELECT * FROM ( SELECT *, round(CUME_DIST() OVER (ORDER BY Marks),2) AS 'per_score'
FROM student_marks ) t
Where t.per_score >0.90