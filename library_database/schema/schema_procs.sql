/* --- PROCS ---*/
-- all procs found / dropped if exists in order to recreate with master changes / updates


-- TO DO
-- update books due_date
-- relinquished book


-- check out book from specific branch
IF OBJECT_ID('dbo.spBookCheckOut') is not null DROP PROC [dbo].[spBookCheckOut] 
GO

	CREATE PROC [dbo].[spBookCheckOut]
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
		SELECT @retval 'retval', @err_mess 'err'


GO

-- return book to specific branch
IF OBJECT_ID('dbo.spBookReturn') is not null DROP PROC [dbo].[spBookReturn]
GO

	CREATE PROC [dbo].[spBookReturn]
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
		SELECT @retval 'retval', @err_mess 'err'

GO

-- create new book record
IF OBJECT_ID('dbo.spCreateBookRecord') is not null DROP PROC [dbo].[spCreateBookRecord]
GO

	CREATE PROC [dbo].[spCreateBookRecord]
	@bk_title varchar(50)
	, @branch_name varchar(25)
	, @author_name varchar(40)
	, @no_ofCopies int
	, @pub_name varchar(50)
	, @pub_address varchar(100) = null
	, @pub_phone varchar(14) = null  
	, @retval int = null OUTPUT
	, @err_mess varchar(250) = null OUTPUT
	AS
	DECLARE @pub_id int, @book_id int

	-- validate existing publisher record
	SELECT @pub_id = COALESCE(pub_id,0) FROM publisher 
		WHERE pub_name = @pub_name

	IF @@ROWCOUNT = 0
	BEGIN
		EXEC spCreatePublisherRecord @pub_name, @pub_address, @pub_phone, @retval = @retval OUTPUT, @err_mess = @err_mess OUTPUT

		IF COALESCE(@retval,1) < 1 GOTO ERROR
	END

	IF EXISTS(SELECT 1 FROM book WHERE bk_title = @bk_title AND pub_id = @pub_id)
	BEGIN
		SELECT @retval = -1, @err_mess = 'Book record for ' + @bk_title + ' from ' + @pub_name + ' already exists.'
		GOTO ERROR
	END
	ELSE BEGIN
		IF (COALESCE(@pub_id,0) = 0)
		BEGIN
			SELECT @pub_id = pub_id FROM publisher
				WHERE pub_name = @pub_name
		END

		INSERT book (bk_title, pub_id)
		VALUES (@bk_title, @pub_id)
		
		SELECT 1 FROM book b
			JOIN author a (NOLOCK) ON b.book_id = a.book_id
			WHERE bk_title = @bk_title AND author_name = @author_name

		IF @@ROWCOUNT = 0
		BEGIN
			EXEC spCreateAuthorRecord @author_name, @bk_title, @pub_name, @retval = @retval OUTPUT, @err_mess = @err_mess OUTPUT

			IF COALESCE(@retval,1) < 1 GOTO ERROR
		END
		ELSE BEGIN
			SELECT @retval = -1, @err_mess = 'Book record for ' + @bk_title + ' by ' + @author_name + ' already exists.'
			GOTO ERROR
		END

		SET @retval = 1
		GOTO SUCCESS
	END

	SUCCESS:
		return

	ERROR:
		SELECT @retval 'retval', @err_mess 'err'

GO

-- create new author record
IF OBJECT_ID('dbo.spCreateAuthorRecord') is not null DROP PROC [dbo].[spCreateAuthorRecord]
GO

	CREATE PROC [dbo].[spCreateAuthorRecord]
	@author_name varchar(40)
	, @bk_title varchar(50)
	, @pub_name varchar(50)
	, @retval int = null OUTPUT
	, @err_mess varchar(250) = null OUTPUT
	AS
	DECLARE @pub_id int, @book_id int

	-- validate existing records
	SELECT 1 FROM author a
		JOIN publisher p (NOLOCK) ON a.pub_id = p.pub_id
		WHERE author_name = @author_name AND pub_name = @pub_name

	IF @@ROWCOUNT > 0
	BEGIN
		SELECT @retval = -1, @err_mess = 'Author record for ' + @author_name + ' already exists for publisher ' + @pub_name + '.'
		GOTO ERROR
	END

	SELECT 1 FROM author a
		JOIN book b (NOLOCK) ON a.book_id = b.book_id
		WHERE author_name = @author_name AND bk_title = @bk_title

	IF @@ROWCOUNT > 0
	BEGIN
		SELECT @retval = -1, @err_mess = 'Book record for ' + @bk_title + ' by ' + @author_name + ' already exists.'
		GOTO ERROR
	END
	
	-- insert new record(s)
	SELECT @pub_id = COALESCE(pub_id,0) FROM publisher 
		WHERE pub_name = @pub_name

		IF @@ROWCOUNT = 0
		BEGIN
			EXEC spCreatePublisherRecord @pub_name, null, null, @retval = @retval OUTPUT, @err_mess = @err_mess OUTPUT

			IF (COALESCE(@retval,0) < 0) GOTO ERROR
		END

	SELECT @book_id = COALESCE(book_id,0) FROM book
		WHERE bk_title = @bk_title

	INSERT author (book_id, author_name, pub_id)
	VALUES (@book_id, @author_name, @pub_id)

	SET @retval = 1
	GOTO SUCCESS

	SUCCESS:
		return

	ERROR:
		SELECT @retval 'retval', @err_mess 'err'

GO

-- create new publisher record
IF OBJECT_ID('dbo.spCreatePublisherRecord') is not null DROP PROC [dbo].[spCreatePublisherRecord]
GO

	CREATE PROC [dbo].[spCreatePublisherRecord]
	@pub_name varchar(50)
	, @pub_address varchar(100) = null
	, @pub_phone varchar(14) = null
	, @retval int = null OUTPUT
	, @err_mess varchar(250) = null OUTPUT
	AS

	-- validate existing records
	SELECT 1 FROM publisher
		WHERE pub_name = @pub_name

	IF @@ROWCOUNT > 0
	BEGIN
		SELECT @retval = -1, @err_mess = 'Publisher record for ' + @pub_name + ' already exists.'
		GOTO ERROR
	END
	ELSE BEGIN
		-- insert new record
		INSERT publisher (pub_name, pub_address, pub_phone)
		VALUES (@pub_name, COALESCE(@pub_address,''), COALESCE(@pub_phone,''))

		SET @retval = 1
		GOTO SUCCESS
	END

	SUCCESS:
		return

	ERROR:
		SELECT @retval 'retval', @err_mess 'err'

GO

---- audit all books check-out / evaluate lost books + cost
--IF OBJECT_ID('dbo.spBookAudit') is not null DROP PROC [dbo].[spBookAudit]
--BEGIN
--	CREATE PROC [dbo].[spBookAudit]
--	-- TO DO
--	AS
	
--END

--GO