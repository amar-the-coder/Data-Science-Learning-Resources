SELECT * FROM nw_employees;
USE sql_Window_func;
SELECT * FROM nw_order_details;

SELECT * FROM nw_orders;

SELECT * FROM nw_products;

SELECT * FROM nw_suppliers;

-- Q-1: Rank Employee in terms of revenue generation. Show employee id, first name, revenue, and rank

Select *, 
DENSE_RANK() OVER(ORDER BY Total_Revenue DESC) 'Rank'
From (
Select EmployeeId, FirstName,sum(revenue) Total_Revenue FROM (
SELECT t1.EmployeeID, FirstName, round((UnitPrice*Quantity),2) revenue
FROM nw_employees t1
JOIN nw_orders t2 ON t1.EmployeeID = t2.EmployeeID
JOIN nw_order_details t3 ON t3.OrderID = t2.OrderID
) t
GROUP BY EmployeeID,FirstName) p;


-- Q-2: Show All products cumulative sum of units sold each month.
SELECT *, sum(quantity) OVER(PARTITION BY ProductName ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM ( 
SELECT ProductName,monthname(OrderDate) Month_Name,month(OrderDate) Month_no,sum(Quantity) 'Quantity' FROM nw_products t1
JOIN nw_order_details t2 ON t1.ProductID = t2.ProductID 
JOIN nw_orders t3 ON t3.OrderID = t2.OrderID
GROUP BY ProductName,monthname(OrderDate),month(OrderDate)
ORDER BY  month(OrderDate),ProductName
 ) t
 ORDER BY ProductName,Month_No;
 
 -- Q-3 : Show Percentage of total revenue by each suppliers
SELECT * , round(Revenue/sum(revenue) Over(),4)*100 Percent_Total  FROM (
SELECT CompanyName, round((t3.unitPrice*Quantity),2) Revenue FROM nw_suppliers t1
JOIN nw_products t2 
ON t1.SupplierID= t2.SupplierID
JOIN nw_order_details t3 ON t3.ProductID = t2.ProductID
) t;

 
-- Q-4: Show Percentage of total orders by each suppliers
SELECT * , round(Total_Count/sum(Total_Count) Over(),2)*100 Percent_Total FROM (
SELECT CompanyName, count(t3.orderId) Total_Count FROM nw_suppliers t1
JOIN nw_products t2 
ON t1.SupplierID= t2.SupplierID
JOIN nw_order_details t3 ON t3.ProductID = t2.ProductID
Group BY CompanyName
) t;

-- Q-5:Show All Products Year Wise report of totalQuantity sold, percentage change from last year.

SELECT *,round((Quantity-Lag(Quantity) OVER(PARTITION BY ProductName))/Lag(Quantity) OVER(PARTITION BY ProductName),2)* 100 As Percent_change
 FROM (
SELECT ProductName,year(OrderDate) Year, count(Quantity) Quantity FROM nw_products t1
JOIN nw_order_details t2 ON t1.ProductID=t2.ProductID
JOIN nw_orders t3 ON t3.OrderID = t2.OrderID
GROUP BY ProductName,year(OrderDate)
ORDER BY ProductName
) t;

-- Problem-6: For each condition, what is the average satisfaction level of drugs that are "On Label" vs "Off Label"?

SELECT Distinct Conditions,  Indication,
round(avg(Satisfaction) OVER(PARTITION BY Conditions , Indication),2) 'avg_satisfication'  FROM drugs_data;

-- Problem-7: For each drug type (RX, OTC, RX/OTC), what is the average ease of use and satisfaction level of drugs with a price above the median for their type?

-- Running in ssms 

WITH MedianPrices AS (
    SELECT
        Type,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Price) OVER (PARTITION BY Type) AS MedianPrice
    FROM
        Drugs_data
)

SELECT
    t.Type,
    AVG(t.EaseOfUse) AS AvgEaseOfUse,
    AVG(t.Satisfaction) AS AvgSatisfaction
FROM
    Drugs_data t
JOIN
    MedianPrices m ON t.Type = m.Type
WHERE
    t.Price > m.MedianPrice
GROUP BY
    t.Type;

-- Problem 8: What is the cumulative distribution of EaseOfUse ratings for each drug type (RX, OTC, RX/OTC)? 
-- Show the results in descending order by drug type and cumulative distribution. 
-- (Use the built-in method and the manual method by calculating on your own. For the manual method,
-- use the "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW" and see if you get the same results as the built-in method.)

SELECT Drug,Type,EaseOfUse,
round(CUME_DIST() OVER(PARTITION BY Type ORDER BY EaseOfuse DESC ),4) Dist,
SUM(EaseOfUSe) OVER(PARTITION BY Type ORDER BY EaseOfuse DESC ) 
FROM Drugs_data
ORDER BY Type DESC, DIST DESC;

-- manual method 
SELECT * ,round((EaseOfUse/cum_sum),4) dist FROM(
SELECT drug, type, Easeofuse, sum(EaseOfUse) OVER(PARTITION BY Type) cum_sum
FROM Drugs_data
ORDER BY Type DESC, cum_sum DESC) t
Order By  t.type DESC, t.Cum_sum DESC,dist DESC;

-- Problem 9: What is the median satisfaction level for each medical condition? 
-- Show the results in descending order by median satisfaction level. (Don't repeat the same rows of your result.)

SELECT Distinct Conditions, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Satisfaction) OVER(PARTITION BY Conditions) Median_Satisfaction_level 
FROM Drugs_data
ORDER BY Median_Satisfaction_level DESC;

-- Problem 10: What is the running average of the price chof drugs for each medical condition? 
-- Show the results in ascending order by medical condition and drug name.

SELECT drug,Conditions,price,
avg(Price) OVER(PARTITION BY Conditions ORDER BY Conditions ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_average 
FROM drugs_data
ORDER BY Conditions,drug;


SELECT *, round(avg(Price) OVER(PARTITION BY Conditions ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) running_average FROM (
SELECT Conditions,drug,Price FROM drugs_data
ORDER BY Conditions,drug
) t;

-- Problem 11: What is the percentage change in the number of reviews for each drug between the previous row and the current row? 
-- Show the results in descending order by percentage change.

SELECT Drug,Reviews,
round(((Reviews- lag(Reviews) OVER (PARTITION BY Drug))/lag(Reviews) OVER (PARTITION BY Drug)) *100,2) percentage_change
FROM drugs_data
ORDER BY percentage_change desc;


-- Experiment 
SELECT *, (reviews-Lag(Reviews) OVER())*100/(Lag(Reviews) OVER()) pc FROM (
SELECT Drug,round(sum(Reviews),1) Reviews FROM drugs_data
GROUP BY Drug
) t
ORDER BY pc desc;

-- Problem 12 : What is the percentage of total satisfaction level for each drug type (RX, OTC, RX/OTC)? 
-- Show the results in descending order by drug type and percentage of total satisfaction.

SELECT 
 Type,drug,
 Satisfaction,
 round(Satisfaction/sum(Satisfaction) OVER( PARTITION BY Type),3) * 100 percentage
 FROM drugs_data;

-- Problem 13: What is the cumulative sum of effective ratings for each medical condition and drug form combination? 
-- Show the results in ascending order by medical condition, drug form and the name of the drug

SELECT drug,Conditions,form,round(Effective,2) ratings,
round(sum(Effective) OVER (PARTITION BY Conditions,Form ORDER BY conditions ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) cum_sum
 FROM drugs_data
 ORDER BY Conditions,Form,drug;
 
 -- Problem-14: What is the rank of the average ease of use for each drug type (RX, OTC, RX/OTC)? 
 -- Show the results in descending order by rank and drug type.
 
 SELECT type, avg(EaseOfUse) Avg_use,
 DENSE_RANK() OVER (ORDER BY AVG(EaseOfUse) DESC)
 FROM drugs_data
 GROUP BY Type;
 
 
 -- Problem-15: For each condition, what is the average effectiveness of the top 3 most reviewed drugs?
 
 SELECT Drug,Conditions,reviews,rank_reviews,avg(effective) FROM (
 SELECT conditions,Drug,Effective,Reviews,
 DENSE_RANK() OVER (PARTITION BY Conditions ORDER BY Reviews DESC) rank_reviews
 FROM drugs_data
) t
WHERE rank_reviews<4
GROUP BY Conditions,Drug,Reviews,rank_reviews

 