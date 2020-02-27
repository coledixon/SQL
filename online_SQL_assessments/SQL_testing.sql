-- VARIOUS ONLINE SQL TECH ASSESSMENTS
-- QUERIES COPYRIGHT: Cole Dixon 2020

-- 1
-- Create an SQL query that shows the TOP 3 authors who sold the most books in total
SELECT TOP 3 author_name, SUM(sold_copies) as copies_sold
FROM authors a
	JOIN books b on a.book_name = b.book_name
		GROUP BY author_name
		ORDER BY copies_sold DESC


-- 2
-- Write an SQL query to find out how many users inserted more than 1000 but less than 2000 images in their presentations
SELECT COUNT(*) FROM
	(SELECT user_id, COUNT(event_date_time) AS image_per_user
		FROM event_log
			GROUP BY user_id) AS image_per_user
	WHERE image_per_user < 2000 AND image_per_user > 1000


-- 3
-- Print every department where the average salary per employee is lower than $500
SELECT department_name, AVG(salaries.salary) AS avg_salaries
FROM employees e
	JOIN salaries s ON e.employee_id = s.employee_id
		GROUP BY department_name
		HAVING AVG(s.salary) < 500


-- 4
-- Change the year value to 2015 for all students with ids between 20 - 100
UPDATE enrollments SET year = 2015
WHERE id BETWEEN 20 AND 100

