
/*
	Basically they are trying to get the report to show them what tools are at what jobs (assignments), 
	with a rate calculation, and the appropriate cost code. 
	
	The problem is that the cost code can either be on the transferheader or transferline and that needs to be accounted for in the report which currently it only shows the transferheader cost code.
*/

-- find columns within schema
SELECT      COLUMN_NAME AS 'ColumnName', TABLE_NAME AS  'TableName'
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%ratesheet%' -- replace val with desired col name
ORDER BY    TableName, ColumnName

--
------ WORK -----
--

select top 10 CostCodes, *
	from ToolBrowser

	
-- NULL ToCostCodeId affecting server performance
select ToCostCodeId, FromCostCodeId, ToCostCenterId, FromCostCenterId, * from TransferLines
	where ToCostCenterId IS NULL
		OR FromCostCodeId IS NULL
		OR ToCostCenterId IS NULL
		OR FromCostCenterId IS NULL


select top 100 tl.ToCostCodeId as LineToCode, th.CostCodeIDTo as HeadToCode, -- to code 
	tl.FromCostCodeId as LineFromCode, th.CostCodeIdFrom as HeadFromCode, -- from code
	tl.ToCostCenterId as LineToCenter, th.CostCenterIdTo as HeadToCenter, -- to cent
	tl.FromCostCenterId as LineFromCenter, th.CostCenterIdFrom as HeadFromCenter, -- from cent
	* from TransferHeaders th
join TransferLines tl (NOLOCK) ON tl.TransferHeaderId = th.TransferHeaderId
	where ToCostCenterId IS NULL
		OR FromCostCodeId IS NULL
		OR ToCostCenterId IS NULL
		OR FromCostCenterId IS NULL

select * from RateSheetLines

select * from CostCodes


/*
	DEV NOTES

	if TO header has CostCenterIdFrom than TO line has FromCostCenterId

	if TO header has CostCenterIdTo than TO line has ToCostCenterId

	no correlation to TO header or TO line costCode

	COALESCE(th.CostCodeIDTo, tl.ToCostCodeId) -- elim NULLS (line first, than header so reverse logic)

	-- looks like anytime there is a header CostCenterTo, there is atleast a header CostCodeIdTo

*/


--
---- CLIENT SUPPLIED QUERY (formatted) ------
--

SELECT
	tb.Assignment,
	tb.AssignmentEntityNumber as Job,
	tb.LastTransferDate, tb.LastTransferNumber, tb.ItemNumber,
	tb.Description, tb.Quantity,
	--rsl.Description as RateSheet,
	ccode.Description as CostCode,
	ccent.RateSheetIdTools, rsh.Type,
	rsh.MonthlyRate, ccent.Description,
	CASE
		WHEN rsh.MonthlyRate >0
		THEN rsh.MonthlyRate *176
	ELSE 0 END AS 'Monthly Rate'
FROM Toolbrowser tb
	JOIN Ratesheetlines rsh (NOLOCK) ON tb.ModelId = rsh.ModelId
	JOIN TransferHeaders th (NOLOCK) ON th.CostCodeIDTo = rsh.CostCodeId
	JOIN TransferLines tl (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId
	JOIN CostCenters ccent (NOLOCK) ON tl.ToCostCenterId=  ccent.CostCenterId
	JOIN CostCodes ccode (NOLOCK) ON tl.ToCostCodeId = ccode.CostCodeId
	JOIN BillingLines bl (NOLOCK) ON bl.CostCenterId = tl.ToCostCenterId
	--JOIN RateSheetHeaders ON CostCenters.RateSheetIdTools=RateSheetHeaders.RateSheetHeaderId
	JOIN RateSheetLines rsl (NOLOCK) ON rsh.RateSheetHeaderId = rsl.RateSheetHeaderId
		WHERE tb.Assignment IS NOT NULL and tb.Assignment != 'Yard'
		ORDER BY Assignment, ItemNumber

/*
	SELECT CRITERIA

	tb.Assignment,
	tb.AssignmentEntityNumber as Job,
	tb.LastTransferDate, tb.LastTransferNumber, tb.ItemNumber,
	tb.Description, tb.Quantity,
	--rsl.Description as RateSheet,
	ccode.Description as CostCode,
	ccent.RateSheetIdTools, rsh.Type,
	rsh.MonthlyRate, ccent.Description,
	CASE
		WHEN rsh.MonthlyRate >0
		THEN rsh.MonthlyRate *176
	ELSE 0 END AS 'Monthly Rate'

*/

SELECT DISTINCT
	tb.Assignment,
	tb.AssignmentEntityNumber as Job,
	tb.LastTransferDate, tb.LastTransferNumber, tb.ItemNumber,
	tb.Description, tb.Quantity--,
	--rsl.Description as RateSheet,
	--ccode.Description as CostCode

FROM ToolBrowser tb 
	JOIN TransferLines tl (NOLOCK) ON tl.TransferLineId = tb.LastTransferLineId
	JOIN TransferHeaders th (NOLOCK) ON th. TransferHeaderId = tl.TransferHeaderId
	JOIN CostCenters ccent (NOLOCK) ON ccent.CostCenterId = tl.ToCostCenterId
	--LEFT JOIN CostCodes ccodeHeaderTo (NOLOCK) ON ccodeHeaderTo.CostCenterId = ccentHeaderTo.CostCenterId
	JOIN CostCodes ccode (NOLOCK) ON ccode.CostCodeId = tl.ToCostCodeId
	JOIN RateSheetHeaders rsh (NOLOCK) ON rsh.RateSheetHeaderId = ccentTo.RateSheetIdTools
	JOIN RateSheetLines rsl (NOLOCK) ON rsl.CostCodeId = ccode.CostCodeId

	

FROM Toolbrowser tb
	JOIN Ratesheetlines rsh (NOLOCK) ON tb.ModelId = rsh.ModelId
	JOIN TransferHeaders th (NOLOCK) ON th.CostCodeIDTo = rsh.CostCodeId
	JOIN TransferLines tl (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId
	JOIN CostCenters ccent (NOLOCK) ON tl.ToCostCenterId=  ccent.CostCenterId
	JOIN CostCodes ccode (NOLOCK) ON tl.ToCostCodeId = ccode.CostCodeId
	JOIN BillingLines bl (NOLOCK) ON bl.CostCenterId = tl.ToCostCenterId
	--JOIN RateSheetHeaders ON CostCenters.RateSheetIdTools=RateSheetHeaders.RateSheetHeaderId
	JOIN RateSheetLines rsl (NOLOCK) ON rsh.RateSheetHeaderId = rsl.RateSheetHeaderId
		WHERE tb.Assignment IS NOT NULL and tb.Assignment != 'Yard'
		ORDER BY Assignment, ItemNumber

select LastTransferLineId, * from ToolBrowser

