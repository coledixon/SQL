/* SCHEMA FOR DRILL CODE VALIDATION (TECH ACADEMY) */
/* Copyright 2018 || Cole Dixon || All rights reserved */

USE [db_drills]
GO


/* --- VIEWS --- */
-- drop and create in case of master schema changes

-----
--- VIEW for course associated drills
-----
IF OBJECT_ID('dbo.vcourse_drills') is not null DROP VIEW [dbo].[vcourse_drills]
GO

	CREATE VIEW [dbo].[vcourse_drills]
	AS

	SELECT course_id, course_abbr, page_no, reqs
		FROM course_main c
		LEFT JOIN drill_main d (NOLOCK) ON c.course_key = d.course_key
		LEFT JOIN drill_params p (NOLOCK) ON d.drill_key = p.drill_key

	GO

-----
--- VIEW for drill solutions
-----
IF OBJECT_ID('dbo.vdrill_solution') is not null DROP VIEW [dbo].[vdrill_solution]
GO

	CREATE VIEW [dbo].[vdrill_solution]
	AS

	SELECT page_no, reqs, solution, code, github_link
		FROM drill_main d
		LEFT JOIN drill_params p (NOLOCK) ON d.drill_key = p.drill_key
		LEFT OUTER JOIN drill_solution s (NOLOCK) ON p.drill_key = s.drill_key 

	GO

-----
--- VIEW keyword searching by course / drill
-----
IF OBJECT_ID('dbo.vkeywords') is not null DROP VIEW [dbo].[vkeywords]
GO

	CREATE VIEW [dbo].[vkeywords]
	AS

	SELECT course_id, course_abbr, page_no, keywords
		FROM course_main c
		LEFT JOIN drill_main d (NOLOCK) ON c.course_key = d.course_key
		LEFT JOIN keywords k (NOLOCK) ON c.course_key = k.course_key AND d.drill_key = k.drill_key

	GO
