
ALTER PROCEDURE [dbo].[spumValidateInventory_USER]

-- validate against #toaAdjustmentWrk
@CompanyID char(3)
, @UserId varchar(30)
, @ValResult int =0 OUTPUT -- 1 = Ok to move, 2 = Override Required. User does not have override permission, 3 = Override Allowed. Show Yes/No message, 4 = Override allowed. Do not show Yes/No Message
, @PermID varchar(30) = null OUTPUT
, @Mess varchar(500) = null OUTPUT
AS
-- 02/19/18 CD: created
DECLARE @Count int, @HasPerm int
-- default to Ok
SET @ValResult = 1

-- validate inventory on qchold pallet
SELECT @Count = COUNT(wrk.ItemKey) FROM to2Pallet pall
	JOIN #toaAdjustmentWrk wrk (NOLOCK) ON pall.AssocBinKey = wrk.whsebinkey AND pall.WhseKey = wrk.whsekey
	WHERE COALESCE(pall.QCHoldRsnKey,0) > 0

IF (COALESCE(@Count,0) > 0)
BEGIN
	SELECT @HasPerm = Authorized FROM vumUserPerm
		WHERE UserID = @UserId AND CompanyID = @CompanyID AND permid = 'IV_QCMOVE'

	IF (COALESCE(@HasPerm,0)=0)
	BEGIN
		SELECT @ValResult = 2, @PermID = 'IV_QCMOVE', @Mess = 'User does not have permission to perform this action'
		GOTO SPEND
	END
END


GOTO SPEND
SPEND:

SELECT @ValResult as Result, @PermID as SecEvent, @Mess as Message

