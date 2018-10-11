/* --- VIEWS --- */
--IF OBJECT_ID('dbo.vbooks_out') is null 
--BEGIN
--	-- all books currently out
--	CREATE VIEW vbooks_out
--	AS
--	SELECT bk_title, date_out, date_due
--		FROM books b
--		JOIN book_loans bl (NOLOCK) ON a.book_id = bl.book_id
--		GROUP BY bk_title, date_out, date_due
--		HAVING date_due > GETDATE()

--END

--GO