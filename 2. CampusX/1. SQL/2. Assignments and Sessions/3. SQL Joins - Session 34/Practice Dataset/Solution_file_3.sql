####################  Freedom Ranking Dataset #######################################

## Q-1 Find out top 10 countries' which have maximum A and D values.

SELECT * FROM country_ab;
SELECT * FROM country_cd;

SELECT C1.Country,MAX(C1.A), MAX(C2.D) 
FROM country_ab AS C1 
JOIN country_cd AS C2
ON C1.Country = C2.Country
GROUP BY C1.Country
ORDER BY MAX(C1.A) DESC, MAX(C2.D) DESC
LIMIT 10;


## Find out highest CL value for 2020 for every region. Also sort the result in descending order.
   ##  Also display the CL values in descending order.
   
SELECT C2.Region AS Region, Sum(C1.CL) AS CL_Value FROM country_cl C1
JOIN country_ab C2
ON C1.Country = C2.Country
WHERE C1.Edition= 2020
GROUP BY C2.Region
ORDER BY CL_Value DESC; 


########################## SALES DATASET PRACTICE ######################################

## Q-3 Find top-5 most sold products.

SELECT T1.ProductID, Name As Product_Name, Sum(Quantity) As Total_Quantity 
FROM products as T1
JOIN sales1 T2
ON T1.ProductID = T2.ProductID
GROUP BY T1.ProductID, Name
Order By Total_Quantity DESC
LIMIT 5;


## Q-4: Find sales man who sold most no of products.

SELECT T1.SalesPersonID, concat(T2.FirstName, " " ,T2.LastName) AS Sales_Person_Name, sum(Quantity) AS Total_Quantity FROM sales1 AS T1
JOIN employees AS T2
ON T1.SalesPersonID = T2.EmployeeID
Group BY T1.SalesPersonID, concat(T2.FirstName, " " ,T2.LastName) 
ORDER BY Total_Quantity DESC
LIMIT 1;

## Q-5: Sales man name who has most no of unique customer.

SELECT SalesPersonID, Concat(FirstName," ", LastName) AS Full_Name, Count(Distinct CustomerID) as Number_of_Unique_Customers
FROM employees AS T1
JOIN sales1 AS T2
ON T1.EmployeeID = T2.SalesPersonID
Group By SalesPersonID, Concat(FirstName," ", LastName)
ORDER BY Number_of_unique_Customers DESC
LIMIT 1;

## Q-6: Sales man who has generated most revenue. Show top 5.

SELECT EmployeeID, concat(FirstName," " ,LastName) SalesPerson, Round(Sum(Price),2) AS Total_Revenue FROM employees AS T1
JOIN sales1  AS T2
ON T2.SalesPersonID = T1.EmployeeID
JOIN products AS T3
ON T2.ProductID = T3.ProductID
GROUP BY EmployeeID, concat(FirstName," " ,LastName)
ORDER BY Total_Revenue DESC
LIMIT 5;

## Q-7: List all customers who have made more than 10 purchases.

SELECT t1.CustomerID,concat(t2.FirstName," " ,t2.LastName) AS customer_name, Count(*)AS Order_Count FROM sales1 AS t1
JOIN customers AS t2
ON t1.CustomerID = t2.CustomerID
GROUP BY CustomerID, concat(t2.FirstName," " ,t2.LastName)
HAVING Count(*)>10
ORDER BY Order_Count DESC;

## Q-8 : List all salespeople who have made sales to more than 5 customers.
SELECT t1.EmployeeID ,concat(t1.FirstName," " ,t1.LastName) AS SalesPersonName, Count(Distinct CustomerID) Sales_Count
FROM employees AS t1
JOIN sales1 AS t2
ON t1.EmployeeID = t2.SalesPersonID
GROUP BY t1.EmployeeID, concat(t1.FirstName," " ,t1.LastName)
HAVING Count(Distinct CustomerID)>5
ORDER BY Sales_Count DESC;
