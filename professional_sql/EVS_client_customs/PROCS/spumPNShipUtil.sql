
CREATE PROCEDURE [dbo].[spumPNShipUtil]
	@PNID VARCHAR(20)
	, @SOLineKey INT
	, @UserId VARCHAR(100)
	, @ItemKey INT
	, @PackSize INT
	, @QtyToXfer INT
	, @LotNo VARCHAR(20)
	, @ToBin VARCHAR(15)
	, @FromBin VARCHAR(15)
	, @RxKey INT
	, @Validate INT = 0 -- validate data
	, @DoShip INT = 0 -- ship pn
	, @LogFail INT = 0
	, @iStr VARCHAR(255)
	, @iRet INT
	, @iSessKey INT
	, @CompanyId VARCHAR(4)
	, @RPHId INT OUTPUT
	, @RetVal INT OUTPUT
	, @Msg VARCHAR(250) OUTPUT
AS
-- 08/02/2017 CD: Wedgewood SOW 071317A: GC Ship (Mobe3)
DECLARE @Shipkey INT, @ShipLineKey INT, @FromBinID VARCHAR(15), @SessionKey INT, @Date DATETIME, @oRetVal INTEGER, @oRetStr VARCHAR(2000)
SELECT @Date = GETDATE()
--------------------------------------------------
-------------- LOG FAILURES
--------------------------------------------------
IF (COALESCE(@LogFail,0) > 0) -- log bin xfer failures
BEGIN
		-- insert bin xfer fail record
		INSERT INTO tsoLinesToShip_RKL (SOLineKey, QtyShip, BinId, LotNo, SerialNo, ErrorMsg, ProcessStatus, SessionKey)
		VALUES (@SOLineKey, COALESCE(@QtyToXfer,0), @FromBin, @PNID, NULL, @iStr, @iRet, @iSessKey)	
		
		SET @RetVal = 1
		GOTO SUCCESS
END
--------------------------------------------------
-------------- GET PN BATCH INFO
--------------------------------------------------
IF (COALESCE(@ItemKey,0) > 0 OR COALESCE(@SOLineKey,0) > 0) 
	AND (COALESCE(@DoShip,0) = 0 AND COALESCE(@LogFail,0) = 0 AND COALESCE(@Validate,0) = 0)
BEGIN
	SELECT COALESCE(sol.ExtCmnt,'') as special_instructions 
		, COALESCE(itemu.PackSize,0) as size 
		, COALESCE(flav.FlavorID,'') as flavor 
		, COALESCE(t.LotNo,'') as lotno
		, t.ExpirationDate as bud
			FROM tsmSOWoMgmtDetail_WED sowo
			JOIN tsoSOLine sol (NOLOCK) ON  sol.SOLineKey = sowo.SOLineKey
			JOIN to2pn pn (NOLOCK) ON pn.PNKey = sowo.PNKey
			LEFT OUTER JOIN tsoSOLineUDF_WED solu (NOLOCK) ON solu.solinekey = sol.SOLineKey
			LEFT OUTER JOIN timItemUDF_WED itemu (NOLOCK) ON itemu.itemkey = sol.ItemKey
			LEFT OUTER JOIN timItemFlavor_WED flav (NOLOCK) ON flav.FlavorKey = solu.flavorkey
			LEFT OUTER JOIN to2Tran t  (NOLOCK)ON t.ItemKey = sol.ItemKey and t.pnkey = pn.pnkey and Type = 'P'
				WHERE sol.solinekey = @SOLineKey and itemu.itemkey = @ItemKey and pn.PNID = @PNID

	SELECT @RPHId = app.RPhID
		FROM tciRPhPackAppUser_WED app
		JOIN tsmUser u (NOLOCK) ON app.RPhName = u.UserName
		LEFT OUTER JOIN tumUser m3u (NOLOCK) ON m3u.userid = u.UserID AND enabled = 1
			WHERE u.UserID = @UserId

	IF @@ROWCOUNT > 0 
	BEGIN
		SET @RetVal = 1
		GOTO SUCCESS
	END
END
--------------------------------------------------
-------------- VALIDATIONS
--------------------------------------------------
IF ((COALESCE(@PNID,'') > '' AND COALESCE(@SOLineKey,0) > 0 AND COALESCE(@ItemKey,0) > 0) AND COALESCE(@Validate,0) = 1)
BEGIN
	SELECT TOP 1 1 -- validate PN is approved for RPH
		FROM tciRPhPNSOLineApproved_WED
		WHERE PNID = @PNID

		IF @@ROWCOUNT > 0
		BEGIN
			SELECT  @Msg = 'PN is already approved for RPH', @RetVal = 1
			GOTO SUCCESS
		END

	SELECT @RPHId = app.RPhID -- validate user has proper creds/perms
		FROM tciRPhPackAppUser_WED app
		JOIN tsmUser u (NOLOCK) ON app.RPhName = u.UserName
		LEFT OUTER JOIN tumUser m3u (NOLOCK) ON m3u.userid = u.UserID AND enabled = 1 -- validate mobe3 user status
			WHERE u.UserID = @UserId

		IF (COALESCE(@RPHID,0) = 0)
		BEGIN
			SELECT @Msg = 'RPHid does not exist in the system' /* and cannnot approve the shipment'*/, @RetVal = 1
			GOTO ERROR
		END

	-- validate shipline is not on another picklist
	DECLARE @val1 int, @val2 int
	SELECT @val1 = COUNT(*)
		FROM tsoShipLine sl
			WHERE sl.SOLineKey = @SOLineKey

	SELECT @val2 = COUNT(*)
		FROM tsoShipLine sl
		JOIN tsoShipmentLog slog (NOLOCK) ON slog.ShipKey = sl.ShipKey
			WHERE sl.SOLineKey = @SOLineKey AND NOT sl.ShipKey IS NULL AND TranStatus = 3

		IF (COALESCE(@val1,0) > 0 AND COALESCE(@val2,0) = 0)
		BEGIN
			SELECT @Msg = 'Line item on another picklist.' /*Order cannot not be processed until shipment is posted.'*/, @RetVal = -1
			GOTO ERROR
		END
END
--------------------------------------------------
------------- PICKLIST/SHIPPING
--------------------------------------------------
IF (COALESCE(@DoShip,0) > 0)
BEGIN
	EXEC spGetNextSurrogateKey 'tsoLinesToShip_RKL', @SessionKey OUTPUT
	
	-- insert base record
	INSERT INTO tsoLinesToShip_RKL (SOLineKey, QtyShip, BinId, LotNo, SerialNo, ErrorMsg, ProcessStatus, SessionKey)
	VALUES (@SOLineKey, @QtyToXfer, @FromBin, @PNID, NULL, '', 0, @SessionKey) -- 08/28/17 CD: ErrorMsg needs to be ''

	EXEC spsoAutoShipLines_RKL @SessionKey, @CompanyID, @RetVal OUTPUT
	SELECT @RetVal

		IF (COALESCE(@RetVal,0) <> 1 OR @@ERROR <> 0) --11/29/17 CD: REMOVED
		BEGIN
			SELECT @Msg = ErrorMsg 
				FROM tsoShipmentLog2_RKL (NOLOCK)
				WHERE SessionKey = @SessionKey -- 10/25/17 CD: get logged error from API

			-- UNDO BIN XFER
			PRINT 'REVERSE BIN XFER'
			EXEC spumUndoGCBinXfer_WED @CompanyId, @SessionKey, @UserId, @ItemKey, @PNID, 'GCSHIP', '150OUT', @Msg OUTPUT, @RetVal OUTPUT -- default binids
			SELECT @RetVal = @RetVal
			
			IF COALESCE(@Msg,'') = '' -- 10/25/17 CD: incase API did not log error, default generic
			BEGIN
				SELECT @Msg = 'Error running spsoAutoShipLines_RKL'
				GOTO ERROR
			END
			GOTO ERROR
		END

	SELECT @ShipKey = ship2.ShipKey, @ShipLineKey = sll2.ShipLineKey, @PackSize = udf.PackSize
		FROM tsoShipmentLog2_RKL ship2
		JOIN tsoShipLineLog2_RKL sll2 (NOLOCK) ON ship2.sessionkey = sll2.SessionKey
		JOIN tsoSOLineUDF_WED udf (NOLOCK) ON udf.solinekey = sll2.solinekey
			WHERE sll2.SOLineKey = @SOLineKey AND ship2.SessionKey = @SessionKey AND NOT sll2.ShipLineKey IS NULL

		IF @@ROWCOUNT = 0
		BEGIN
			SELECT @Msg = 'no records found in tsoShipmentLog2_RKL/tsoShipLineLog2_RKL', @RetVal = -1
			GOTO ERROR
		END

	INSERT INTO tciRPHPNSOLineApproved_Wed (UserId, RPhApprovedDate, ShipKey, ShipLineKey, RxNo, ItemKey, QtyShipped, PackSize, RPhID, PNID, SOLineKey, AppID)
	VALUES (@UserId, GETDATE(), @Shipkey, @ShipLineKey, @RxKey, @ItemKey, @QtyToXfer, @PackSize, @RPHId, @PNID, @SOLineKey, 'ShipFromGC') -- default 'ShipFromGC' as this is coming strictly from Mobe3
	
		IF @@ROWCOUNT > 0 SET @RetVal = 1
END



SUCCESS:
IF(COALESCE(@RetVal,0) <> 1) SET @RetVal = 1
RETURN

ERROR:
IF(COALESCE(@RetVal,0) = -1 AND COALESCE(@Validate,0) = 1) SET @RetVal = -1
ELSE SET @RetVal = 1
IF(COALESCE(@Msg,'') = '') SET @Msg = 'Error running spumPNShipUtil'
