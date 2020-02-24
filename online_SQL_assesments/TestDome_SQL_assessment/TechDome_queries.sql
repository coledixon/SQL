-- TESTDOME SQL TECH ASSESSMENT
-- QUERIES COPYRIGHT: Cole Dixon 2020


-- 1
/*
	Given the following data defintion, select city names in descending order

	TABLE cities
		id INT NOT NULL PRIMARY KEY,
		name VARCHAR(30) NOT NULL

*/
-- Write only the SQL statement that solves the problem and nothing else.

SELECT name
FROM cities
  ORDER BY name DESC


-- 2
/*
	Given the following data definition, write a query that returns the number of students whose first name is John.

	TABLE students
		id INT PRIMARY KEY,
		firstName VARCHAR(30) NOT NULL,
		lastName VARCHAR(30) NOT NULL

*/
-- Write only the SQL statement that solves the problem and nothing else.
SELECT COUNT(firstName) as johns
FROM students
  WHERE firstName = 'John'


-- 3
/*


*/
-- Write only the SQL statement that solves the problem and nothing else.
UPDATE enrollments
SET year = 2015
  WHERE id BETWEEN 20 AND 100


-- 4
/*


*/
-- Write only the SQL statement that solves the problem and nothing else.
SELECT userId, AVG(duration)
FROM sessions
	GROUP BY userId
	HAVING COUNT(userId) > 1