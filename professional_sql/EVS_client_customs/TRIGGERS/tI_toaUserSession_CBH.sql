
CREATE TRIGGER [dbo].[tI_toaUserSession_CBH] ON [dbo].[toaUserSession] 
FOR INSERT, UPDATE AS
-- 02/20/17 CD: update current transaction user session
BEGIN

	SELECT 1 FROM inserted
	
	IF @@ROWCOUNT = 0
	RETURN
	
	UPDATE u SET u.SPID = @@SPID
		FROM toaUserSession u
		JOIN inserted i ON i.UserID = u.UserID
		WHERE u.LoggedIn = 'Y'

END