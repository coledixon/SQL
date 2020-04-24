

SELECT DISTINCT Assignment, AssignmentEntityNumber as Job, LastTransferDate, LastTransferNumber, ItemNumber,
	tb.Description, tb.Quantity, rsh.Description as RateSheet,
	code.Description as CostCode, cent.RateSheetIdTools, rsl.Type, rsl.MonthlyRate, cent.Description,
	CASE WHEN rsl.MonthlyRate >0 
		THEN rsl.MonthlyRate *176 ELSE 0 END AS 'Monthly Rate'
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