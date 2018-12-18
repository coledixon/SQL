
ALTER PROCEDURE [dbo].[spumUserWhse_INSUPD]
-- Assume that #vumUserWhse is created from the vumUserWhse object def, with proc_status(int) and proc_message(nvc500)
-- This proc can be called from a trigger or from SQL directly
-- INS, UPD
@retval int = null OUTPUT
, @message nvarchar(500) = null OUTPUT
AS
-- 04/20/18 CD: created logic for Label 4 printers 
SET @message = ''
SET @retval = 1
 
CREATE TABLE #Val (rp uniqueidentifier PRIMARY KEY) 
DECLARE @UserID VARCHAR(30), @CompanyID CHAR(3), @SessionID INT
EXEC spumSessInfo @userid=@userid OUTPUT, @companyid=@companyid OUTPUT, @sessionid = @sessionid OUTPUT
 
IF COALESCE(@sessionid,0)=0
BEGIN
	SET @message = 'Invalid session.'
	GOTO ERROR
END
 
---- SET DEFAULTS
--UPDATE #vumUserWhse SET rp = COALESCE(rp, newid()), companyid = COALESCE(companyid, @companyid)
--	, proc_message = ''
--	WHERE COALESCE(proc_status,0)=0
 
---- RESOLVE FKs
--INSERT #val (rp)
--SELECT wrk.rp
--	FROM #vumUserWhse wrk
--	WHERE wrk.proc_status=0
 
---- VALIDATE ROWS
--UPDATE wrk SET proc_message = CASE WHEN wrk.company is null THEN 'Invalid company ' + COALESCE(wrk.company,'')
--		ELSE '' END
--	FROM #vumUserWhse wrk
--	JOIN #Val v ON v.rp = wrk.rp
--	WHERE wrk.proc_status=0 
  
UPDATE tr SET proc_status=-1 FROM #vumUserWhse tr WHERE proc_message > ''
 
IF @@ROWCOUNT > 0
	GOTO ERROR
 
--
-- HANDLE INSERT / UPDATE
-- 
BEGIN TRY
	BEGIN TRANSACTION
	-- TO DO : Return error above if any of the printer names entered are not valid
	-- UPDATE EXISTING 
	UPDATE exist SET DefLabel1Key = lbl1.PrinterKey , DefLabel2Key = lbl2.PrinterKey, DefLabel3Key = lbl3.PrinterKey, DefLabel4Key = lbl4.PrinterKey /*04/20/18 CD*/, DefPrinterKey = dsk.PrinterKey
	FROM #vumUserWhse wrk
	JOIN toaUserDef exist ON exist.UserID = wrk.Userid ANd exist.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl1 ON wrk.DefLabelPrinter1 = lbl1.PrinterName AND lbl1.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl2 ON wrk.DefLabelPrinter2 = lbl2.PrinterName AND lbl2.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl3 ON wrk.DefLabelPrinter3 = lbl3.PrinterName AND lbl3.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl4 ON wrk.DefLabelPrinter4 = lbl4.PrinterName AND lbl4.CompanyID = wrk.CompanyID -- 04/20/18 CD
	LEFT OUTER JOIN toaMastPrinter dsk ON wrk.DesktopPrinter = dsk.PrinterName AND dsk.CompanyID = wrk.CompanyID
 
	--CD: for changing printer with scan. scan looks at PVID, not printer name.
	UPDATE exist SET DefLabel1Key = COALESCE(lbl1.PrinterKey, curr.DefLabel1Key) , DefLabel2Key = COALESCE(lbl2.PrinterKey,curr.DefLabel2Key), DefLabel3Key = COALESCE(lbl3.PrinterKey,curr.DefLabel3Key), DefLabel4Key = COALESCE(lbl4.PrinterKey, curr.DefLabel4Key) /*04/20/18 CD*/, DefPrinterKey = COALESCE(dsk.PrinterKey,curr.DefPrinterKey)
	FROM #vumUserWhse wrk
	LEFT JOIN vumUserWhse curr ON curr.UserID = wrk.UserID AND curr.CompanyID = wrk.CompanyID -- CD
	JOIN toaUserDef exist ON exist.UserID = wrk.Userid ANd exist.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl1 ON wrk.DefLabelPrinter1 = lbl1.PVID AND lbl1.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl2 ON wrk.DefLabelPrinter2 = lbl2.PVID AND lbl2.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl3 ON wrk.DefLabelPrinter3 = lbl3.PVID AND lbl3.CompanyID = wrk.CompanyID
	LEFT OUTER JOIN toaMastPrinter lbl4 ON wrk.DefLabelPrinter4 = lbl4.PVID AND lbl4.CompanyID = wrk.CompanyID -- 04/20/18 CD
	LEFT OUTER JOIN toaMastPrinter dsk ON wrk.DesktopPrinter = dsk.PVID AND dsk.CompanyID = wrk.CompanyID
 
 
	-- DO INSERT
	--INSERT toaUserDef(companyid)
	--SELECT v.companyid -- TODO
	--	FROM #vumUserWhse wrk
	--	JOIN #Val v ON v.rp = wrk.rp
	--	LEFT OUTER JOIN toaUserDef exist ON exist.rp = wrk.rp
	--	WHERE wrk.proc_status=0  AND exist.UserID is null
	
	SET @retval=1
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'PROC ERR ' + ERROR_PROCEDURE() + ' ' + STR(ERROR_LINE()) + ' ' + ERROR_MESSAGE()
	SET @message = ERROR_MESSAGE()
 
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
 
	GOTO ERROR
END CATCH
 
 
GOTO SPEND
 
ERROR:
IF COALESCE(@retval,0) IN (0,1) SET @retval = 2
 
IF COALESCE(@message,'')=''
BEGIN
	SELECT @message = wrk.proc_message
		 FROM #vumUserWhse wrk
		 WHERE wrk.proc_status NOT IN (0,1) AND proc_message > ''
END
 
PRINT @message
 
SPEND:
