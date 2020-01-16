

SELECT * FROM vcontact_data_all
ORDER BY contact_id ASC

SELECT * FROM vcontact_audit_all
ORDER BY audit_key ASC

select * from audit_contact
select * from audit_info

select * from contact_main
select * from contact_address
select * from contact_phone
select * from contact_email
select * from contact_website

dbcc opentran

kill 62

BEGIN TRAN
exec sp_executesql N'INSERT INTO vcontact_data_all (contact_id, first_name, last_name, address, city, state, zip, email_personal, email_work, phone_home, phone_cell, phone_work, website, github) VALUES (@contact_id, @first_name, @last_name, @address, @city, @state, @zip, @email_personal, @email_work, @phone_home, @phone_cell, @phone_work, @website, @github)',N'@contact_id int,@first_name nvarchar(4),@last_name nvarchar(5),@address nvarchar(23),@city nvarchar(11),@state nvarchar(2),@zip int,@email_personal nvarchar(26),@email_work nvarchar(34),@phone_home nvarchar(2),@phone_cell nvarchar(12),@phone_work nvarchar(8),@website nvarchar(10),@github nvarchar(28)',@contact_id=3,@first_name=N'Cole',@last_name=N'Dixon',@address=N'14770 Orchard Pkwy #222',@city=N'Westminster',@state=N'CO',@zip=80023,@email_personal=N'colefromportland@gmail.com',@email_work=N'denverdean@learncodinganywhere',@phone_home=N'()',@phone_cell=N'(503)7069821',@phone_work=N'(503)503',@website=N'google.com',@github=N'https://github.com/coledixon'

ROLLBACK TRAN

INSERT INTO vcontact_data_all VALUES (@contact_id, @first_name, @last_name, @address, @city, @state, @zip, @email_personal, @email_work, @phone_home, @phone_cell, @phone_work, @website, @github)

@contact_id=2,
@first_name=N'Cole',
@last_name=N'Dixon',
@address=N'14770 Orchard Pkwy #222'
,@city=N'Westminster',
@state=N'CO',
@zip=80023,
@email_personal=N'colefromportland@gmail.com',
@email_work=N'denverdean@learncodinganywhere',
@phone_home=N'()',
@phone_cell=N'(503)7069821',
@phone_work=N'(503)503',
@website=N'google.com',
@github=N'https://github.com/coledixon'

select * from vcontact_data_all

select * from contact_main
select * from contact_address
select * from contact_phone
select * from contact_email
select * from contact_website
