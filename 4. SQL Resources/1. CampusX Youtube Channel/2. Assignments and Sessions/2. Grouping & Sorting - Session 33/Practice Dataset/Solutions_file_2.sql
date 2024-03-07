-- Practice Dataset 1 -- 

--  1. Find out the average sleep duration of top 15 male candidates who's sleep duration are equal to 7.5 or greater than 7.5.

SELECT ID,avg(sleep_duration) as average FROM sleep_data
WHERE sleep_duration >=7.5 and gender = 'male'
GROUP BY ID
ORDER BY average DESC
LIMIT 15;

-- 2. Show avg deep sleep time for both gender

SELECT Gender, round(avg(Sleep_duration),2) AS Average_Sleep 
FROM sleep_data
GROUP BY Gender;

-- 3. Find out the lowest 10th to 30th light sleep percentage records where deep sleep percentage values are between 25 to 45.
-- Display age, light sleep percentage and deep sleep percentage columns only.

SELECT Age,Light_sleep_percentage ,Deep_sleep_percentage 
FROM sleep_data
where Deep_sleep_percentage BETWEEN 25 and 45
ORDER BY Light_sleep_percentage
Limit 10,20;

-- 4. Group by on exercise frequency and smoking status and show average deep sleep time, average light sleep time and avg rem sleep time.
-- Note the differences in deep sleep time for smoking and non smoking status

Select Exercise_frequency,Smoking_status,avg(Deep_sleep_percentage) as Average_Deep_Sleep, avg(Light_sleep_percentage) as Average_Light_Sleep,
avg(REM_sleep_percentage) as Average_REM_Sleep
FROM sleep_data
GROUP BY Exercise_frequency, Smoking_status;

-- 5. Group By on Awekning and show AVG Caffeine consumption, AVG Deep sleep time and 
     -- AVG Alcohol consumption only for people who do exercise atleast 3 days a week. 
     -- Show result in descending order awekenings
     
SELECT ID,Exercise_frequency,Awakenings,AVG(Caffeine_consumption) AS Average_Caffeine_Consumption, round(AVG(Deep_sleep_percentage)) AS Average_Deep_Sleep_Time 
FROM sleep_data
WHERE Exercise_frequency = 3
GROUP BY Awakenings,ID
ORDER BY Awakenings DESC;

################# Practice Dataset 2 ############################################

-- 6. Display those power stations which have average 'Monitored Cap.(MW)' 
      -- (display the values) between 1000 and 2000 and the number of occurance of the power stations 
      -- (also display these values) are greater than 200. 
      -- Also sort the result in ascending order.
      
SELECT power_station, Count(Power_Station) as Total_Counts,  avg(Monitored_Cap_MW) as Average_MW FROM power_data
WHERE Monitored_Cap_MW BETWEEN 1000 and 2000
GROUP BY Power_Station
-- HAVING count(Power_Station)>200
ORDER BY Average_MW;

###################### Practice Dataset 3 ########################################################

SELECT * FROM us_colleges;

-- 7. Display top 10 lowest "value" State names of which the Year either belong to 2013 or 2017 or 2021 and type is 'Public In-State'. 
   -- Also the number of occurance should be between 6 to 10. 
   -- Display the average value upto 2 decimal places, state names and the occurance of the states.

SELECT State, Count(*) AS Total_Count, Avg(Value) AS Average_Value_of_State From us_colleges
WHERE YEAR IN (2013,2017,2021) and Type = 'Public In-State'
GROUP BY State
Having Count(*) BETWEEN 6 and 10
ORDER BY Average_value_of_state;

-- 8. Best state in terms of low education cost (Tution Fees) in 'Public' type university.
SELECT State,  Avg(Value)AS Average_Value  FROM us_colleges
WHERE Type LIKE 'Public%'
GROUP BY State
Order by Average_Value ASC
LIMIT 1;

-- 9. 2nd Costliest state for Private education in year 2021. Consider, Tution and Room fee both
SELECT State, avg(Value) as fees FROM us_colleges
WHERE Type = 'Private' and Expense = 'Fees/Tuition'
GROUP BY State
ORDER BY fees DESC
LIMIT 1,1;


######################### Practice Dataset 4 ##################################################

SELECT * FROM shipping_data;

-- 10. Display total and average values of Discount_offered for all the combinations of 'Mode_of_Shipment'
 -- (display this feature) and 'Warehouse_block' (display this feature also) for all male ('M') and 'High' Product_importance. 
 -- Also sort the values in descending order of Mode_of_Shipment and ascending order of Warehouse_block.
 
 SELECT Warehouse_block, Mode_of_Shipment, SUM(Discount_offered) AS Total_Discount , Avg(Discount_offered) AS Avg_Discount_Offered
 FROM shipping_data
 GROUP BY Warehouse_block, Mode_of_Shipment
 ORDER BY Warehouse_block  ASC, Mode_of_Shipment DESC;

