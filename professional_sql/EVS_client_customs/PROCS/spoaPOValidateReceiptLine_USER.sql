
CREATE PROCEDURE [dbo].[spoaPOValidateReceiptLine_USER]
@CompanyID char(3)
, @UserId varchar(20) = ''
, @OARecLineKey int
, @POLineKey int
, @ItemKey int
, @WhseKey int
, @BinKey int
, @LotNo varchar(20) = null OUTPUT
, @SerialNo varchar(20) = null OUTPUT
, @Qty float = null OUTPUT
, @UOMKey int = null OUTPUT
, @RetVal int = null OUTPUT
, @ErrMess varchar(250) = null OUTPUT
AS
-- 07/06/17 CD: SOW053017A - PO Lot Expiration validation
-- CD: works for both new lots and existing lots
DECLARE  @TrackMeth int, @ExpDate datetime, @ItemId varchar(30)

SELECT @ItemId = ItemId, @Trackmeth = TrackMeth 
	FROM timItem 
	WHERE ItemKey = @ItemKey

IF (COALESCE(@TrackMeth,0) = 1) -- lot tracked
BEGIN
	IF (SUBSTRING(@ItemId,1,1) = '5') -- item begins with 5
	BEGIN
		SELECT @ExpDate = ExpirationDate 
			FROM timInvtLot 
			WHERE LotNo = @LotNo 
				AND WhseKey = @WhseKey
				AND ItemKey = @ItemKey
	
		IF (COALESCE(@ExpDate,'') = '')
		BEGIN
			SELECT @RetVal = -1, @ErrMess = 'Expiration Required for Lot ' + @LotNo
		END
	END	
END