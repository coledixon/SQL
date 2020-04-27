
/*
	Basically they are trying to get the report to show them what tools are at what jobs (assignments), 
	with a rate calculation, and the appropriate cost code. 
	
	The problem is that the cost code can either be on the transferheader or transferline and that needs to be accounted for in the report which currently it only shows the transferheader cost code.
*/

-- find columns within schema
SELECT      COLUMN_NAME AS 'ColumnName', TABLE_NAME AS  'TableName'
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%LastTransferDate%' -- replace val with desired col name
ORDER BY    TableName, ColumnName

--
------ WORK -----
--

SELECT DISTINCT Assignment, AssignmentEntityNumber as Job, LastTransferDate, LastTransferNumber, ItemNumber,
	tb.Description, tb.Quantity, rsh.Description as RateSheet,
	code.Description as CostCode, cent.RateSheetIdTools, rsl.Type, rsl.MonthlyRate, cent.Description,
	CASE WHEN rsl.MonthlyRate >0 
		THEN rsl.MonthlyRate *176 ELSE 0 END AS 'Monthly Rate'

SELECT DISTINCT *
FROM Toolbrowser tb
	JOIN Ratesheetlines rsl (NOLOCK) ON tb.ModelId = rsl.ModelId
	JOIN TransferLines tl (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
	JOIN CostCenters cent (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId
	JOIN CostCodes code (NOLOCK) ON tl.ToCostCodeId = code.CostCodeId
	JOIN BillingLines bl (NOLOCK) ON rsl.RatesheetLineID = bl.RateSheetLineId
	INNER JOIN RateSheetHeaders rsh (NOLOCK) ON cent.RateSheetIdTools = rsh.RateSheetHeaderId
	--INNER JOIN RateSheetLines rs (NOLOCK) ON rsh.RateSheetHeaderId = rs.RateSheetHeaderId
		WHERE Assignment IS NOT NULL and Assignment != 'Yard' and bl.CostCenterId = tl.ToCostCenterId
		ORDER BY Assignment, ItemNumber


select top 10 Assignment, *
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



/*
	DEV NOTES

	if TO header has CostCenterIdFrom than TO line has FromCostCenterId

	if TO header has CostCenterIdTo than TO line has ToCostCenterId

	no correlation to TO header or TO line costCode

	COALESCE(th.CostCodeIDTo, tl.ToCostCodeId) -- elim NULLS (line first, than header so reverse logic)

	-- looks like anytime there is a header CostCenterTo, there is atleast a header CostCodeIdTo

*/

