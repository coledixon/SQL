-- TESTDOME SQL TECH ASSESSMENT
-- QUERIES COPYRIGHT: Cole Dixon 2020


-- 1
/*
	Given the following data defintion, select city names in descending order

	TABLE cities
		id INTEGER NOT NULL PRIMARY KEY,
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
		id INTEGER PRIMARY KEY,
		firstName VARCHAR(30) NOT NULL,
		lastName VARCHAR(30) NOT NULL

*/
-- Write only the SQL statement that solves the problem and nothing else.
SELECT COUNT(firstName) as johns
FROM students
	WHERE firstName = 'John'


-- 3
/*
	A table containing the students enrolled in a yearly course has incorrect data in records with ids 20-100.

	TABLE enrollments
		id INTEGER NOT NULL PRIMARY KEY,
		year INTEGER NOT NULL,
		studentId INTEGER NOT NULL

	Write a query that updates the 'year' field of every faulty record to 2015.

*/
-- Write only the SQL statement that solves the problem and nothing else.
UPDATE enrollments SET year = 2015
WHERE id BETWEEN 20 AND 100


-- 4
/*
	App usage data is kept in the following table:

	TABLE sessions
		id INTEGER PRIMARY KEY,
		userId INTEGER NOT NULL,
		duration DECIMAL NOT NULL

	Write a query that selects the userId and average session duration for each user who has more than one session.

*/
-- Write only the SQL statement that solves the problem and nothing else.
SELECT userId, AVG(duration)
FROM sessions
	GROUP BY userId
	HAVING COUNT(userId) > 1


-- 5
/*
	Information about pets is kept in two separate tables:

	TABLE dogs
		id INTEGER NOT NULL PRIMARY KEY,
		name VARCHAR(50) NOT NULL

	TABLE cats
		id INTEGER NOT NULL PRIMARY KEY,
		name VARCHAR(50) NOT NULL

	Write a query that selects all distinct pet names.

*/
-- Write only the SQL statement that solves the problem and nothing else.
SELECT name
FROM dogs
	UNION
SELECT name
FROM cats