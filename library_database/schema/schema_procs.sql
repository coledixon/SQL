/* --- PROCS ---*/
-- TO DO
-- update books due_date
-- relinquished book
IF OBJECT_ID('dbo.spBookCheckOut') is null
BEGIN
	CREATE PROC [dbo]. [spBookCheckOut]
	@bk_title varchar(50)
	, @branch_name varchar(25)
	, @card_no int
	, @retval int = null OUTPUT
	, @err_mess varchar(250) = null OUTPUT
	AS
	-- handle logic for checking out a book
	DECLARE @book_id int, @branch_id int, @tran_id int, @no_ofCopies int
	SET @retval = 0 -- default return value

	SELECT @book_id = book_id 
		FROM book WHERE bk_title = @bk_title

		IF (COALESCE(@book_id,0)=0)
		BEGIN
			SELECT @err_mess = 'ERROR RETREIVING BOOK ID', @retval = -1
			GOTO ERROR
		END
	
	SELECT @branch_id = branch_id 
		FROM library_branch WHERE branch_name = @branch_name

		IF (COALESCE(@branch_id,0)=0)
		BEGIN
			SELECT @err_mess = 'ERROR RETREIVING BRANCH ID', @retval = -1
			GOTO ERROR
		END

	IF NOT EXISTS(SELECT 1 FROM book_copies 
		WHERE branch_id = @branch_id AND book_id = @book_id) -- add book record if not exist at branch
	BEGIN
		INSERT book_copies (book_id, branch_id, no_ofCopies)
		VALUES (@book_id, @branch_id, 1)
	END

	SELECT @no_ofCopies = no_ofCopies
		FROM book_copies WHERE book_id = @book_id AND branch_id = @branch_id

	SELECT @tran_id = tran_id
		FROM tran_id

	INSERT book_loans (tran_id, book_id, branch_id, card_no, date_due, status)
	VALUES (@tran_id, @book_id, @branch_id, @card_no, DATEADD(day,5,GETDATE()), 1)

	UPDATE tran_id SET tran_id = (@tran_id + 1) -- increment tran_id

	IF (COALESCE(@no_ofCopies,0) > 0) -- update copies on-hand
	BEGIN
		UPDATE book_copies SET no_ofCopies = (@no_ofCopies - 1)
			WHERE branch_id = @branch_id AND @book_id = @book_id
	END

	SUCCESS:
		IF (COALESCE(@retval,0)=0) SET @retval = 1
		RETURN

	ERROR:

END

GO

IF OBJECT_ID('dbo.spBookReturn') is null
BEGIN
	CREATE PROC [dbo]. [spBookReturn]
	@bk_title varchar(50)
	, @branch_name varchar(25)
	, @card_no int
	, @condition varchar(50) = null
	, @retval int = null OUTPUT
	, @err_mess varchar(250) = null OUTPUT
	AS
	-- handle logic for book returns
	DECLARE @book_id int, @branch_id int, @tran_id int, @no_ofCopies int
	SET @retval = 0 -- default return value

	SELECT @book_id = book_id 
		FROM book WHERE bk_title = @bk_title

		IF (COALESCE(@book_id,0)=0)
		BEGIN
			SELECT @err_mess = 'ERROR RETREIVING BOOK ID', @retval = -1
			GOTO ERROR
		END
	
	SELECT @branch_id = branch_id 
		FROM library_branch WHERE branch_name = @branch_name

		IF (COALESCE(@branch_id,0)=0)
		BEGIN
			SELECT @err_mess = 'ERROR RETREIVING BRANCH ID', @retval = -1
			GOTO ERROR
		END

	IF NOT EXISTS(SELECT 1 FROM book_copies 
		WHERE branch_id = @branch_id AND book_id = @book_id) -- add book record if not exist at branch
	BEGIN
		INSERT book_copies (book_id, branch_id, no_ofCopies)
		VALUES (@book_id, @branch_id, 0)
	END

	SELECT @no_ofCopies = no_ofCopies
		FROM book_copies WHERE book_id = @book_id AND branch_id = @branch_id
	
	-- remove tran record
	DELETE FROM book_loans 
		WHERE branch_id = @branch_id 
			AND book_id = @book_id AND card_no = @card_no

	IF (COALESCE(@no_ofCopies,0) >= 0) -- update copies on-hand
	BEGIN
		UPDATE book_copies SET no_ofCopies = (@no_ofCopies + 1), book_condition = COALESCE(@condition,'')
			WHERE branch_id = @branch_id AND @book_id = @book_id
	END

	SUCCESS:
		IF (COALESCE(@retval,0)=0) SET @retval = 1
		RETURN

	ERROR:

END

GO

IF OBJECT_ID('dbo.spBookAudit') is null
BEGIN
	CREATE PROC [dbo].[spBookAudit]
	-- TO DO
	-- audit all books and evaluate lost books / cost
	
END

GO