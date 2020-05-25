/*
	PINKARD TOOL REPORTING
		Cole Dixon :: Copyright 2020

	NOTES:
		-- added CASE WHEN THEN to SELECT to further filter the NULLS from the TO Header to TO line for CostCodes
		-- aliased all JOINS and added (NOLOCK)
		-- removed FULL JOIN predicates, as this slowed the query down substantially
		-- created 2 LEFT JOINS to CostCodes in order to filter the TO Header vs. TO Line
		-- removed redundant JOIN to RateSheetLines as the data was never used in SELECT or to filter further
		-- moved the "BillingLines.CostCenterId = Transferlines.ToCostCenterId" from WHERE to JOIN
*/
-- PURPOSE: tracking tool costing by location

SELECT DISTINCT
	tb.Assignment,
	tb.AssignmentEntityNumber as Job,
	tb.LastTransferDate, tb.LastTransferNumber, tb.ItemNumber,
	tb.Description, tb.Quantity,
	RateSheetHeaders.Description as RateSheet,
	-- CD: begin
	CASE
		WHEN th.CostCodeIDTo = codeHead.CostCodeId 
		THEN codeHead.Description
		ELSE codeLine.Description
	END as CostCode,
	-- CD: end
	cent.RateSheetIdTools, rsl.Type,
	rsl.MonthlyRate, cent.Description,
	CASE
		WHEN rsl.MonthlyRate > 0
		THEN rsl.MonthlyRate * 176
	ELSE 0
	END as MonthlyRate
FROM Toolbrowser tb
	JOIN RateSheetLines rsl (NOLOCK) ON tb.ModelId = rsl.ModelId
	JOIN TransferLines tl (NOLOCK) ON tb.LastTransferLineId=TransferLineId
	JOIN TransferHeaders th (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId -- CD 05/2020
	JOIN CostCenters cent (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId
	LEFT JOIN CostCodes codeHead (NOLOCK) ON th.CostCodeIDTo = codeHead.CostCodeId -- CD 05/2020
	LEFT JOIN CostCodes codeLine (NOLOCK) ON tl.ToCostCodeId = codeLine.CostCodeId -- CD 05/2020
	JOIN BillingLines bl (NOLOCK) ON rsl.RatesheetLineID = bl.RateSheetLineId AND bl.CostCenterId = tl.ToCostCenterId -- CD 05/2020
	JOIN RateSheetHeaders ON cent.RateSheetIdTools = RateSheetHeaders.RateSheetHeaderId
	--CD 05/2020: REMOVED -- JOIN RateSheetLines as RS ON RateSheetHeaders.RateSheetHeaderId = RS.RateSheetHeaderId
		WHERE Assignment IS NOT NULL and Assignment != 'Yard' and AssignmentEntityNumber = '1202.'
		ORDER BY Assignment, ItemNumber