
CREATE PROC [dbo].[spumUndoGCBinXfer_WED]
	@CompanyId VARCHAR(4)
	, @SessionKey INT
	, @UserId VARCHAR(50)
	, @ItemKey INT
	, @LotNo VARCHAR(20)
	, @FromBinId VARCHAR(15)
	, @ToBinId VARCHAR(15)
	, @ErrMess VARCHAR(255) OUTPUT
	, @RetVal INT OUTPUT
AS
-- 08/10/17 CD: created to reverse the bin xfer API if GC Ship API fails (SOW 071317A: GC SHIP)
DECLARE @Date DATETIME, @ToBinKey INT, @FromBinKey INT, @LotKey INT, @QtyAvailable DECIMAL(17,8), @QtyToXfer INT
--------------------------------------------------
-------------- TEMP TABLE
--------------------------------------------------
IF OBJECT_ID('tempdb..##toaIMStockMove') is null
BEGIN 
	CREATE TABLE ##toaIMStockMove (
	SessionID INT DEFAULT 0 not null
	,BinID VARCHAR (15)
	,CompanyID VARCHAR (3)
	,ExpirationDate DATETIME
	,ItemKey FLOAT
	,LotKey FLOAT
	,LotNo VARCHAR (20)
	,QtyAvailable DECIMAL (17,8)
	,QtyToTrnsfr DECIMAL (17,8)
	,SerialNo VARCHAR (20)
	,SerialKey FLOAT
	,TargetWhseBinKey FLOAT
	,WhseBinKey FLOAT
	);
	CREATE UNIQUE INDEX AllKeys_timStockWRk ON ##toaIMStockMove (SessionID, ItemKey, LotKey, QtyToTrnsfr, SerialKey, WhseBinKey, TargetWhseBinKey)
END
ELSE BEGIN
	TRUNCATE TABLE ##toaIMStockMove
END
--------------------------------------------------
-------------- GET REQUIRED DATA
--------------------------------------------------
SELECT @Date = GETDATE()
SELECT @ToBinKey = WhseBinKey FROM timWhseBin WHERE WhseBinId = @ToBinId
SELECT @QtyToXfer = QtyOnHand, @QtyAvailable = QtyAvailable, @LotKey = InvtLotKey, @FromBinKey = WhseBinKey 
	FROM dbo.vdvInventoryLotBin 
		WHERE LotNo = @LotNo AND QtyOnHand > 0 AND WhseBinId = @FromBinId
--------------------------------------------------
-------------- UNDO BIN XFER
--------------------------------------------------
-- remove false records
DELETE FROM ##toaIMStockMove WHERE SessionId = @SessionKey

-- insert base record
-- SELECT 'DEBUG', @SessionKey as sess, @FromBinId as frombin, @CompanyId as company, @ItemKey as itemkey, @LotKey as lotkey, @LotNo as lotno, @QtyAvailable as qtyavail, @QtyToXfer as qtyxfer, @ToBinKey as tobinkey, @FromBinKey as frombinkey
INSERT INTO ##toaIMStockMove (SessionId, BinId, CompanyId, ItemKey, LotKey, LotNo, QtyAvailable, QtyToTrnsfr, TargetWhseBinKey, WhseBinKey)
VALUES (@SessionKey, @FromBinId, @CompanyId, @ItemKey, @LotKey, @LotNo, @QtyAvailable, @QtyToXfer, @ToBinKey, @FromBinKey)

-- run O2/MAS bin xfer
IF EXISTS(SELECT 1 FROM ##toaIMStockMove WHERE SessionId = @SessionKey)
BEGIN
	EXEC spoaSpimSaveBinTransferTrnxs @CompanyId, @Date, @SessionKey, @UserId
		IF @@ERROR <> 0
		BEGIN
			SELECT @RetVal = -1, @ErrMess = 'Error in spoaSpimSaveBinTransferTrnxs'
			GOTO ERROR
		END
END
ELSE BEGIN
	SELECT @RetVal = -1, @ErrMess = 'Nothing to Move'
	GOTO ERROR
END



SUCCESS:
IF COALESCE(@RetVal,0) <> 1 SET @RetVal = 1
RETURN

ERROR:
IF(COALESCE(@RetVal,0) <> -1) SET @RetVal = -1
IF(COALESCE(@ErrMess,'') = '') SET @ErrMess = 'Error running spumUndoGCBinXfer_WED'