/* TRIGGERS */

IF OBJECT_ID('dbo.tI_author') is not null DROP TRIGGER [dbo].[tI_author]
GO

	CREATE TRIGGER [dbo].tI_author ON author
	AFTER INSERT
	AS
	
	-- associate author to publisher
	UPDATE a SET a.pub_id = b.pub_id
		FROM author a
		JOIN book b (NOLOCK) ON a.book_id = b.book_id
		WHERE a.pub_id IS NULL

GO