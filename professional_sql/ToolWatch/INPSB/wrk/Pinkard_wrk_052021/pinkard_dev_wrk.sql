

;

-- BEGIN - CD 05/17/2021 
-- compile the totals per item type, then calc the final total
WITH tools_equipment AS
(
	SELECT DISTINCT SUM(bl.Quantity * bl.ChargeEach) AS ToolsEquipmentTotal, bl.CostCenterId 
	FROM BillingHeaders bh
		JOIN BillingLines bl WITH (NOLOCK) ON bh.BillingHeaderId = bl.BillingHeaderId
		JOIN RateSheetLines rsl WITH (NOLOCK) ON rsl.RateSheetLineId = bl.RateSheetLineId
	WHERE bh.PostingNumber IS NOT NULL 
		AND bl.type like '%charge'
		AND bl.ItemGroup = 'Tools & Equipment'
	GROUP BY bl.CostCenterId
)
, materials_consumables AS
(
	SELECT SUM(bl.Quantity * bl.ChargeEach) AS MaterialsConsumablesTotal, bl.CostCenterId 
	FROM BillingHeaders bh
		JOIN BillingLines bl WITH (NOLOCK) ON bh.BillingHeaderId = bl.BillingHeaderId
		JOIN RateSheetLines rsl WITH (NOLOCK) ON rsl.RateSheetLineId = bl.RateSheetLineId
	WHERE bh.PostingNumber IS NOT NULL 
		AND bl.type like '%charge'
		AND bl.ItemGroup = 'Materials & Consumables'
	GROUP BY bl.CostCenterId
)
, misc_charges AS
(
	SELECT SUM(Charge) AS MiscChargesTotal, bmc.CostCenterId  
	FROM BillingMiscCharges bmc
	WHERE PostingNumber IS NOT NULL 
	GROUP BY bmc.CostCenterId
)
, final_total AS
(
	SELECT DISTINCT sum(a.ToolsEquipmentTotal + b.MaterialsConsumablesTotal + c.MiscChargesTotal) AS total_posted, c.CostCenterId
	FROM tools_equipment a
		JOIN materials_consumables b WITH (NOLOCK) ON a.CostCenterId = b.CostCenterId
		JOIN misc_charges c WITH (NOLOCK) ON b.CostCenterId = c.CostCenterId
	GROUP BY c.CostCenterId
)
-- END - CD 05/17/2021

-- final SELECT
SELECT DISTINCT
	tb.Assignment,
	tb.AssignmentEntityNumber AS Job,
	FORMAT(t.total_posted, '###,##0.##') as TotalPostedToDate, -- CD 05/17/2021: FORMAT() for presentation purposes
	COALESCE(tb.LastTransferDate,'') AS LastTransferData, COALESCE(tb.LastTransferNumber, '') AS LastTransferNumber, tb.ItemNumber, -- CD 05/2020
	tb.Description, tb.Quantity,
	COALESCE(rsh.Description,'') AS RateSheet, -- CD 05/2020
	-- CD 05/2020: begin
	COALESCE(
		CASE
			WHEN th.CostCodeIDTo = codeHead.CostCodeId 
			THEN codeHead.Description
			ELSE codeLine.Description
	END,'') AS CostCode,
	-- CD: end
	COALESCE(CAST(cent.RateSheetIdTools AS VARCHAR(MAX)), '') AS RateSheetIdTools, COALESCE(rsl.Type,'') AS Type, -- CD 05/2020
	COALESCE(rsl.MonthlyRate,'') AS MonthlyRate, COALESCE(cent.Description,'') AS Description, -- CD 05/2020
	CASE
		WHEN rsl.MonthlyRate > 0
		THEN rsl.MonthlyRate * 176
	ELSE 0
	END AS MonthlyRate
FROM Toolbrowser tb
	FULL JOIN TransferLines tl WITH (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
	FULL JOIN TransferHeaders th WITH (NOLOCK) ON th.TransferHeaderId = tl.TransferHeaderId -- CD 05/2020
	FULL JOIN CostCenters cent WITH (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId OR th.CostCenterIdTo = cent.CostCenterId
	FULL JOIN RateSheetHeaders rsh WITH (NOLOCK) ON rsh.RateSheetHeaderId = cent.RateSheetIdTools
	FULL JOIN RateSheetLines rsl WITH (NOLOCK) ON rsh.RateSheetHeaderId = rsl.RateSheetHeaderId AND tb.ModelId = rsl.ModelId
	LEFT JOIN CostCodes codeHead WITH (NOLOCK) ON th.CostCodeIDTo = codeHead.CostCodeId -- CD 05/2020
	LEFT JOIN CostCodes codeLine WITH (NOLOCK) ON tl.ToCostCodeId = codeLine.CostCodeId -- CD 05/2020
	JOIN final_total t WITH (NOLOCK) ON t.CostCenterId = cent.CostCenterId -- CD 05/17/2021
WHERE tb.Assignment IS NOT NULL AND tb.Assignment <> 'Yard' 
	AND (rsl.Type <> 'Job Costing' OR rsl.type IS NULL) -- CD 05/2020
ORDER BY tb.Assignment desc, tb.ItemNumber desc
