
ALTER TRIGGER [dbo].[ti_tsoShipment_CBH]
ON [dbo].[tsoShipment]
AFTER INSERT, UPDATE 
AS 
-- 03/01/17 CD: CBH: set CreateUserId to O2Mobile userid on SO/Ship type trans
BEGIN
	DECLARE @CompanyId char(3), @UserId varchar(30), @PalletKey int, @PalletTranType int, @TranType int

		SELECT @UserID = tr.UpdateUserID, @TranType = tr.TranType
		FROM inserted tr
		
		IF (RTRIM(LTRIM(@UserId)) = 'IV' AND @TranType IN (810,811)) -- 810 = Shipment / 811 = Return
		BEGIN
			SELECT @UserId = COALESCE(USERID,'IV') FROM toaUserSession WHERE SPID = @@SPID AND LoggedIn = 'Y'
			UPDATE sh SET  sh.CreateUserId = @UserId, sh.UpdateUserID = @UserId, sh.UpdateDate = GETDATE(), sh.TranCmnt = 'O2Mobile' -- 03/01/17 CD
				FROM tSOShipment sh JOIN inserted i (NOLOCK) ON i.ShipKey = sh.ShipKey
		END

END
