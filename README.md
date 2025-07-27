# Netflix movies and TV shows data analysis using sql
## Overview
This project is about analyzing data from Netflix using SQL. The main goal is to find useful insights and answer different business-related questions using the dataset. This README explains the project goals, questions, solutions, key results, and final conclusions.

## Objectives
Understand how many movies and TV shows are on Netflix.
Find out the most common ratings for both movies and TV shows.
Look at content based on release year, country, and duration.
Group and study content using specific keywords or categories.



## Schema
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
## Business Problems and Solutions
### 1. Count the Number of Movies vs TV Shows
SELECT type,
count(*) as total_content
from netflix
group by type

### 2. Find the Most Common Rating for Movies and TV Shows
select type, rating from
(
	SELECT 
  type, 
  rating, 
  common_rating,
  RANK() OVER (PARTITION BY type ORDER BY common_rating DESC) AS ranking
FROM (
  SELECT 
    type, 
    rating, 
    COUNT(*) AS common_rating
  FROM netflix
  GROUP BY type, rating
) AS sub
ORDER BY type, common_rating DESC) as t1
where ranking=1

### 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix
where type='Movie'and release_year=2020

### 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT TRIM(unnest(string_to_array (country,','))) as new_country, count(show_id) as total_content
FROM netflix
group by new_country
order by total_content desc

### 5. Identify the Longest Movie
SELECT * FROM netflix
where type='Movie' and duration= (select max(duration) from netflix)

### 6. Find Content Added in the Last 5 Years
SELECT*FROM netflix
where TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE-INTERVAL'5 YEARS'

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT*FROM netflix
where director ilike '%Rajiv Chilaka%'

### 8. List All TV Shows with More Than 5 Seasons
select*,
SPLIT_PART(duration,' ',1) as season
from netflix
where type='TV Show' and cast(SPLIT_PART(duration,' ',1) as INTEGER)>=5

### 9. Count the Number of Content Items in Each Genre
select unnest(STRING_TO_ARRAY(listed_in,','))as genre,
count(show_id) as content
from netflix
group by genre
order by content desc

### 10.Find each year and the average numbers of content release in India on netflix.
return top 5 year with highest avg content release!

select extract(year from TO_DATE(date_added,'Month DD,YYYY')) as year,count(show_id) as content ,
round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric *100,2) as avg_content
from netflix
where country='India'
group by year
order by content desc

### 11. List All Movies that are Documentaries
select*from netflix
where type='Movie' and listed_in ilike '%documentaries%'

### 12. Find All Content Without a Director
SELECT*FROM netflix
where director is null

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT*FROM netflix
where release_year>= Extract (Year from CURRENT_DATE)-10 and casts ilike '%Salman Khan%'

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT unnest(STRING_TO_ARRAY (casts,',')) as actors ,count(show_id) as content FROM netflix
where country ilike '%India%'
group by actors
Order by content desc
limit 10

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
with new_table
as
(
Select*,
case
when description ilike '%kill%' or description ilike '%violence%'
then 'Bad_content'
else 'good_content'
end category
from netflix
	)
select
category,count(*) as total_content
from new_table
group by category

## Findings and Conclusion
Types of Content: Netflix has a mix of both movies and TV shows.
Ratings: Some ratings are more common, which helps understand what age groups or audiences the content is made for.
Country Insights: We learned which countries create the most content, especially focusing on India.
Keyword Tagging: We saw how content descriptions can show the nature or mood of the shows or movies.
This analysis gives a clear picture of what kind of content is available on Netflix. It can help teams make smarter content decisions or marketing plans.
