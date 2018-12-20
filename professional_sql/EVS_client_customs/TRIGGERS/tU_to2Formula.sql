

CREATE TRIGGER tU_to2Formula ON [dbo].[to2Formula]
AFTER UPDATE, INSERT
AS

IF @@ROWCOUNT = 0 RETURN
DECLARE @errno int, @errmsg varchar(255)

-- Created By: Cole Dixon
-- Date: 01/25/17
-- Alert user they cannot modify a formula associated to open PN batches.
IF EXISTS (SELECT 1 FROM inserted, to2PN (NOLOCK)
	WHERE inserted.FMKey = to2PN.FMKey AND to2PN.Status = 1)
	BEGIN
		SELECT @errno = 50024, @errmsg ='tU_to2Formula: You may not modify a Formula associated to open batches in to2PN.'
        GOTO error
	END 

	RETURN

	error:
		RAISERROR(@errno, 16, 1, @errmsg)
		ROLLBACK TRANSACTION