
CREATE PROCEDURE [dbo].[spoaGetPrinter_USER_POST]
@CompanyID char(3)
, @UserId varchar(30)
, @WhseKey int
, @BusinessFormKey int = null
, @O2ReportID int = null
, @RptName varchar(255)
, @SysReportID varchar(50) = null -- 5/13/14
, @PrinterDest varchar(255) = null OUTPUT
, @AltPrinterDest1 varchar(255) = null OUTPUT
, @AltPrinterDest2 varchar(255) = null OUTPUT
, @AltPrinterDest3 varchar(255) = null OUTPUT
-- 12/05/17 CD: CREATED (Wedgewood SOW 071317A: GC SHIP)
AS
DECLARE @WhsePrinter varchar(255), @DefPrinter varchar(255), @BizFormPrinter varchar(255), @UserPrinter varchar(255)
	, @OAPrintTo varchar(20), @OAPrinterKey int, @DefOAPrinter varchar(255), @GroupId varchar(50)

IF (COALESCE(@SysReportID, '') = 'wprx_RxLabels')
BEGIN
	SELECT @PrinterDest = @PrinterDest + 'LABELS'
END
