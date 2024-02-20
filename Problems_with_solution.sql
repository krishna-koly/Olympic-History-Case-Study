USE olympic_history;
CREATE TABLE athlete
			(
			id  INT,
			name VARCHAR(50),
			sex  VARCHAR(30),
			PRIMARY KEY(id)
			);


-- Problem 01 How many olympics games have been held?--
SELECT COUNT(DISTINCT games) as no_of_games
FROM athlete_events;

-- -------------

-- PROBLEM 02 Write a SQL query to list down all the Olympic Games held so far.--
SELECT DISTINCT(year), season, city 
FROM athlete_events
ORDER BY year ASC;

-- ------------

-- 03. Mention the total no of nations who participated in each olympics game?
select * from athlete_events;

select Games, count(Distinct NOC) as total_nations
from athlete_events
group by Games;

-- -------------

-- 04. Which year saw the highest and lowest no of countries participating in olympics?

with t1 as (
select Games, count(distinct NOC) as lowest
from athlete_events
group by Games
order by lowest
limit 1
),
t2 as (
select Games, count(distinct NOC) as highest
from athlete_events
group by Games
order by highest desc
limit 1
)
select concat(t1.Games, '-', lowest)as lowest_countries, concat(t2.Games, '-', highest)as lowest_countries
from t1,t2;


-- ------------

-- 05. Which nation has participated in all of the olympic games?
select * from athlete_events;

select nr.region as countries,
count(distinct Games) as Total_participated_games
from athlete_events ae
join noc_regions nr on nr.NOC = ae.NOC
group by nr.region
having count(distinct Games) = (select count(distinct Games) from athlete_events);


-- 06.SQL query to fetch the list of all sports which have been part of every olympics.

with tot_games as
              (select count(distinct games) as total_games
              from athlete_events),
          countries as
              (select games, nr.region as country
              from athlete_events oh
              join noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games;
      

-- 7 -- Which Sports were just played only once in the olympics?
-- Using SQL query, Identify the sport which were just played once in all of olympics--

 with t1 as
          	(select distinct games, sport
          	from athlete_events),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games
      from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;

-- 8 -- Fetch the total no of sports played in each olympic games.
-- Write SQL query to fetch the total no of sports played in each olympics.?


select Games,count(distinct sport) as no_of_played_games
from athlete_events
group by Games
order by no_of_played_games desc;


-- 9-- Fetch oldest athletes to win a gold medal
-- SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

with cte as (
select *,
dense_rank() over (partition by Medal order by Age desc) as ok
from athlete_events
where Medal = 'Gold'
)
select Name,Age,Games,Season,Sport,Medal
from cte 
where ok = 1;

-- 10.-- Find the Ratio of male and female athletes participated in all olympic games.
-- Write a SQL query to get the ratio of male and female participants.

with cte as (
select count(distinct ID) as female
from athlete_events
where Sex = 'F'
),
te as (
select count(distinct ID) as male
from athlete_events
where Sex = 'M'
),
t2 as(
select 
	round(100*female/(select count(distinct ID) from athlete_events),2) as female_ratio,
	round(100*male/(select count(distinct ID) from athlete_events),2) as male_ratio
from cte,te
)
select concat('1 : ', round(female_ratio/male_ratio, 2)) as ratio
from t2;

-- 11. Fetch the top 5 athletes who have won the most gold medals.
-- SQL query to fetch the top 5 athletes who have won the most gold medals.
select * from athlete_events;

with cte as (select name, team, count(Medal)as total_medal,
dense_rank() over (order by count(Medal) desc) as rnk 
from athlete_events
where Medal = 'Gold'
group by name,team
)
select 
name,team,total_medal
from cte
where rnk <= 5;

-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
-- SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).

with cte as (select name, team, count(Medal)as total_medal,
dense_rank() over (order by count(Medal) desc) as rnk 
from athlete_events
where Medal = 'Gold' or Medal = 'Silver' or Medal = 'Bronze'
group by name,team
)
select 
name,team,total_medal
from cte
where rnk <= 5;


-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

-- Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics.
--  (Success is defined by no of medals won).


with cte as (select distinct region, count(Medal)as total_medal,
dense_rank() over (order by count(Medal) desc) as rnk 
from athlete_events
join noc_regions using (NOC)
#where Medal = 'Gold' or Medal = 'Silver' or Medal = 'Bronze'
where Medal != 'NA'
group by region
)
select 
region, total_medal
from cte
where rnk <= 5;



-- 14. List down total gold, silver and broze medals won by each country
select * from athlete_events;
select * from noc_regions;


SELECT 
    nr.region,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM 
    athlete_events ae
JOIN noc_regions nr on ae.NOC = nr.NOC
WHERE 
    Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY 
    nr.region
ORDER BY 
    Gold desc, Silver desc, Bronze desc;
    

-- 15 -- List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

-- Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals 
-- won by each country corresponding to each olympic games.

SELECT 
    nr.region,Games,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM 
    athlete_events ae
JOIN noc_regions nr on ae.NOC = nr.NOC
WHERE 
    Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY 
    Games,nr.region
ORDER BY 
     Games;

-- 16.Identify which country won the most gold, most silver and most bronze medals in each olympic games.

-- Problem Statement: Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals


select * from athlete_events;

with cte as(
select distinct Games,region,
sum(case when Medal = 'Gold' then 1 else 0 end )as gold_count,
sum(case when Medal = 'Silver' then 1 else 0 end) as Silver_count,
sum(case when Medal = 'Bronze' then 1 else 0 end) as Bronze_count
from athlete_events a
JOIN noc_regions AS n ON a.NOC = n.NOC
group by Games,region
)
select distinct games
, concat(first_value(region) over(partition by games order by gold_count desc)
, ' - '
, first_value(gold_count) over(partition by games order by gold_count desc)) as Max_Gold
, concat(first_value(region) over(partition by games order by Silver_count desc)
, ' - '
, first_value(Silver_count) over(partition by games order by Silver_count desc)) as Max_Silver
, concat(first_value(region) over(partition by games order by Bronze_count desc)
, ' - '
, first_value(Bronze_count) over(partition by games order by Bronze_count desc)) as Max_Bronze
from cte
order by games;



-- 17-- Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
-- Similar to the previous query, identify during each Olympic Games, which country won the highest gold,
 -- silver and bronze medals. Along with this, identify also the country with the most medals in each olympic games.


with cte as(
select distinct Games,region,
count(case when Medal = 'Gold' then Medal end )as gold_count,
count(case when Medal = 'Silver' then Medal end) as Silver_count,
count(case when Medal = 'Bronze' then Medal  end) as Bronze_count,
count(case when Medal = 'Bronze' or Medal ='Silver' or Medal = 'Gold' then Medal end) as Total_count

from athlete_events a
JOIN noc_regions AS n ON a.NOC = n.NOC
group by Games,region
)
select distinct games
, concat(first_value(region) over(partition by games order by gold_count desc)
, ' - '
, first_value(gold_count) over(partition by games order by gold_count desc)) as Max_Gold
, concat(first_value(region) over(partition by games order by Silver_count desc)
, ' - '
, first_value(Silver_count) over(partition by games order by Silver_count desc)) as Max_Silver
, concat(first_value(region) over(partition by games order by Bronze_count desc)
, ' - '
, first_value(Bronze_count) over(partition by games order by Bronze_count desc)) as Max_Bronze
, concat(first_value(region) over(partition by games order by Total_count desc)
, ' - '
, first_value(Total_count) over(partition by games order by Total_count desc)) as Total_Medal
from cte
order by games;



-- 18.Which countries have never won gold medal but have won silver/bronze medals?

-- Problem Statement: Write a SQL Query to fetch details of countries which have won 
-- silver or bronze medal but never won a gold medal.


select 
    nr.region,Games,
    SUM(CASE WHEN Medal != 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM 
    athlete_events ae
JOIN noc_regions nr on ae.NOC = nr.NOC
 
where Medal != 'Gold' or Medal = 'Silver' or Medal = 'Bronze'
GROUP BY 
    Games,nr.region
ORDER BY 
    Silver desc ,Bronze desc;



-- 19.In which Sport/event, India has won highest medals.
-- Problem Statement: Write SQL Query to return the sport which has won India the highest no of medals.

select Sport, count(Medal)as total_medal
from athlete_events
where NOC = 'IND' and Medal <> 'NA'
group by Sport
order by total_medal desc
limit 1;

-- 20 -- Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

-- Problem Statement: Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey.

select team,sport,Games,count(Medal)as Total_Medal
from athlete_events
where NOC = 'IND' and Sport = 'Hockey' and medal in ('Gold', 'Silver', 'Bronze')
group by Games,team,sport
order by games





























 
























-




      
      
      




-- Identify which country won the most gold, most silver and most bronze medals in each olympic games.




















 

















        