exec usp_String_or_binary_data_truncated 'INSERT INTO vcontact_data_all VALUES (@contact_id, @first_name, @last_name, @address, @city, @state, @zip, @email_personal, @email_work, @phone_home, @phone_cell, @phone_work, @website, @github)'N'@contact_id int,@first_name nvarchar(4),@last_name nvarchar(5),@address nvarchar(23),@city nvarchar(11),@state nvarchar(2),@zip int,@email_personal nvarchar(26),@email_work nvarchar(34),@phone_home nvarchar(2),@phone_cell nvarchar(12),@phone_work nvarchar(8),@website nvarchar(10),@github nvarchar(28)'