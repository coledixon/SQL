/*
	PINKARD TOOL REPORTING (V2)
		Cole Dixon :: Copyright 2020

	NOTES:
		-- added COALESCE() to SELECT in order to filter NULLS for cleaner data return
		-- added CASE WHEN THEN to SELECT to further filter the NULLS from the TO Header to TO line for CostCodes
		-- aliased all JOINS and added (NOLOCK)
		-- changed filtering throgh tables by restructuring the query body (JOINs)
		-- used FULL JOINs to get data items with NULL values on key columns (this will slow the query down when being ran open)
		-- created 2 LEFT JOINS to CostCodes in order to filter the TO Header vs. TO Line
		-- removed the JOIN to BillingSheetLines as this is not used in SELECT, WHERE, on in filtering via JOIN
		-- added (rsl.Type <> 'Job Costing' OR rsl.type IS NULL) to further filter data and include data items with NULL RateSheet values
*/
-- PURPOSE: tracking tool costing by location

SELECT DISTINCT
	tb.Assignment,
	tb.AssignmentEntityNumber as Job,
	COALESCE(tb.LastTransferDate,'') as LastTransferData, COALESCE(tb.LastTransferNumber, ''), tb.ItemNumber, -- CD 05/2020
	tb.Description, tb.Quantity,
	COALESCE(rsh.Description,'') as RateSheet, -- CD 05/2020
	-- CD 05/2020: begin
	COALESCE(
		CASE
			WHEN th.CostCodeIDTo = codeHead.CostCodeId 
			THEN codeHead.Description
			ELSE codeLine.Description
	END,'') as CostCode,
	-- CD: end
	COALESCE(CAST(cent.RateSheetIdTools as VARCHAR(MAX)), '') as RateSheetIdTools, COALESCE(rsl.Type,'') as Type, -- CD 05/2020
	COALESCE(rsl.MonthlyRate,'') as MonthlyRate, COALESCE(cent.Description,'') as Description, -- CD 05/2020
	CASE
		WHEN rsl.MonthlyRate > 0
		THEN rsl.MonthlyRate * 176
	ELSE 0
	END as MonthlyRate
FROM Toolbrowser tb
	FULL JOIN TransferLines tl (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
	FULL JOIN TransferHeaders th (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId -- CD 05/2020
	FULL JOIN CostCenters cent (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId OR th.CostCenterIdTo = cent.CostCenterId
	FULL JOIN RateSheetHeaders rsh (NOLOCK) ON rsh.RateSheetHeaderId = cent.RateSheetIdTools
	FULL JOIN RateSheetLines rsl (NOLOCK) ON rsh.RateSheetHeaderId = rsl.RateSheetHeaderId and tb.ModelId = rsl.ModelId
	LEFT JOIN CostCodes codeHead (NOLOCK) ON th.CostCodeIDTo = codeHead.CostCodeId -- CD 05/2020
	LEFT JOIN CostCodes codeLine (NOLOCK) ON tl.ToCostCodeId = codeLine.CostCodeId -- CD 05/2020
		WHERE tb.Assignment IS NOT NULL and tb.Assignment <> 'Yard'
			and (rsl.Type <> 'Job Costing' OR rsl.type IS NULL) -- CD 05/20202
		ORDER BY tb.Assignment desc, tb.ItemNumber desc
