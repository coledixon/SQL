
/*
	Jobs with total numbers not matching; toolbrowser vs. cost code report
	job # - toolbrowser vs. sql report
	1186. - 51 vs. 47
	1202. - 66 vs. 61
	1216. - 9 vs. 7
	1218. - 34 vs. 32
*/


SELECT  itemnumber, itemid, * FROM ToolBrowser tb
	WHERE AssignmentEntityNumber = '1202.' 
	ORDER BY tb.ItemNumber desc

select th.transferheaderid, tb.AssignmentEntityNumber, tb.ItemNumber,
	th.CostCodeIdFrom, th.CostCodeIDTo, -- header code
	tl.FromCostCodeId, tl.ToCostCodeId, -- line code
	th.CostCenterIdTo, th.CostCenterIdFrom, -- header cent
	tl.ToCostCenterId, tl.FromCostCenterId -- line cent
from ToolBrowser tb  
	FULL JOIN TransferLines tl (NOLOCK) on tl.TransferLineId = tb.LastTransferLineId
	FULL JOIN TransferHeaders th (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId
	where AssignmentEntityNumber = '1186.' and Assignment <> 'Yard'
	ORDER BY tb.ItemNumber desc, tb.AssignmentEntityNumber DESC, th.CreatedOn DESC

/*
	MISSING ITEMNUMBERS 
	1186. - 51 vs. 47
		9942-03 - no LastTransferLineId - no RateSheetId...
		460
		394
		34796
	1202. - 66 vs. 61
		9942-03 - no LastTransferLineId
		9932-01 - no LastTransferLineId
		9917-01 
		9902-96
		4-1458 - no LastTransferLineId
	1216.
		9942-04 - no LastTransferLineId
		4-424 - no LastTransferLineId
*/

SELECT DISTINCT 
	tb.Assignment,
	tb.AssignmentEntityNumber as Job,
	tb.LastTransferDate, tb.LastTransferNumber, tb.ItemNumber,
	tb.Description, tb.Quantity,
	rs.Description as RateSheet,
	-- CD: begin
	CASE
		WHEN th.CostCodeIDTo = codeHead.CostCodeId 
		THEN codeHead.Description 
		ELSE codeLine.Description
	END as CostCode,
	-- CD: end
	cent.RateSheetIdTools, cent.RateSheetIdMaterials, cent.RateSheetIdLabor, 
	rsl.Type, cent.Description, rsl.MonthlyRate as BaseMonthlyRate,
	CASE
		WHEN rsl.MonthlyRate > 0
		THEN rsl.MonthlyRate * 176
	ELSE 0
	END as MonthlyRate 
FROM Toolbrowser tb
	FULL JOIN TransferLines tl (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
	FULL JOIN TransferHeaders th (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId -- CD 05/2020
	FULL JOIN CostCenters cent (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId OR th.CostCenterIdTo = cent.CostCenterId
	LEFT JOIN CostCodes codeHead (NOLOCK) ON th.CostCodeIDTo = codeHead.CostCodeId -- CD 05/2020
	LEFT JOIN CostCodes codeLine (NOLOCK) ON tl.ToCostCodeId = codeLine.CostCodeId -- CD 05/2020
	FULL JOIN RateSheetHeaders rs (NOLOCK) ON cent.RateSheetIdTools = rs.RateSheetHeaderId
	FULL JOIN RateSheetLines rsl (NOLOCK) ON rs.RateSheetHeaderId = rsl.RateSheetHeaderId and tb.ModelId = rsl.ModelId
	FULL JOIN BillingLines bl (NOLOCK) ON rsl.RatesheetLineID = bl.RateSheetLineId AND bl.CostCenterId = tl.ToCostCenterId OR bl.CostCenterId = th.CostCenterIdTo -- CD 05/2020
		WHERE Assignment IS NOT NULL and Assignment <> 'Yard' 
			and rsl.Type <> 'Job Costing' and tb.AssignmentEntityNumber = '1186.' 
		ORDER BY tb.ItemNumber desc, tb.Assignment desc
		


/*
th.CostCodeIdFrom IS NULL
		AND th.CostCodeIDTo IS NULL
		-- line
		AND tl.FromCostCodeId IS NULL
		AND tl.ToCostCodeId IS NULL
*/

SELECT      COLUMN_NAME AS 'ColumnName', TABLE_NAME AS  'TableName'
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%ratesheet%' -- replace val with desired col name
ORDER BY    TableName, ColumnName
