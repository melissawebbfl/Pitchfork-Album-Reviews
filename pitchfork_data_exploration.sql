/*
	Pitchfork Album Reviews - Data Exploration
	Melissa Webb
    
    Data set source: https://www.kaggle.com/nolanbconaway/pitchfork-data
    Description: This database contains information related to over 18,000 music album reviews posted on a website called Pitchfork between the years 1999 and 2017.
    The following tables are contained in the database: reviews, artists, genres, labels

	Skills used: CTE's, joins, aggregate functions, subqueries, partition by, group by 
*/


-- Who were the most reviewed artists?

SELECT artist,
	   COUNT(artist) as review_count
FROM artists
GROUP BY artist
ORDER BY review_count DESC, 
		 artist
LIMIT 10;


-- Which artists scored the highest on average?

SELECT a.artist,
       ROUND(AVG(r.score), 2) AS avg_score
FROM artists AS a
INNER JOIN reviews AS r
	USING (reviewid)
GROUP BY a.artist
ORDER BY avg_score DESC, 
		 artist
LIMIT 10;


-- Who were the highest rated artists by year?

WITH scores_by_year AS(
	SELECT year(r.pub_date) AS year,
		   a.artist,
		   ROUND(AVG(r.score), 2) AS avg_score,
           MAX(AVG(r.score)) OVER (PARTITION BY year(r.pub_date)) AS highest_avg_score
	FROM reviews AS r
	JOIN artists AS a
		USING (reviewid)
	GROUP BY year, 
			 a.artist
	ORDER BY year DESC, 
			 avg_score DESC, 
             a.artist
)
SELECT year, 
	   artist,
       avg_score 
FROM scores_by_year
WHERE avg_score = highest_avg_score;
       

-- How many reviews were posted each year?

SELECT year(pub_date) AS year,
	   COUNT(*) AS total_reviews
FROM reviews
GROUP BY year
ORDER BY year;
  

-- On which day of the week were reviews posted the most?

SELECT DAYNAME(pub_date) AS DAY,
       COUNT(*) AS total_reviews,
       CONCAT(ROUND((COUNT(*) * 100.0) /
                      (SELECT COUNT(*)
                       FROM reviews)), '%') AS percentage_of_reviews
FROM reviews
GROUP BY DAY
ORDER BY total_reviews DESC;


-- What genres were reviewed the most each year?

WITH genres_by_year AS(
	SELECT year(r.pub_date) AS year,
		   g.genre,
		   COUNT(*) AS total_reviews,
		   MAX(COUNT(*)) OVER (PARTITION BY year(r.pub_date)) AS highest_total_reviews
	FROM genres AS g
	INNER JOIN reviews AS r
		USING (reviewid)
	WHERE g.genre IS NOT NULL
	GROUP BY year,
			 g.genre
	ORDER BY year DESC,
			 total_reviews DESC
)
SELECT year,
	   genre,
       total_reviews
FROM genres_by_year
WHERE total_reviews = highest_total_reviews;


-- What was the most reviewed genre for each label?

WITH genres_by_label AS(
	SELECT l.label,
		   g.genre,
		   COUNT(*) AS total_reviews,
		   MAX(COUNT(*)) OVER (PARTITION BY l.label) AS highest_total_reviews
	FROM labels AS l
	INNER JOIN genres AS g
		USING (reviewid)
	INNER JOIN reviews AS r 
		USING (reviewid)
	WHERE l.label IS NOT NULL 
		AND g.genre IS NOT NULL
	GROUP BY label, 
			 genre
	 ORDER BY label,
			  total_reviews DESC
)
SELECT label,
	   genre,
       total_reviews
FROM genres_by_label
WHERE total_reviews = highest_total_reviews;