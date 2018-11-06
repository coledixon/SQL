/* SCHEMA FOR DRILL CODE VALIDATION (TECH ACADEMY) */
/* Copyright 2018 || Cole Dixon || All rights reserved */

IF NOT EXISTS(SELECT name FROM sys.databases WHERE name ='db_drills')
BEGIN
	CREATE DATABASE [db_drills]
END
GO

USE [db_drills]
GO


/* --- TABLES --- */

IF OBJECT_ID('dbo.course_main') is null
BEGIN
	-- course master 
	CREATE TABLE course_main (
			[course_key] int IDENTITY(1,1),
			[course_id] varchar(100) not null,
			[course_abbr] varchar(100) not null,
		PRIMARY KEY NONCLUSTERED 
		(
			[course_key] ASC
		) ON [PRIMARY]
	)
END

GO

IF OBJECT_ID('dbo.drill_main') is null
BEGIN
	-- drills master (by course)
	CREATE TABLE drill_main (
			[drill_key] int IDENTITY(1,1),
			[course_key] int not null,
			[page_no] int not null,
			[upd_date] datetime null,
			CONSTRAINT fk_drillCourse FOREIGN KEY (course_key) REFERENCES course_main(course_key),
		PRIMARY KEY NONCLUSTERED 
		(
			[drill_key] ASC
		) ON [PRIMARY]
	)

		ALTER TABLE drill_main 
			ADD CONSTRAINT def_updDate DEFAULT (GETDATE()) FOR [upd_date]
END

GO

IF OBJECT_ID('dbo.drill_params') is null
BEGIN
	-- drill requirements and assumptions
	CREATE TABLE drill_params (
			[drill_key] int not null,
			[reqs] varchar(MAX) not null,
			[upd_date] datetime null,
			CONSTRAINT fk_drillParams FOREIGN KEY (drill_key) REFERENCES drill_main(drill_key),
	)
		ALTER TABLE drill_params 
			ADD CONSTRAINT def_updDate DEFAULT (GETDATE()) FOR [upd_date]

		CREATE UNIQUE NONCLUSTERED INDEX natKey_params ON drill_params (
			[drill_key]
		)
END

GO

IF OBJECT_ID('dbo.drill_solution') is null
BEGIN
	-- drill solution(s)
	CREATE TABLE drill_solution (
			[drill_key] int not null,
			[solution] varchar(MAX) not null,
			[code] varchar(MAX) not null,
			[github_link] varchar(MAX) null,
			[upd_date] datetime null,
			CONSTRAINT fk_drillSolution FOREIGN KEY (drill_key) REFERENCES drill_main(drill_key),
	)
		ALTER TABLE drill_solution 
			ADD CONSTRAINT def_updDate DEFAULT (GETDATE()) FOR [upd_date]

		CREATE UNIQUE NONCLUSTERED INDEX natKey_solution ON drill_solution (
			[drill_key]
		)
END

GO

IF OBJECT_ID('dbo.keywords') is null
BEGIN
	-- keywords for searching
	CREATE TABLE keywords (
			[drill_key] int not null,
			[course_key] int not null,
			[keywords] varchar(MAX) null,
			CONSTRAINT fk_keywordDrill FOREIGN KEY (drill_key) REFERENCES drill_main(drill_key),
			CONSTRAINT fk_keywordCourse FOREIGN KEY (course_key) REFERENCES course_main(course_key),
	)
		CREATE UNIQUE NONCLUSTERED INDEX natKey_keyword ON keywords (
			[drill_key],
			[course_key]
		)
END

GO

