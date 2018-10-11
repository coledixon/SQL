/* DATA POPULATION FOR SQL LIBRARY PROJECT */

USE db_library
GO

-- publisher records
IF NOT EXISTS(SELECT 1 FROM publisher)
BEGIN
	INSERT INTO publisher (pub_name, pub_address, pub_phone)
	VALUES
		('Henry Holt & Co.','175 Fifth Avenue, New York, NY 10010', '888-330-8477'),
		('Chapman & Hall','115 5th Avenue Floor 4, New York, NY 10003', '212-564-1060'),
		('Iron Crown Enterprises','37 Fulbourn Road, Cambridge, United Kingdom', '123-456-7890'),
		('Macmillan Publishers','16365 James Madison Highway, Gordonsville, VA 22942','888-330-8477'),
		('Little, Brown & Company','1290 Avenue Of The Americas, New York, NY 10104', '212-364-1100'),
		('George Newnes','123 Oldstown Road, London, England', '541-379-6394'),
		('Viking Press','375 Hudson Street, New York, NY 10014', '212-366-2000'),
		('L.C. Page & Co.','245 Peachtree Center Avenue, Atlanta, GA 30303, USA', '404-669-9400'),
		('Penguin Books','375 Hudson Street, New York, NY 10014', '212-366-2000'),
		('Anchor Books','1745 Broadway, New York, NY 10019', '212-940-7390'),
		('Bloomsbury Publishing', '1385 Broadway, New York, NY 10018', '212-419-5300'),
		('HarperCollins','195 Broadway, New York, NY 10007', '212-207-7000'),
		('J.B. Lippincott & Co.','2001 Market Street, Philadelphia, PA 19103','215-521-8300'),
		('Scholastic Co.', '557 Broadway, New York City, New York 10012','1-800-724-6527'),
		('William Heinemann', 'P. O. Box 6926, Portsmouth, NH 03802-6926', '603-431-7894' ),
		('Harper & Row', '195 Broadway, New York, NY 10007', '212-207-7000'),
		('Penguin Putnam', '375 Hudson Street, New York, NY 10014', '212-366-2000'),
		('Schribner','153-157 Fifth Avenue, New York City', '212-632-4915'),
		('Random House','1745 Broadway, New York, NY 10019', '212-940-7390'),
		('Simon & Schuster','1230 Avenue of the Americas, New York, NY 10020','212-698-7000')
END

GO

-- borrower records
IF NOT EXISTS(SELECT 1 FROM borrower)
BEGIN
	INSERT borrower (bwr_name, bwr_address, bwr_phone)
	VALUES
		('John Doe','Portland, OR', '123-456-7890'),
		('Jane Smith','Tigard, OR', '123-456-7890'),
		('Chris Johnson','Hillsboro, OR', '123-456-7890'),
		('Michael Reid','Portland, OR', '123-456-7890'),
		('Sarah Dotson','Tualatin, OR', '123-456-7890'),
		('Kyle Steward','Beaverton, OR', '123-456-7890'),
		('Madison Jackson','Portland, OR', '123-456-7890'),
		('Peter Ross','Portland, OR', '123-456-7890'),
		('Nick Strong', 'Beaverton, OR', '123-456-7890')
END

GO

-- library branches
IF NOT EXISTS (SELECT 1 FROM library_branch)
BEGIN
	INSERT library_branch (branch_name, branch_address)
	VALUES
		('Central', '123 Main Street'),
		('Sharpstown', '678 Cutting Court'),
		('Mountain', '459 Rocky Road'),
		('Grassburg', '260 Country Lane'),
		('Hazelden', '22 Angler Ave'),
		('Buckets','5154 Orchard Pkwy')
END

GO

-- book records (randomly associating to a publisher)
IF NOT EXISTS(SELECT 1 FROM book)
BEGIN
	INSERT book (bk_title, pub_id)
	VALUES
		('The Lost Tribe', FLOOR(RAND()*(20-1+1))+1),
		('A Tale of Two Cities', FLOOR(RAND()*(20-1+1))+1),
		('The Lord of the Rings', FLOOR(RAND()*(20-1+1))+1),
		('The Adventures of Alice in Wonderland', FLOOR(RAND()*(20-1+1))+1),
		('The Catcher in the Rye', FLOOR(RAND()*(20-1+1))+1),
		('The Adventures of Sherlock Holmes', FLOOR(RAND()*(20-1+1))+1),
		('Cujo', FLOOR(RAND()*(20-1+1))+1),
		('Anne of Green Gables', FLOOR(RAND()*(20-1+1))+1),
		('Eat, Pray, Love', FLOOR(RAND()*(20-1+1))+1),
		('The Shining', FLOOR(RAND()*(20-1+1))+1),
		('Harry Potter & the Sorcerer''s Stone', FLOOR(RAND()*(20-1+1))+1),
		('Charlotte''s Web', FLOOR(RAND()*(20-1+1))+1),
		('To Kill A Mockingbird', FLOOR(RAND()*(20-1+1))+1),
		('The Hunger Games', FLOOR(RAND()*(20-1+1))+1),
		('Things Fall Apart', FLOOR(RAND()*(20-1+1))+1),
		('Where The Wild Things Are', FLOOR(RAND()*(20-1+1))+1),
		('The Very Hungry Caterpillar', FLOOR(RAND()*(20-1+1))+1),
		('The Old Man and the Sea', FLOOR(RAND()*(20-1+1))+1),
		('The Cat in the Hat', FLOOR(RAND()*(20-1+1))+1),
		('Pride and Predjudice', FLOOR(RAND()*(20-1+1))+1),
		('The Lost Tribe 2: Even Loster', FLOOR(RAND()*(20-1+1))+1)
END

GO

-- author records
IF NOT EXISTS(SELECT 1 FROM author)
BEGIN
	INSERT author (book_id, author_name)
	VALUES
		(1, 'Edward Marriot'),
		(11, 'Charles Dickens'),
		(21, 'JRR Tolkien'),
		(31, 'Lewis Carroll'),
		(41, 'J.D. Salinger'),
		(51, 'Sir Arthur Conan Doyle'),
		(61, 'Stephen King'),
		(71, 'Lucy Maud Montgomery'),
		(81, 'Elizabeth Gilbert'),
		(91, 'Stephen King'),
		(101, 'JK Rowling'),
		(111, 'E.B.White'),
		(121, 'Harper Lee'),
		(131, 'Suzanne Collins'),
		(141, 'Chinua Achebe'),
		(151, 'Maurice Sendak'),
		(161, 'Eric Carle'),
		(171, 'Ernest Hemmingway'),
		(181, 'Dr. Seuss'),
		(191, 'Jane Austen'),
		(201, 'Edward Marriot')

	-- associate author to publisher
	UPDATE a SET a.pub_id = b.pub_id
		FROM author a
		JOIN book b (NOLOCK) ON a.book_id = b.book_id

END

GO

-- inventory records for branches (randomly associating to branches and setting inventory amount)
IF NOT EXISTS(SELECT 1 FROM book_copies)
BEGIN
	INSERT book_copies (book_id, branch_id, book_condition, no_ofCopies)
	VALUES
		(1, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1), 
		(11, FLOOR(RAND()*(6-1+1))+1, 'worn', FLOOR(RAND()*(10-1+1))+1),
		(151, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(101, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(181, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(201, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(21, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(111, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(71, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(41, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(91, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(111, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(131, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(11, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(201, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(41, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(21, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(121, FLOOR(RAND()*(6-1+1))+1, 'worn', FLOOR(RAND()*(10-1+1))+1),
		(1, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(61, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(71, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(151, FLOOR(RAND()*(6-1+1))+1, 'worn', FLOOR(RAND()*(10-1+1))+1),
		(161, FLOOR(RAND()*(6-1+1))+1, 'worn', FLOOR(RAND()*(10-1+1))+1),
		(111, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(181, FLOOR(RAND()*(6-1+1))+1, 'pre-owned', FLOOR(RAND()*(10-1+1))+1),
		(191, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(111, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(131, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(111, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(31, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(81, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(71, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(101, FLOOR(RAND()*(6-1+1))+1, 'refurbished', FLOOR(RAND()*(10-1+1))+1),
		(41, FLOOR(RAND()*(6-1+1))+1, 'worn', FLOOR(RAND()*(10-1+1))+1),
		(121, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(151, FLOOR(RAND()*(6-1+1))+1, 'worn', FLOOR(RAND()*(10-1+1))+1),
		(141, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(1, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1),
		(61, FLOOR(RAND()*(6-1+1))+1, 'worn', FLOOR(RAND()*(10-1+1))+1),
		(91, FLOOR(RAND()*(6-1+1))+1, 'new', FLOOR(RAND()*(10-1+1))+1)
END

GO

-- set master tran id
IF NOT EXISTS(SELECT 1 FROM tran_id)
BEGIN
	INSERT tran_id (tran_id)
	VALUES (100)
END

GO