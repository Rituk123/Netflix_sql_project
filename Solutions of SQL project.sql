--netflix project
drop table if exists netflix;
create table netflix (
    show_id	varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(250),
	casts varchar(1000),
	country	varchar(150),
	date_added	varchar(50),
	release_year int,
	rating	varchar(10),
	duration varchar(15),	
	listed_in	varchar(100),
	description varchar(500)
);

select count(*) as total_content from netflix

select distinct type from netflix;

--15 business problems
--1. Count the number of movies vs tv shows.
SELECT type,
count(*) as total_content
from netflix
group by type

--2. Find the most common rating for movies and tv shows
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

--3. List all the movies that are released in a specifc year(e.g. 2020)
SELECT * FROM netflix
where type='Movie'and release_year=2020

--4.Find the top 5 countries with the most content on netflix

SELECT TRIM(unnest(string_to_array (country,','))) as new_country, count(show_id) as total_content
FROM netflix
group by new_country
order by total_content desc
--unnest function will be differentiating all the countries which are combined using commas..
--trim function will not give duplicate values


--5.Identify the longest movie
SELECT * FROM netflix
where type='Movie' and duration= (select max(duration) from netflix)

--6. find the content that added in the last 5 years
SELECT*FROM netflix
where TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE-INTERVAL'5 YEARS'
 

--7.Find all the movies/tv_shows by director 'Rajiv Chilaka'!
SELECT*FROM netflix
where director ilike '%Rajiv Chilaka%'
--ilike is similar to like function, its just not case sensitive


--8. List all the tv shows with more than 5 seasons
select*,
SPLIT_PART(duration,' ',1) as season
from netflix
where type='TV Show' and cast(SPLIT_PART(duration,' ',1) as INTEGER)>=5
-- where type='TV Show' and SPLIT_PART(duration,' ',1)::numeric>=5
--without using cast, the split function is giving the result in text, so convert it into integer

--9.Count the number of content items in each genre
select unnest(STRING_TO_ARRAY(listed_in,','))as genre,
count(show_id) as content
from netflix
group by genre
order by content desc

/*10. find each year and the average number of content release by india on netflix.
return top 5 year with highest avg content release */
select extract(year from TO_DATE(date_added,'Month DD,YYYY')) as year,count(show_id) as content ,
round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric *100,2) as avg_content
from netflix
where country='India'
group by year
order by content desc

--11. List all the movies that are documentaries
select*from netflix
where type='Movie' and listed_in ilike '%documentaries%'

--12.Find all the content without a director
SELECT*FROM netflix
where director is null

--13.find how many movies actor 'salman khan' appeared in last 10 years!
SELECT*FROM netflix
where release_year>= Extract (Year from CURRENT_DATE)-10 and casts ilike '%Salman Khan%'

--14. Find the top 10 actors who have appeared in the highest number of movies in India
SELECT unnest(STRING_TO_ARRAY (casts,',')) as actors ,count(show_id) as content FROM netflix
where country ilike '%India%'
group by actors
Order by content desc
limit 10

/*15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in the
description field.Label content containing these keywords as 'bad' and all other content as 'good' . 
count how many items fall into each category.*/
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
