SELECT DISTINCT
	tb.Assignment,
	tb.AssignmentEntityNumber as Job,
	COALESCE(tb.LastTransferDate,'') as LastTransferData, COALESCE(tb.LastTransferNumber, ''), tb.ItemNumber,
	tb.Description, tb.Quantity,
	COALESCE(rsh.Description,'') as RateSheet,
	-- CD: begin
	COALESCE(
		CASE
			WHEN th.CostCodeIDTo = codeHead.CostCodeId 
			THEN codeHead.Description
			ELSE codeLine.Description
	END,'') as CostCode,
	-- CD: end
	COALESCE(CAST(cent.RateSheetIdTools as VARCHAR(MAX)), '') as RateSheetIdTools, COALESCE(rsl.Type,'') as Type,
	COALESCE(rsl.MonthlyRate,'') as MonthlyRate, COALESCE(cent.Description,'') as Description,
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
			and (rsl.Type <> 'Job Costing' OR rsl.type IS NULL)
		ORDER BY tb.ItemNumber desc, tb.Assignment desc
