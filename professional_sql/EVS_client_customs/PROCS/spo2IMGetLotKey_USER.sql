

CREATE PROCEDURE [dbo].[spo2IMGetLotKey_USER]
--CROSSOVER PN ENTER PROD
@ItemKey int
, @WhseKey int
, @LotNo varchar(20)
, @InvtLotKey int OUTPUT
-- 07/13/17 CD: created for Gonnella (SOW053017A)
-- if itemid begins with '5' + lot exists: show existing Exp Date in O2Mobile UI.
-- if itemid begins with '5' + new lot: Exp Date field is blank in O2Mobile UI.
AS
SET @LotNo = ltrim(rtrim(@LotNo))
DECLARE @kLotOpenStatus int, @ExpDate datetime, @ShelfLife int, @ItemExists int, @ItemID varchar(200)
	SELECT @kLotOpenStatus = 1
-- get existing lot key	
SELECT @InvtLotKey = InvtLotKey
	FROM timInvtLot lot (NOLOCK)
	WHERE ItemKey = @ItemKey AND WhseKey = @WhseKey AND LotNo = @LotNo

-- Get New Lot Key
IF COALESCE(@InvtLotKey,0) = 0
BEGIN
	-- validate item and whse
	SELECT @ItemId = ItemId, @ItemExists=1, @ShelfLife = it.ShelfLife 
		FROM vo2Item it (NOLOCK) 
		JOIN vo2Whse wh ON it.CompanyID = wh.CompanyID 
		WHERE it.ItemKey = @ItemKey AND wh.WhseKey = @WhseKey AND it.TrackMeth IN (1,3)
		
	IF COALESCE(@ItemExists,0)=0
	BEGIN
		GOTO ERROR
	END
	EXEC spevGetNextSurrogateKey 'timInvtLot', @InvtLotKey OUTPUT
	
	-- set expiration date that will be shown in O2Mobile UI during receiving
	IF (SUBSTRING(@ItemId,1,1) = '5') -- item begins with 5
	BEGIN
		SELECT @ExpDate = ExpirationDate 
			FROM timInvtLot 
			WHERE ItemKey = @ItemKey AND InvtLotKey = @InvtLotKey 
				AND WhseKey = @WhseKey
		
		IF (COALESCE(@ExpDate,'') = '')
		BEGIN
			SET @ExpDate = NULL -- blank Exp Date field in O2Mobile UI
		END
	END
	ELSE BEGIN
		IF COALESCE(@ShelfLife,0)>0 SET @ExpDate = dbo.fnO2ParseDate(getdate()) + @ShelfLife
	END

	INSERT timInvtLot (InvtLotKey, ExpirationDate, ItemKey, LotNo, Status, WhseKey)
		VALUES (@InvtLotKey, @ExpDate, @ItemKey, @LotNo, @kLotOpenStatus , @WhseKey)
END
GOTO SPEND
ERROR:
SET @InvtLotKey = null
GOTO SPEND
SPEND:



