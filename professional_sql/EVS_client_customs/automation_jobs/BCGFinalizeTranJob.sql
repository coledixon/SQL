/*
//
//  PN Transaction Finalization Script
//  Developed by: Cole Dixon
//  Escape Velocity Systems
//  03/15/2017
//
//  Created for: Blue Chip Group
//
*/

-- PRODUCTION NOTES:
-- BE SURE TO SET CORRECT VARIABLES
-- MAX DATE RANGE 48hrs - (GETDATE()-2)
-- COMMENT OUT ALL DEBUGGING STATEMENTS

/*DECLARE VARIABLES*/
DECLARE @PNKey int, @CompanyId VARCHAR(5), @WhseKey int, @TypeRestrict VARCHAR(5), @BatchPost int, 
    @UseActualCost int, @UseExistingPNList int, @TotalCount int, @FailCount int, @SPID int, @DoNotRecomputeStats int

/*SET CONSTANTS [AS NEEDED]*/
SELECT @CompanyId = '100', @TypeRestrict = 'MB'/*Material,BOM*/, @BatchPost = 1, @UseActualCost = 0, @UseExistingPNList = 1
-- SELECT @CompanyId, @TypeRestrict, @BatchPost, @UseActualCost, @UseExistingPNList , @DoNotRecomputeStats // for debugging

/*INIT TEMP TABLE*/
IF OBJECT_ID('tempdb..#PNList') is null 
    SELECT * INTO #PNList FROM to2PNListWrk WHERE 1=0
ELSE 
    TRUNCATE TABLE #PNList

/*INSERT PNKEYS INTO #PNList FOR OPENBATCHES WITH COMMITTED TRANS*/
INSERT INTO #PNList (PNKEY)
SELECT DISTINCT tr.PNKey
    FROM to2Tran tr (NOLOCK)
    JOIN to2PN pn (NOLOCK) ON  pn.PNKey = tr.PNKey
    WHERE COALESCE(GLBatchKey,0) = 0 AND (Type IN ('M','B') AND IssueComplete = 0)
        AND GLPostingID = 0 AND tr.TranDate BETWEEN /*LAST 24HRS*/(GETDATE() - 1) AND GETDATE() AND pn.CompanyID = @CompanyId
        AND pn.Status = 1

/*FINALIZE TRANSACTIONS*/       
DECLARE finalizeTrans CURSOR LOCAL READ_ONLY 
FOR
SELECT PNKey FROM #PNList

OPEN finalizeTrans

FETCH NEXT FROM finalizeTrans INTO @PNKey
WHILE @@FETCH_STATUS = 0
BEGIN

    -- PRINT @PNKey --// for debugging
    EXEC spo2PNProcInvtTrans @CompanyId, @PNKey, @TotalCount OUTPUT, @FailCount OUTPUT, @TypeRestrict, @SPID OUTPUT, @BatchPost, @UseActualCost, 0, @UseExistingPNList

    /*CAPTURE FAILURES*/
    IF (@FailCount > 0)
    BEGIN
        -- PRINT 'FAIL' --// for debugging
        UPDATE #PNList SET Fail = @FailCount WHERE PNKey = @PNKey
        -- errors are logged in tciErrorLog from spo2CreateErrorLog within spo2PNProcInvtTrans
    END ELSE
    BEGIN
        UPDATE #PNList SET Total = @TotalCount WHERE PNKey = @PNKey
    END 

    -- REMOVED: DELETE FROM #PNList WHERE PNKey = @PNKey AND Fail = @FailCount -- 03/27/17 CD
    FETCH NEXT FROM finalizeTrans INTO @PNkey
END

CLOSE finalizeTrans 
DEALLOCATE finalizeTrans

--// DEBUGGING - strictly informational
-- 1) SHOW TOTALCOUNT/FAILCOUNT
--SELECT * FROM #PNList

---- 2) SHOW UNFINALIZED LINES
--SELECT pn.PNID, tr.IssueComplete, tr.ItemKey, WhseBinKey, tr.TranDate, tr.UpdateDate, *
--    FROM to2Tran tr (NOLOCK)
--    JOIN to2PN pn (NOLOCK) ON  pn.PNKey = tr.PNKey
--    WHERE COALESCE(GLBatchKey,0) = 0 AND (Type IN ('M','B') AND IssueComplete = 0)
--        AND GLPostingID = 0 AND tr.TranDate BETWEEN /*LAST 24HRS*/(GETDATE() - 1) AND GETDATE() AND pn.CompanyID = @CompanyId
--        AND pn.Status = 1