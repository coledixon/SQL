/* TESTING PROC FUNCTIONAITY */

select * from book 
-- 91 = the shining
select * from library_branch 
-- 5 = hazelden / 6 = buckets
select * from borrower
-- 109 = Jane Smith

-- test check out book
BEGIN TRAN

select a.no_ofCopies, b.branch_name from book_copies a
JOIN library_branch b (NOLOCK) ON a.branch_id = b.branch_id
WHERE book_id = 91
select * from book_loans

exec spBookCheckOut 'The Shining', 'Buckets', 109

select a.no_ofCopies, b.branch_name from book_copies a
JOIN library_branch b (NOLOCK) ON a.branch_id = b.branch_id
WHERE book_id = 91
select * from book_loans

ROLLBACK TRAN

-- test return book
BEGIN TRAN

select a.no_ofCopies, b.branch_name from book_copies a
JOIN library_branch b (NOLOCK) ON a.branch_id = b.branch_id
WHERE book_id = 91
select * from book_loans

exec spBookReturn 'The Shining', 'Hazelden', 109

select a.no_ofCopies, b.branch_name from book_copies a
JOIN library_branch b (NOLOCK) ON a.branch_id = b.branch_id
WHERE book_id = 91
select * from book_loans

ROLLBACK TRAN

-- test create new book / publisher / author (stacked procs)
BEGIN TRAN

select * from book where bk_title = 'test'
select * from publisher where pub_name = 'testest'
select * from author where author_name = 'test test'

exec spcreatebookrecord 'test', 'buckets', 'test test', 4, 'testtest', null, null

select * from book where bk_title = 'test'
select * from publisher where pub_name = 'testtest'
select * from author where author_name = 'test test'

ROLLBACK TRAN