/* SCHEMA FOR SQL LIBRARY PROJECT */


IF NOT EXISTS(SELECT name FROM sys.databases WHERE name ='db_library')
BEGIN
	CREATE DATABASE [db_library]
END

GO

USE db_library
GO

/* --- TABLES --- */
IF OBJECT_ID('dbo.library_branch') is null
BEGIN
	-- library branches
	CREATE TABLE library_branch (
			[branch_id] int IDENTITY(0001,1),
			[branch_name] varchar(25) not null,
			[branch_address] varchar(30) not null,
		PRIMARY KEY NONCLUSTERED 
		(
			[branch_id] ASC
		) ON [PRIMARY]
	)
END

GO

IF OBJECT_ID('dbo.borrower') is null
BEGIN
	-- borrowers
	CREATE TABLE borrower (
			[card_no] int IDENTITY(0001,1),
			[bwr_name] varchar(40) not null,
			[bwr_address] varchar(30) not null,
			[bwr_phone] varchar(12) not null,
		PRIMARY KEY NONCLUSTERED 
		(
			[card_no] ASC
		) ON [PRIMARY]
	)

		CREATE UNIQUE NONCLUSTERED INDEX natKey_borrower ON borrower (
			[card_no],
			[bwr_name]
		)
END

GO

IF OBJECT_ID('dbo.publisher') is null
BEGIN
	-- publishers
	CREATE TABLE publisher (
			[pub_id] int IDENTITY(0001,1) not null,
			[pub_name] varchar(50) not null,
			[pub_address] varchar(30) null,
			[pub_phone] varchar(12) null,
		PRIMARY KEY NONCLUSTERED 
		(
			[pub_id] ASC
		) ON [PRIMARY]
	)
END

GO

IF OBJECT_ID('dbo.book') is null
BEGIN
	-- book records
	CREATE TABLE book (
			[book_id] int IDENTITY(0001,1) not null,
			[bk_title] varchar(50) not null,
			[pub_id] int not null,
		CONSTRAINT fk_bkPublisher FOREIGN KEY (pub_id) REFERENCES publisher(pub_id),
		PRIMARY KEY NONCLUSTERED 
		(
			[book_id] ASC
		) ON [PRIMARY]
	)

		CREATE UNIQUE NONCLUSTERED INDEX natKey_book ON book (
			[book_id],
			[bk_title]
		)
END

GO

IF OBJECT_ID('dbo.author') is null
BEGIN
	-- authors
	CREATE TABLE author (
			[book_id] int not null,
			[author_name] varchar(40) not null,
			[pub_id] int null,
		CONSTRAINT fk_authPublisher FOREIGN KEY (pub_id) REFERENCES publisher(pub_id),
		CONSTRAINT fk_authBook FOREIGN KEY (book_id) REFERENCES book(book_id)
	)
END

GO

IF OBJECT_ID('dbo.book_loans') is null
BEGIN
	-- book loans and transactions
	CREATE TABLE book_loans (
			[book_id] int not null,
			[branch_id] int not null,
			[card_no] int not null,
			[date_out] datetime not null,
			[date_due] datetime not null,
			[status] int not null,
		CONSTRAINT fk_loanBook FOREIGN KEY (book_id) REFERENCES book(book_id),
		CONSTRAINT fk_loanBranch FOREIGN KEY (branch_id) REFERENCES library_branch(branch_id),
		CONSTRAINT fk_loanBorrower FOREIGN KEY (card_no) REFERENCES borrower(card_no),
	)

		ALTER TABLE book_loans 
			ADD CONSTRAINT def_dateDue DEFAULT (DATEADD(day,5,GETDATE())) FOR [date_due]
		ALTER TABLE book_loans 
			ADD CONSTRAINT def_status DEFAULT (1) FOR [status]

		CREATE UNIQUE NONCLUSTERED INDEX natKey_loans ON book_loans (
			[card_no],
			[book_id],
			[branch_id]
		)
END

GO

IF OBJECT_ID('dbo.book_copies') is null
BEGIN
	-- book copies and records
	CREATE TABLE book_copies (
			[book_id] int not null,
			[branch_id] int not null,
			[book_condition] varchar(50) null,
			[no_ofCopies] int not null,
		CONSTRAINT fk_copyBook FOREIGN KEY (book_id) REFERENCES book(book_id),
		CONSTRAINT fk_copyBranch FOREIGN KEY (branch_id) REFERENCES library_branch(branch_id),
	)

		ALTER TABLE book_copies 
			ADD CONSTRAINT def_copies DEFAULT (0) FOR [no_ofCopies]

		CREATE UNIQUE NONCLUSTERED INDEX natKey_copies ON book_copies(
			[book_id],
			[branch_id]
		)
END

GO

/* --- VIEWS --- */
IF OBJECT_ID('dbo.vbooks_out') is null 
BEGIN
	-- all books currently out
	CREATE VIEW vbooks_out
	AS
	SELECT bk_title, date_out, date_due
		FROM books b
		JOIN book_loans bl (NOLOCK) ON a.book_id = bl.book_id
		GROUP BY bk_title, date_out, date_due
		HAVING date_due > GETDATE()

END

GO


/* --- PROCS ---*/
-- TO DO
-- update books duedate
-- returned book
-- checked out book