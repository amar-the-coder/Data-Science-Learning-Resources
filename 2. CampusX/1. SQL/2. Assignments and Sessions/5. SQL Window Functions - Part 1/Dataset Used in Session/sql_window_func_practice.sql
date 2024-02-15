## Practice Questions 

SELECT * FROM marks;

## examples of aggregation with window function

# 1. Branch Wise Average Marks
SELECT *,
Avg(marks) OVER(PARTITION BY branch)
FROM marks;

# 2. Window Function on the whole dataset
SELECT *,Avg(marks) OVER()
FROM marks;

# 3. Find the average marks , average marks by branch do the same with min and max
SELECT *, avg(marks) OVER()'Overall_avg',
avg(marks) OVER(PARTITION BY branch) 'Branch_avg' ,
min(marks) OVER()'Overall_min_marks',
min(marks) OVER(PARTITION BY branch) 'branch_minimum',
max(marks) OVER()'Overall_max',
max(marks) OVER(PARTITION BY branch) 'Branch_maximum'
FROM marks;

# 4. Find all the students wh have score higher marks than tha average marks of their resective branch
SELECT name,branch,marks,branch_avg FROM(
SELECT *, 
Avg(marks) OVER(PARTITION BY Branch) AS branch_avg FROM marks) as t 
WHERE t.marks>t.branch_avg;

## Rank/ Dense_rank/ row_number

## 1. Rank on the whole datset

## if 2 marks are same then rank always skip like 95-1, 95-1,93-3 

SELECT *,RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'branch_rank' FROM mark;

## to tackle this we have dense_rank
## in dense_rank if 2 are same then it will don;t skip. 95-1,95-1,95-3

SELECT *,DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'branch_rank' FROM marks;

## Rank vs Dense_rank
SELECT *,RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'branch_rank',
DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'branch_dense_rank' FROM marks;

## Row_number
SELECT*, ROW_NUMBER() OVER(PARTITION BY branch) AS 'Branch_numbering'
FROM marks;


## question -- Find the top 2 customers of every month from the zomato wala dataset.
SELECT * FROM (
SELECT name,o.user_id, month(DATE) Month_Num, monthname(date) Month ,sum(amount) Total_Amount,
RANK() OVER(PARTITION BY monthname(DATE) ORDER BY sum(amount) DESC) "month_rank" FROM orders o
JOIN users u ON u.user_id = o.user_id
GROUP BY user_id,monthname(DATE), month(DATE),name
ORDER BY month(date)
) T WHERE T.month_rank <3
ORDER BY month_num;

## First_Value and last Value 

## on the whole dataset
## ---- First Value

SELECT *,FIRST_VALUE(Marks) OVER (ORDER BY marks desc) 'First_value_max' 
FROM marks;

## ----- Last Value 
SELECT *,LAST_VALUE(Marks) OVER (ORDER BY marks desc) 'Last_value_max' 
FROM marks;

-- Here the magic is instead of printing the last value, the corresponding marks of the current row is printing :
#### It is because of the frames concept in mysql
-- There are 4 Types of frames 

-- so to tackle this 
-- use rows between unbounded preceding & unbounded following
#### By Default is unbounded proceding & current Row 

SELECT *,
LAST_VALUE(marks) OVER(ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 'Lowest_Marks'
FROM marks;

## Nth Value
SELECT *,
NTH_VALUE(marks,2) OVER(ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 'Secomd_Highest_Marks',
NTH_VALUE(marks,2) OVER(ORDER BY marks ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 'Secomd_lowest_Marks'
FROM marks;

## find the branch_toppers
SELECT name, branch,marks FROM (
Select *,
FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC) 'branch_topper_marks' 
FROM marks
) T
WHERE T.marks = T.branch_topper_marks;

## Branch Lowst marks
SELECT name, branch,marks FROM (
Select *,
FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks ASC) 'branch_lowest_marks' 
FROM marks
) T
WHERE T.marks = T.branch_lowest_marks;
-- or ----------------------------------------------------------------
SELECT NAME, branch,marks FROM(
SELECT *,
LAST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 'Lowest_Marks_branch'
FROM marks ) T 
WHERE t.marks = t.lowest_marks_branch;


## Lag AND Lead 
-- Lag matlab ek piche wala - First row null hogi
-- Lead matlab ek aage wala - Last row null hogi

SELECT *,
lag(marks) OVER (ORDER BY student_id) 'lagging marks'
FROM marks;

SELECT *,
lead(marks) OVER (ORDER BY student_id) 'lead marks'
FROM marks;
 
 ## find MOM growth of Zomato
 
 -- percentage = curr-previous/previous
 
 SELECT Monthname(date),sum(amount),
 ((sum(amount))-lag(sum(amount)) over(ORDER BY month(date)))/(lag(sum(amount)) over(ORDER BY month(date)))*100 'percentage'
 From orders
 GROUP BY monthname(date) ,month(date) 
 order BY month(date) ASC
 