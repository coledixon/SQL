/*
	PINKARD TOOL REPORTING (V3)
		Cole Dixon :: Copyright 2020- 2021 :: All Rights Reserved
	NOTES:
		/* ---- 05/26/2020 ---- */
		-- added COALESCE() to SELECT in order to filter NULLS for cleaner data return
		-- added CASE WHEN THEN to SELECT to further filter the NULLS from the TO Header to TO line for CostCodes
		-- aliased all JOINS and added (NOLOCK)
		-- changed filtering throgh tables by restructuring the query body (JOINs)
		-- used FULL JOINs to get data items with NULL values on key columns (this will slow the query down when being ran open)
		-- created 2 LEFT JOINS to CostCodes in order to filter the TO Header vs. TO Line
		-- removed the JOIN to BillingSheetLines as this is not used in SELECT, WHERE, on in filtering via JOIN
		-- added (rsl.Type <> 'Job Costing' OR rsl.type IS NULL) to further filter data and include data items with NULL RateSheet values
		/* ----- 06/09/2021 ----- */
		-- per CTE guidelines, changed first CTE to ;WITH (this should prevent any batching syntax errors)
		/* ---- 07/07/2021 ---- */
		-- use of WITH for temp tables and more robust functionality
		-- compile the totals per item type
		-- JOIN tools_equipment into base query
		-- FORMAT() final_total output for presentation purposes
*/
-- PURPOSE: tracking tool costing by location

-- BEGIN - CD 07/07/2021 
;WITH tools_equipment AS
(
	-- totals of all Tools & Equipment on a posted billing header and not 'pending' on the billing line by cost center
	SELECT DISTINCT SUM(bl.Quantity * bl.ChargeEach) AS ToolsEquipmentTotal, bl.itemid, bl.CostCenterId 
	FROM BillingHeaders bh
		JOIN BillingLines bl WITH (NOLOCK) ON bh.BillingHeaderId = bl.BillingHeaderId
		JOIN RateSheetLines rsl WITH (NOLOCK) ON rsl.RateSheetLineId = bl.RateSheetLineId
	WHERE bh.PostingNumber IS NOT NULL 
		AND bl.type like '%charge'
		AND bl.ItemGroup = 'Tools & Equipment'
	GROUP BY bl.CostCenterId, bl.ItemId
)
-- END - CD 07/07/2021

---- FINAL SELECT (utilizing Pinkard's internal modifications to original project query)
SELECT DISTINCT
	tb.Assignment
	, tb.AssignmentEntityNumber as Job#
	, COALESCE(tb.LastTransferDate,'') as LastTransferDate
	, COALESCE(tb.LastTransferNumber, '') as Transfer#
	, tb.ItemNumber as Tool# -- CD 05/2020
	, FORMAT(tools.ToolsEquipmentTotal, '##,###,##0.##') as TotalPostedToDate -- CD 07/07/2021
	, tb.Description as ToolDescription
	, tb.Quantity
	, COALESCE(rsh.Description,'') as RateSheet -- CD 05/2020
	, CASE
		WHEN th.CostCodeIDTo = codeHead.CostCodeId
		THEN codeHead.Number
		ELSE codeLine.Number
	END as PhaseCodeNumber      
	-- CD 05/2020: begin
	, COALESCE(CASE
		WHEN th.CostCodeIDTo = codeHead.CostCodeId
		THEN codeHead.Description
		ELSE codeLine.Description
	END,'') as PhaseCodeDescription
	, tb.ReplacementCost,
	-- CD: end
	CASE
		WHEN rsl.MonthlyRate > 0
		THEN rsl.MonthlyRate * 176
	ELSE 0
	END as MonthlyRate
FROM Toolbrowser tb
	FULL JOIN TransferLines tl WITH (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
	FULL JOIN TransferHeaders th WITH (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId -- CD 05/2020
	FULL JOIN CostCenters cent WITH (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId OR th.CostCenterIdTo = cent.CostCenterId
	FULL JOIN RateSheetHeaders rsh WITH (NOLOCK) ON rsh.RateSheetHeaderId = cent.RateSheetIdTools
	FULL JOIN RateSheetLines rsl WITH (NOLOCK) ON rsh.RateSheetHeaderId = rsl.RateSheetHeaderId and tb.ModelId = rsl.ModelId
	LEFT JOIN CostCodes codeHead WITH (NOLOCK) ON th.CostCodeIDTo = codeHead.CostCodeId -- CD 05/2020
	LEFT JOIN CostCodes codeLine WITH (NOLOCK) ON tl.ToCostCodeId = codeLine.CostCodeId -- CD 05/2020
	LEFT JOIN tools_equipment tools WITH (NOLOCK) ON tools.CostCenterId = cent.CostCenterId AND tools.ItemId = tb.ItemId -- CD 07/07/2021
WHERE tb.Assignment IS NOT NULL and tb.Assignment <> 'Yard'
	AND (rsl.Type <> 'Job Costing' OR rsl.type IS NULL) -- CD 05/20202
 ORDER BY tb.Assignment asc, tb.ItemNumber asc