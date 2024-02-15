## Independent Subquery - Scalar Subquery

## Q1 - Find the movie with highest rating
SELECT name,score FROM movies
WHERE score = (SELECT MAX(SCORE) FROM MOVIES);

## Q2 -  Find the movie with highest profit(vs order by) 
SELECT Name,Genre,Score, (gross-budget) AS Profit 
FROM movies
WHERE (gross-budget) =  (SELECT MAX(gross-budget) 
									FROM movies);
                                    
## Q3 - Find how many movies have a rating > the avg of all the movie ratings(Find the count of above average movies)
SELECT COUNT(*)AS Count_Of_Movies FROM (
SELECT * 
FROM movies
WHERE score > (SELECT AVG(score) FROM movies)) as t1; 

--------------- or ------------------------------------------

SELECT Count(*) AS Count_of_Movies
FROM movies
WHERE score > (SELECT AVG(score) FROM movies); 


## Q3 - Find the highest rated movie of 2000
SELECT name,score
 FROM movies 
Where year = 2000 and Score = (SELECT MAX(score) FROM movies
                                    WHERE year = 2000);
                                    
## Q4 - Find the highest rated movie among all movies whose number of votes are > the dataset avg votes
SELECT name, year, score, votes 
FROM movies
WHERE score = (
	SELECT max(score) FROM movies
	WHERE votes > (SELECT avg(votes) from movies));

## ----------------------------------------------------------------------------------------------------------------

## Independent Subquery - Row Subquery(One Col Multi Rows)

## 1. Find all users who never ordered
SELECT user_id,name FROM users
WHERE user_id NOT IN ( SELECT DISTINCT(user_id) FROM orders);

## 2. Find all the movies made by top 3 directors(in terms of total gross income)
WITH top_direct AS (
SELECT director  FROM movies
GROUP BY director
ORDER BY sum(Gross) DESC
LIMIT 3) 

SELECT name,director,year,genre,score,star FROM movies
WHERE director In ( SELECT * FROM top_direct);

## 3. Find all movies of all those actors whose filmography's avg rating > 8.5(take 25000 votes as cutoff)
SELECT name, genre FROM movies 
WHERE star IN 
(
SELECT Star FROM movies 
GROUP BY star
HAVING avg(score)> 8.5)
and votes > 25000;

## ----------------------------------------------------------------------------------------------------------------

## Independent Subquery - Table Subquery(Multi Col Multi Row)

## 1. Find the most profitable movie of each year
SELECT name,genre,score,director,star,year FROM movies 
WHERE (year,gross-budget) In 
(
SELECT year,Max(gross-budget) as Profit 
FROM movies
GROUP BY year
);

## 2. Find the highest rated movie of each genre votes cutoff of 25000
SELECT * FROM movies 
WHERE (genre, score) IN 
(SELECT genre, MAX(score) as Highest_rating
 FROM movies
GROUP BY genre
) AND Votes >25000;


## 3. Find the highest grossing movies of top 5 actor/director combo in terms of total gross income
With top_combo as (
SELECT director,Star,max(gross) FROM movies 
GROUP BY director,star
ORDER BY Sum(gross) DESC
LIMIT 5)

SELECT name, year, director, star, genre FROM movies
WHERE (director,star,gross) IN ( SELECT * from top_combo);

## ----------------------------------------------------------------------------------------------------------------

## Correlated Sub-Query 

## 1. Find all the movies that have a rating higher than the average rating of movies in the same genre.

SELECT name,genre,score,year FROM movies m1
WHERE score > (Select Avg(score) FROM movies m2 WHERE m2.genre = m1.genre); 

## 2.  Find the favorite food of each customer.
With food as
(SELECT T2.user_id,name,Count(*) as Frequency,f_name FROM users AS T1
JOIN orders AS T2 ON T1.user_id = T2.user_id
JOIN order_details AS T3 ON T2.order_id = T3.order_id
JOIN food AS T4 ON T3.f_id = T4.f_id
GROUP BY T2.user_id,T3.f_id,name,f_name
)

SELECT * FROM food f1 WHERE Frequency = (SELECT max(Frequency) from food f2 where f2.user_id = f1.user_id);

## ----------------------------------------------------------------------------------------------------------------

## USAGE WITH SELECT 

## 1. Get the percentage of votes for each movie compared to the total number of votes.
SELECT Name, Votes, Round((Votes/(SELECT sum(votes) FROM movies ))*100,3) AS Percentage_Of_Votes FROM movies; 

## 2. Display all movie names ,genre, score and avg(score) of genre 
SELECT Name,Genre,Score ,(Select round(avg(Score),2) FROM movies m2 WHERE m2.genre = m1.genre ) AS Avg_of_that_Genre
FROM movies m1;

## ----------------------------------------------------------------------------------------------------------------

## Usage with FROM

## Display average rating of all the restaurants
SELECT r_name, Avg_rating FROM (
SELECT r_name,round(avg(restaurant_rating),2) Avg_rating FROM restaurants t1 
JOIN orders t2 ON t1.r_id = t2.r_id
GROUP BY r_name ) T1;
-- ---------------------------------------- OR ----------------------------------------------------------------
SELECT r_name, Rating FROM (
SELECT r_id,round(Avg(restaurant_rating),1) Rating FROM orders 
GROUP BY r_id ) t1 JOIN restaurants t2 On t1.r_id =  t2.r_id;

## ----------------------------------------------------------------------------------------------------------------

## Usage with Having

## 1. Find genres having avg score > avg score of all the movies
SELECT Genre,Avg(score) AS Average_Score FROM movies
GROUP BY genre
HAVING avg(Score) > (SELECT AVG(score) FROM movies);

## ----------------------------------------------------------------------------------------------------------------

## Subquery In INSERT
## Populate a already created loyal_customers table with records of only those customers who have ordered food more than 3 times.
INSERT INTO loyal_users (user_id,name)
SELECT t1.user_id,name From users t1
JOIN orders t2 On t1.user_id = t2.user_id
GROUP BY t1.user_id,name
HAVING COUNT(*)>3;

## ----------------------------------------------------------------------------------------------------------------

## Subquery in UPDATE

## Populate the money col of loyal_cutomer table using the orders table. Provide a 10% app money to all customers based on their order value.
UPDATE loyal_users
SET money = (Select sum(amount) *0.1 From orders Where orders.user_id = loyal_users.user_id);

## ----------------------------------------------------------------------------------------------------------------

## Subquery in DELETE

## Delete all the customers record who have never ordered.

DELETE FROM users WHERE user_id IN  (SELECT user_id FROM users
WHERE user_id NOT IN ( SELECT DISTINCT(user_id) FROM orders))