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


-- 5
-- Select all even number records from table id_records. Then select all odd number records
SELECT * -- evens
FROM id_records
	WHERE id % 2 = 0

SELECT * -- odds
FROM id_records
	WHERE id % 2 != 0


-- 6
/*

	SELECT * FROM users;

		user_id  username
		1        John Doe         
		2        Jane Don   
		3        Alice Jones
		4        Lisa Romero

	SELECT * FROM training_details;

		user_training_id  user_id  training_id  training_date
		1                 1        1            "2015-08-02"
		2                 2        1            "2015-08-03"
		3                 3        2            "2015-08-02"
		4                 4        2            "2015-08-04"
		5	              2        2            "2015-08-03"
		6                 1        1            "2015-08-02"
		7                 3        2            "2015-08-04"
		8                 4        3            "2015-08-03"
		9                 1        4            "2015-08-03"
		10                3        1            "2015-08-02"
		11                4        2            "2015-08-04"
		12                3        2            "2015-08-02"
		13                1        1            "2015-08-02"
		14                4        3            "2015-08-03"

	Write a query to to get the list of users who took the a training lesson more than once in the same day, grouped by user and training lesson, each ordered from the most recent lesson date to oldest date.

*/
SELECT u.user_id, username, training_id, training_date, COUNT(user_training_id) as count
FROM users u 
	JOIN training_details td (NOLOCK) ON u.user_id = td.user_id
		GROUP BY u.user_id, username, training_id, training_date
		HAVING COUNT(user_training_id) > 1
		ORDER BY training_date DESC


-- 7
-- Write a query to add 2 when field (Nmbr) value equals 0 and add 3 when field (Nmbr) value equals 1. TBL.Nmbr (1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1)
UPDATE TBL 
SET Nmbr = CASE WHEN Nmber = 0 THEN Nmbr+2 ELSE Nmbr+3 END


-- 8
-- For each invoice, show the Invoice ID, the billing date, the customer’s name, and the name of the customer who referred that customer (if any). The list should be ordered by billing date.
SELECT i.Id, i.BillingDate, c.Name, ref.Name as Referredby
FROM invoices i 
	JOIN customers c (NOLOCK) ON i.Id = c.Id
	LEFT JOIN customers ref (NOLOCK) ON c.ReferredBy = ref.Id
		ORDER BY i.BillilngDate