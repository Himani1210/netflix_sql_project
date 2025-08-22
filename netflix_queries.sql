create database netflix_db1;
use netflix_db1;
show tables;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);
select * from netflix_titles;
truncate netflix;
select count(*) from netflix;

select distinct type from netflix;

# 15 problems

# 1. Count the number of Movies vs TV Shows
select type, count(*) as total_content from netflix group by type;

# 2. Find the most common rating for movies and TV shows
select type, rating from(
select type, rating, count(*), rank() over(partition by type order by count(*) desc) as ranking
from netflix 
group by 1,2) as t1
where ranking=1;

# 3. List all movies released in a specific year (e.g., 2020)
select * from netflix where type = 'movie' and release_year = 2020;

#  4. Identify the longest movie
select * from netflix where type= 'Movie' and duration= (select max(duration) from netflix);

# 5. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

# 6.  Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix where director like '%Rajiv Chilaka%';

# 7. List all TV shows with more than 5 seasons
select * from netflix where type='TV Show' and duration like '5%';

# 8. Find each year and the average numbers of content release by India on netflix.
SELECT 
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
    COUNT(*) AS total_content,
    ROUND(
        (COUNT(*) * 100.0) / 
        (SELECT COUNT(*) FROM netflix WHERE country = 'India'),
        2
    ) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY year
ORDER BY avg_content_per_year DESC
LIMIT 5;

# 9.  List all movies that are documentaries
select * from netflix where listed_in like '%Documentaries';

# 10. Find all content without a director
select * from netflix where director is NULL;

# 11.  Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix
WHERE cast LIKE '%Salman Khan%'
  AND release_year > YEAR(CURDATE()) - 10;
  
# 12. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
# Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
with new_table
as (
select *, 
case when description like '%kill%' or description like '%violence%' then 'Bad_content' else 'Good_content'
end category
from netflix)
select category, count(*) as total_content from new_table group by 1;

# 13. Find the average duration of movies (in minutes) released after 2015.
SELECT AVG(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) AS avg_duration_minutes
FROM netflix
WHERE type = 'Movie'
  AND release_year > 2015;
  
# 14. Find the top 3 genres (listed_in) with the most TV Shows.
SELECT genre, COUNT(*) AS total_shows
FROM (
    SELECT show_id, TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre FROM netflix WHERE type = 'TV Show'
    UNION ALL
    SELECT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 2), ',', -1)) AS genre FROM netflix WHERE type = 'TV Show'
    UNION ALL
    SELECT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 3), ',', -1)) AS genre FROM netflix WHERE type = 'TV Show'
) t
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_shows DESC
LIMIT 3;

# 15. Find the top director in each country (the one who directed the most content).
WITH director_rank AS (
    SELECT 
        country,
        director,
        COUNT(*) AS total_content,
        RANK() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    WHERE director IS NOT NULL AND country IS NOT NULL
    GROUP BY country, director
)
SELECT country, director, total_content
FROM director_rank
WHERE rnk = 1
ORDER BY total_content DESC
LIMIT 10;












