
ALTER PROCEDURE [dbo].[spoaHandleScan_USER]
-- 3/16/15 GFP User hook to log scan data
@CompanyId char(3)
, @UserId varchar(30)
, @WhseKey int
, @Module varchar(2)
, @ContextEntityType int = null
, @ContextOwnerKey int = null
, @ScanCode varchar(8000)
, @ScanResult varchar(8000) = null OUTPUT
, @SOScanMode int = 0
, @Msg varchar(max) = null OUTPUT
AS
BEGIN
Declare @Prefix Char(3), @SONo char(50), @PalletSeriesKey int, @PalletID varchar(50), @PalletKey int, @DfltBinLocKey int
		, @Count int, @SOKey int, @ScanLogKey int, @XFerKey int
		
---------------------------------------------------------
--BEGIN CUSTOM LOGIC for SOW 051215-02a
---------------------------------------------------------
--Developer: Cole Dixon
--Date: 06/05/15
--Description: This custom will run for custom prefix /?b and is used to add pallets and call pallet screen in mobile.
--				Pallets will be added and assigned to a SO (custom table) where PalletID is a set of pallets starting with
--				The Sales Order Number and incremented by one for each subsequent pallet.
SET @Prefix = SUBSTRING(@ScanCode,2,2)
IF (COALESCE(@Prefix,'') = '?b')
BEGIN
SET @SONo = SUBSTRING(@ScanCode,4, LEN(@ScanCode) -3)

--Check if open SO
IF EXISTS(SELECT TOP 1 1 FROM tsoSalesOrder where TranNo = @SONo AND Status = 1)
BEGIN
	SELECT @SOKey = SOKey FROM tsoSalesOrder WHERE TranNo = @SONo
	SELECT @PalletSeriesKey = PalletSeriesKey, @DfltBinLocKey = DefWhseBinKey FROM to2PalletSeries WHERE PalletSeriesID = 'DRY' -- Change this for Customer Defined Value
	IF (COALESCE(@PalletSeriesKey,0) > 0)
	BEGIN
		SELECT TOP 1 @PalletID = PalletID
			FROM to2Pallet WHERE PalletSeriesKey = @PalletSeriesKey AND PalletID like RTRIM(LTRIM(@SoNo)) + '%'
			ORDER BY PalletKey DESC
		IF (COALESCE(@PalletID,'') > '')
		BEGIN
			
			SET @COUNT = SUBSTRING(@PalletID, CHARINDEX('-',@PalletID, LEN(@SONo))+1, LEN(@PalletID) - (LEN(@SONo)-1)) + 1	
			
			EXEC spGetNextSurrogateKey 'to2Pallet', @PalletKey OUTPUT
			
			INSERT INTO to2Pallet(CompanyID,PalletKey,PalletID,PalletSeriesKey,InUse,AssocBinKey,CurrLocBinKey,WhseKey,QCHoldRsnKey,TareWeight
									,Notes,PalletIsPerm,UpdateCounter,UpdateDate,UpdateUser,ReserveInvtTranKey,AssocPNKey,CartonKey
									,HandCartonKey,PNProdTemplKey,ExpReturnDate)
			VALUES(@CompanyId,@PalletKey, LTRIM(RTRIM(@SONo)) + '-'+ LTRIM(RTRIM(CAST(@COUNT AS CHAR(6)))),@PalletSeriesKey,1,null,@DfltBinLocKey,@WhseKey,0,0
								,'',0,0,GETDATE(),@UserId,0,0,null
								,null,null,null)
			EXEC spo2PalletActivate @CompanyID,@PalletKey			
								
		END
		ELSE
		--If SO Pallets don't already exist
		BEGIN
			EXEC spGetNextSurrogateKey 'to2Pallet', @PalletKey OUTPUT
		
			INSERT INTO to2Pallet(CompanyID,PalletKey,PalletID,PalletSeriesKey,InUse,AssocBinKey,CurrLocBinKey,WhseKey,QCHoldRsnKey,TareWeight
									,Notes,PalletIsPerm,UpdateCounter,UpdateDate,UpdateUser,ReserveInvtTranKey,AssocPNKey,CartonKey
									,HandCartonKey,PNProdTemplKey,ExpReturnDate)
			VALUES(@CompanyId,@PalletKey, LTRIM(RTRIM(@SONo)) + '-1',@PalletSeriesKey,1,null,@DfltBinLocKey,@WhseKey,0,0
								,'',0,0,GETDATE(),@UserId,0,0,null
								,null,null,null)
			EXEC spo2PalletActivate @CompanyID,@PalletKey
		END
	END -- END Pallet Series Exist Logic
--Associate Pallet to SO
INSERT INTO to2SOPallets_GON (SOKey,PalletKey)
VALUES (@SOKey,@PalletKey)

--Get full PalletID	
SELECT @PalletID = PalletID
	FROM to2Pallet 
	WHERE PalletKey = @PalletKey
	
--Return this value to call Pallet screen in mobile	
SET @ScanResult = '/B'+ @PalletID

END -- END SO Exist Logic
---------------------------------------------------------
--END CUSTOM LOGIC for SOW 051215-02a
---------------------------------------------------------
END -- END /?B prefix logic


--DECLARE @SOKey int, @ScanLogKey int

--IF @ContextEntityType = 811 -- SO
--BEGIN
--	--SELECT @SOKey = sol.SOKey
--	--	FROM toa
--	--select entitytype, ownerkey, * from toapickline where pickid = 1027
--	--select * from tsoshiplinedist where shiplinekey = 1826

--	--EXEC spGetNextSurrogateKey 'to2_GFP_ScanLog', @ScanLogKey OUTPUT

--	--INSERT to2_GFP_ScanLog (CompanyID, ScanLogKey, UserID, ScanDate, SOKey, ScanData)
--	--SELECT @CompanyID, @ScanLogKey, @UserId, getdate(), @SOKey, @ScanCode
	
	
	
--END

--SET @ScanResult = '' -- make calling procedure continue on

END

-- 04/10/18 CD: compiled from base spoaHandleScan_USER
-- log scan for sales order types
IF @ContextEntityType = 811 -- SO
BEGIN
	BEGIN TRY
      SELECT @SOKey = sol.SOKey, @XFerKey = tol.TrnsfrOrderKey
      FROM tsoShipLine sl (NOLOCK)
            LEFT OUTER JOIN tsoSOLine sol (NOLOCK) ON sol.SOLineKey = sl.SOLineKey
			LEFT OUTER JOIN timTrnsfrOrderLine tol (NOLOCK) ON tol.TrnsfrOrderLineKey = sl.TrnsfrOrderLineKey
            WHERE sl.ShipLineKey = @ContextOwnerKey

      EXEC spGetNextSurrogateKey 'to2_GFP_ScanLog', @ScanLogKey OUTPUT
	  
 
	-- check for second. This routine gets called twice from the ui and we only want to log the first time aroudn
	IF NOT EXISTS(SELECT 1 FROM to2_GFP_ScanLog WHERE ScanLogKey > @ScanLogKey - 10 AND UserId=@UserId 
		AND SOKey=@SOKey AND TrnsfrOrderKey = @XFerKey AND ScanData=@ScanCode)
	BEGIN
		  INSERT to2_GFP_ScanLog (CompanyID, ScanLogKey, UserID, ScanDate, SOKey, ScanData, TrnsfrOrderKey)
		  SELECT @CompanyID, @ScanLogKey, @UserId, getdate(), @SOKey, @ScanCode, @XFerKey
	END
	END TRY
	BEGIN CATCH -- in case there's an error, allow to continue
		SET @ScanResult=''
	END CATCH
END
 
--
-- Check item UPCs
--
IF COALESCE(@ScanResult,'')=''
BEGIN
      SELECT @ScanResult = '/I' + rtrim(uom.ItemId) -- could add qty later + '/U' + rtrim(uom.UOMID) + '/Q1'
            FROM vo2ItemUOMLight uom (NOLOCK)
            WHERE uom.CompanyID = @CompanyId AND uom.UPC = @ScanCode
           
      -- check for a UPC in the table that is missing first digit & check digit
      IF COALESCE(@ScanResult,'')=''           
            SELECT @ScanResult = '/I' + rtrim(uom.ItemId) -- could add qty later + '/U' + rtrim(uom.UOMID) + '/Q1'
                  FROM vo2ItemUOMLight uom (NOLOCK)
                  WHERE uom.CompanyID = @CompanyId
                        AND uom.UPC LIKE SUBSTRING(@ScanCode, 2, LEN(@ScanCode)-2)
                       
      -- TODO Additional logic here pending testing
 
END



