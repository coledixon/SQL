/****************************************
FIX PARTIAL BTO ISSUE SCRIPT
****************************************/
------------------------------------
--Created By: Cole Dixon
--Created On: 10/22/2015
--Description: This script is used to fix partial BTO Pending Shipments. The script will determine which pending shipments have partial BTO kits and will issue components
--to create the next whole BTO Kit Item
-----------------------------------

--------DECLARE THESE VARIABLES-----------
DECLARE @CompanyID char(3) = 'PMA';
DECLARE @UserID varchar(20) = 'admin';
DECLARE @IssueWhseBinID varchar(30) = 'Default'; -- This is the Bin where all inventory transactions will be issued from
DECLARE @WhseID varchar(30) = 'Denv';
DECLARE @TranDate datetime = DATEADD(MM, -2, GETDATE());
DECLARE @ValidateOnly int = 1;
--------DECLARE THESE VARIABLES-----------

--Local Variables
DECLARE @SOKEY int, @KitShipLineKey int, @WhseBinKey int, @WhseKey int, @PickListKey int

--Declare Partial SO Temp Table
IF OBJECT_ID('tempdb..#thepartials') > 0 DROP TABLE #thepartials
--Get Default WhseKey
SELECT @WhseKey = WhseKey FROM timWarehouse WHERE WhseID = @WhseID AND CompanyID = @CompanyID
--Get Default WhseBinKey
SELECT @WhseBinKey = WhseBinKey 
FROM timWhseBin wb
WHERE WhseBinID = @IssueWhseBinID AND WhseKey = @WhseKey

---------------------------------------------
-----------------VALIDATION------------------
---------------------------------------------
--check valid warehouse
IF COALESCE(@WhseKey,0) = 0
BEGIN
	SELECT 'ERROR:' + @WhseID + ' is not a valid warehouse for company ' + @CompanyID
	GOTO SPEND
END
--check valid bin is warehouse
IF COALESCE(@WhseBinKey,0) = 0
BEGIN
	SELECT 'ERROR:' + @IssueWhseBinID + ' is not a valid bin for warehouse ' + @WhseID
	GOTO SPEND
END
---------------------------------------------
-------------END VALIDATION------------------
---------------------------------------------


--Find the Sales Orders that have partial BTOs
SELECT SOKey, TranNo INTO #thepartials FROM
(
SELECT sol.SoKey, so.TranNo
FROM tsoShipLine sl -- kitheader
JOIN tsoShipLine sl2 WITH (NOLOCK)On sl2.KitShipLineKey = sl.ShipLineKey
JOIN tsoSOLine sol WITH (NOLOCK)On sol.SOLineKey = sl.SOLineKey
JOIN tsoSalesOrder so (NOLOCK) ON so.SOKey = sol.SOKey
JOIN tsoPendShipment ps WITH (NOLOCK) ON ps.ShipKey = sl2.ShipKey -- 10/23 CD
JOIN timKitCompList cl WITH (NOLOCK)On cl.KitItemKey = sl.ItemKey AND sl2.ItemKey = cl.CompItemKey
JOIN timItem i WITH (NOLOCK) ON i.ItemKey = cl.KitItemKey AND ItemType = 7
LEFT OUTER JOIN timInvtTranDist dl WITH (NOLOCK)ON dl.InvtTranKey = sl2.InvtTranKey
WHERE so.CompanyID = @CompanyID AND so.DfltWhseKey = @WhseKey
GROUP BY dl.ItemKey, sol.SOKey, so.TranNo, ps.TranNo
HAVING (SUM(dl.DistQty) IS NULL OR ((SUM(dl.DistQty)/SUM(cl.CompItemQty)) % 1) > 0) OR 
(SUM(dl.DistQty) - SUM(ps.AmtShipped) > 0)) leftover -- 10/23 CD: Added AmtShipped from tsoPendShipment
GROUP BY SOKey, TranNo

SELECT 'partialSO' as Debug, * FROM #thepartials

---------------------------------------------
-----------Start c cursor--------------------
---------------------------------------------
-- Partial Sales Order Cursor
DECLARE c CURSOR SCROLL_LOCKS
FOR SELECT SOKEY FROM #thepartials

OPEN c
FETCH NEXT FROM c INTO @SOKey

WHILE @@FETCH_STATUS = 0
BEGIN

---------------------------------------------
-----------Start c2 cursor-------------------
---------------------------------------------
-- Parent Kit Line Cursor
DECLARE @ToIssue decimal, @KitCompItemKey int, @KitItemShipLineKey int, @StockUOMKey int
--cursor for each kit on the SO
DECLARE c2 CURSOR SCROLL_LOCKS
FOR
SELECT sl.ShipLineKey
FROM tsoSOLine sol (NOLOCK)
JOIN tsoShipLine sl (NOLOCK) ON sl.SOLineKey = sol.SOLineKey
WHERE sol.SOKey = @SOKEY AND COALESCE(sl.KitShipLineKey,0) = 0

OPEN c2
FETCH NEXT FROM c2 INTO @KitShipLineKey

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @SOKEY as SOKey

	IF @ValidateOnly = 1
		BEGIN
		-- Qty to Make
		SELECT COALESCE(SUM(d.DistQty),0) QuantityIssued,(MIN(ToMake) * MIN(cl.CompItemQty)) as toMakePerItem, (MIN(ToMake) * MIN(cl.CompItemQty)) - COALESCE(SUM(d.DistQty),0) as QtyToIssue
		,sl2.ItemKey, sl2.ShipLineKey
		FROM
			(SELECT TOP 1 CEILING(SUM(d.DistQty)/MIN(cl.CompItemQty)) AS ToMake
				FROM tsoShipLine sl
				JOIN tsoShipLine sl2 ON sl2.KitShipLineKey = sl.ShipLineKey
				JOIN tsoSOLine sol On sol.SOLineKey = sl.SOLineKey
				JOIN timKitCompList cl ON cl.KitItemKey=sl.ItemKey AND sl2.ItemKey = cl.CompItemKey
				LEFT OUTER JOIN timInvtTranDist d ON d.InvtTranKey = sl2.InvtTranKey
				WHERE sl.ShipLineKey = @KitShiplineKey
				GROUP BY sl2.ItemKey
				ORDER BY ToMake DESC) as make
		JOIN tsoShipLine sl ON 1=1
		JOIN tsoShipLine sl2 ON sl2.KitShipLineKey = sl.ShipLineKey
		JOIN timKitCompList cl ON cl.KitItemKey = sl.ItemKey and sl2.ItemKey = cl.CompItemKey
		LEFT OUTER JOIN timInvtTranDist d ON d.InvtTranKey = sl2.InvtTranKey
		JOIN tsoSOLine sol On sol.SOLineKey = sl.SOLineKey
		WHERE sl.ShipLineKey = @KitShipLineKey
		GROUP BY sl2.ItemKey, sl2.ShipLineKey
		END
	ELSE
		BEGIN
---------------------------------------------
-----------Start c3 cursor-------------------
---------------------------------------------		
--cursor for determining remaining quantity to issue
		DECLARE c3 CURSOR SCROLL_LOCKS
		FOR
		SELECT (MIN(ToMake) * MIN(cl.CompItemQty)) - COALESCE(SUM(d.DistQty),0) as QtyToIssue
		,sl2.ItemKey, sl2.ShipLineKey
		FROM
			(SELECT TOP 1 CEILING(SUM(d.DistQty)/MIN(cl.CompItemQty)) AS ToMake
				FROM tsoShipLine sl
				JOIN tsoShipLine sl2 ON sl2.KitShipLineKey = sl.ShipLineKey
				JOIN tsoSOLine sol On sol.SOLineKey = sl.SOLineKey
				JOIN timKitCompList cl ON cl.KitItemKey=sl.ItemKey AND sl2.ItemKey = cl.CompItemKey
				LEFT OUTER JOIN timInvtTranDist d ON d.InvtTranKey = sl2.InvtTranKey
				WHERE sl.ShipLineKey = @KitShiplineKey
				GROUP BY sl2.ItemKey
				ORDER BY ToMake DESC) as make
		JOIN tsoShipLine sl ON 1=1
		JOIN tsoShipLine sl2 ON sl2.KitShipLineKey = sl.ShipLineKey
		JOIN timKitCompList cl ON cl.KitItemKey = sl.ItemKey and sl2.ItemKey = cl.CompItemKey
		LEFT OUTER JOIN timInvtTranDist d ON d.InvtTranKey = sl2.InvtTranKey
		JOIN tsoSOLine sol On sol.SOLineKey = sl.SOLineKey
		WHERE sl.ShipLineKey = @KitShipLineKey
		GROUP BY sl2.ItemKey, sl2.ShipLineKey
		
		OPEN c3
		FETCH NEXT FROM c3 INTO @ToIssue,@KitCompItemKey, @KitItemShipLineKey
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF (@ToIssue > 0)
			BEGIN
				--always issue in stock quantity
				SELECT @StockUOMKey = StockUnitMeasKey
				FROM timItem i
				WHERE ItemKey = @KitCompItemKey
				
				--create the distribution for the remainder
				EXEC spoaSOAddDist @CompanyID,@UserID, @TranDate, @KitItemShipLineKey,@KitCompItemKey,@WhseKey,@WhseBinKey,null,null,@ToIssue,@StockUOMKey
			END
			
			FETCH NEXT FROM c3 INTO @ToIssue,@KitCompItemKey, @KitItemShipLineKey
		END
		
		CLOSE c3
		DEALLOCATE c3
---------------------------------------------
-----------end c3 cursor---------------------
---------------------------------------------
		END


FETCH NEXT FROM c2 INTO @KitShipLineKey
END


CLOSE c2
DEALLOCATE c2
---------------------------------------------
-----------end c2 cursor---------------------
---------------------------------------------

FETCH NEXT FROM c INTO @SOKey
END


CLOSE c
DEALLOCATE c

SPEND:
---------------------------------------------
-----------end c cursor----------------------
---------------------------------------------
