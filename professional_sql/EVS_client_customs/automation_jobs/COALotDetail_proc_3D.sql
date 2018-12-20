
--COA Detail Cursor/Proc for 3D
--Created by: Cole Dixon
--04/21/2016
ALTER procedure [dbo].[sp_EVS_3D_COA_Detail]
	@BegDate date,
	@Enddate date,
	@StCustId	varchar(12),
	@BegItemId varchar(30),
	@EndItemId varchar(30)

as
DECLARE @start datetime
DECLARE @LotNo VARCHAR(10)
DECLARE @Lots VARCHAR(200) --THIS CAN BE ADJUSTED IF NEEDED
DECLARE @CustId VARCHAR(12)
DECLARE @Shipdate date
DECLARE @ItemID varchar(30)
DECLARE @SO varchar(15)

SET @Lots = ''
SET @start = getdate()

IF OBJECT_ID('tempdb..#scustlots') > 0DROP TABLE #custlots
CREATE TABLE #custlots (CustID varchar(12), ShipDate datetime, Itemid varchar(30), SO varchar(15), Lots VARCHAR(250))

-- get temp table of lots​
DECLARE ship CURSOR LOCAL READ_ONLY FOR
SELECT DISTINCT trannorel, itemid, custid, shipdate
   FROM vdv_o2_COA_LotsbySO (NOLOCK) so
   WHERE so.shipdate between @BegDate and @Enddate
	AND (COALESCE(@StCustId,'')='' OR so.custid=@StCustId)
	AND so.itemid >= COALESCE(@BegItemId,'')
	AND (COALESCE(@EndItemID,'')='' OR @EndItemId >= so.itemid)

OPEN ship

FETCH NEXT FROM ship INTO @SO, @itemid, @custid, @shipdate​
WHILE (@@FETCH_STATUS = 0)
BEGIN
	SET @Lots = ''

	SELECT @Lots = @lots + CASE WHEN @lots > '' THEN ', ' ELSE '' END + rtrim(d.lot) -- remove comma on last record
			FROM (SELECT Distinct COALESCE(l.lotno,'N/A') lot
				FROM vdv_o2_COA_LotsbySO l (NOLOCK)
				WHERE TranNoRel = @SO AND ItemID = @ItemID AND custid=@custid AND shipdate = @shipdate
			) d
			ORDER BY d.lot
	
	INSERT INTO #custlots VALUES(@Custid, @shipdate, @Itemid, @so, @Lots)
	
   FETCH NEXT FROM ship INTO @SO, @itemid, @custid, @shipdate
   END
       
CLOSE ship
DEALLOCATE ship

-- select result
SELECT 
   case when spec.testdesc like 'Moist%' then coa.NumericFinalResult end as Moisture
  , case when spec.testdesc like 'Fat%' then coa.NumericFinalResult end as Fat
  , case when spec.testdesc like 'Protein%' then coa.NumericFinalResult end as Protein
  , case when spec.testdesc like 'Ash%' then coa.NumericFinalResult end as Ash
  , case when spec.testdesc like 'per%' then coa.NumericFinalResult end as PV
  , case when spec.testdesc like 'Free%' then coa.NumericFinalResult end as FFA
  , c.CustName
  , s.ShipKey
  , s.CustPONo
  , a.City
  , s.SO
  , i.ItemID
  , i.ShortDesc
  , coa.TranNoRel
  , coa.Seq
  , coa.CompleteUserId
  , s.CompanyID
  , coa.itemid
  , spec.TestDesc
  , coa.QCSampleID
  , ci.CustItemNo
  , i.ItemKey
  , spec.numericlow
  , spec.lowop
  , spec.highop
  , spec.NumericHigh
  , i.ItemClassKey
  , #custlots.lots
  , s.OAShipDate
  , #custlots.CustID
  , ' ' as SourceDescription
 FROM vdv_o2_COA_SO_Frozen_3D coa (NOLOCK)
 INNER JOIN tarCustomer c  (NOLOCK)ON coa.CompanyID= c.CompanyID AND coa.custkey= c.CustKey
 INNER JOIN voaShipmentAll s  (NOLOCK)ON coa.CompanyID =s.CompanyID AND coa.ShipKey = s.ShipKey
 INNER JOIN tciAddress a  (NOLOCK) on a.AddrKey = s.ShipToAddrKey
 INNER JOIN vO2Item i  (NOLOCK)ON coa.CompanyID =i.CompanyID AND coa.itemkey = i.ItemKey
 INNER JOIN vdv_o2_COA_CustSpecs spec (NOLOCK)ON coa.custid = spec.custid
	AND coa.CompanyID = spec.CompanyID AND coa.itemid = spec.itemid AND coa.QCTestKey = spec.QCtestKey 
  INNER JOIN #custlots on #custlots.CustID = COA.custid 
	and #custlots.itemid = COA.itemid and #custlots.so = S.SO
 LEFT OUTER JOIN vdv_o2_COA_Lots lots  (NOLOCK)ON coa.ownerkey = lots.ownerkey AND coa.itemkey = lots.itemkey
 LEFT OUTER JOIN timCustItem ci  (NOLOCK)ON coa.custkey = ci.CustKey AND coa.itemkey = ci.ItemKey
 WHERE  
	coa.custid = @StCustId 
	AND s.CompanyID='pro' 
	and coa.itemid >= @BegItemId 
	and coa.itemid <= @EndItemId
	and s.OAShipDate >= @BegDate
	and s.OAShipDate <= @EndDate
	AND i.ItemClassKey=268
 ORDER BY coa.TranNoRel, coa.Seq 







