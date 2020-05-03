
-- client query
SELECT DISTINCT Assignment, AssignmentEntityNumber as Job, LastTransferDate, LastTransferNumber, ItemNumber,
	tb.Description, tb.Quantity, rsh.Description as RateSheet,
	code.Description as CostCode, cent.RateSheetIdTools, rsl.Type, rsl.MonthlyRate, cent.Description,
	CASE WHEN rsl.MonthlyRate >0 
		THEN rsl.MonthlyRate * 176 ELSE 0 END AS 'Monthly Rate'
FROM Toolbrowser tb
	full JOIN Ratesheetlines rsl (NOLOCK) ON tb.ModelId = rsl.ModelId 
	full JOIN TransferLines tl (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId -- done
	full JOIN CostCenters cent (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId -- done
	full JOIN CostCodes code (NOLOCK) ON tl.ToCostCodeId = code.CostCodeId -- done
	JOIN BillingLines bl (NOLOCK) ON rsl.RatesheetLineID = bl.RateSheetLineId
	INNER JOIN RateSheetHeaders rsh (NOLOCK) ON cent.RateSheetIdTools = rsh.RateSheetHeaderId
	INNER JOIN RateSheetLines rs (NOLOCK) ON rsh.RateSheetHeaderId = rs.RateSheetHeaderId
		WHERE Assignment IS NOT NULL and Assignment != 'Yard' and bl.CostCenterId = tl.ToCostCenterId
		ORDER BY Assignment, ItemNumber



-- WORK

SELECT DISTINCT tb.Assignment, tb.AssignmentEntityNumber as Job, tb.LastTransferDate, tb.LastTransferNumber, tb.ItemNumber,
	tb.Description, tb.Quantity, rsh.Description as RateSheet,
	--code.Description as CostCode, cent.RateSheetIdTools, rsl.Type, rsl.MonthlyRate, cent.Description,
	CASE WHEN rsl.MonthlyRate >0 
		THEN rsl.MonthlyRate * 176 ELSE 0 END AS 'Monthly Rate'
	FROM ToolBrowser tb
		JOIN TransferLines tl (NOLOCK) ON tl.TransferLineId = tb.LastTransferLineId
		JOIN RateSheetLines rsl (NOLOCK) ON tl.ToCostCodeId = rsl.CostCodeId
		JOIN RateSheetHeaders rsh (NOLOCK) ON rsh.RateSheetHeaderId = tb
		LEFT JOIN CostCenters ccent (NOLOCK) ON ccent.CostCenterId = tb.CostCenterIdTo
		JOIN TransferLines tl (NOLOCK) ON th.TransferHeaderId = tl. TransferHeaderId -- tl costcode line might still be NULL
		-- JOIN CostCenters ccent (NOLOCK) ON ccent.CostCenterId = tl.ToCostCenterId
		JOIN RateSheetHeaders rsh (NOLOCK) ON rsh.RateSheetHeaderId = ccent.RateSheetIdTools
		-- move to end?? need to elim head v. line -- JOIN CostCodes ccode (NOLOCK) ON COALESCE(tl.ToCostCodeId, th.CostCodeIDTo) = ccode.CostCodeId -- elim NULLs
		JOIN RateSheetLines rsl (NOLOCK) ON rsl.RateSheetHeaderId = rsh.RateSheetHeaderId
		JOIN BillingLines bl (NOLOCK) ON bl.CostCenterId = ccent.CostCenterId
		LEFT JOIN ToolBrowser tb (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
			WHERE Assignment IS NOT NULL and Assignment != 'Yard' and bl.CostCenterId = tl.ToCostCenterId
				ORDER BY Assignment, ItemNumber
	

-- WRL 2

SELECT top 10 * /*
	Assignment, AssignmentEntityNumber as Job, LastTransferDate, LastTransferNumber, ItemNumber,
	tb.Description, tb.Quantity, --rsh.Description as RateSheet,
	code.Description as CostCode, cent.RateSheetIdTools, rsl.Type, rsl.MonthlyRate, cent.Description,
	CASE WHEN rsl.MonthlyRate >0 
		THEN rsl.MonthlyRate * 176 ELSE 0 END AS 'Monthly Rate'
*/
	FROM TransferHeaders th
		JOIN TransferLines tl (NOLOCK) ON th.TransferHeaderId = tl. TransferHeaderId
		JOIN CostCodes ccode (NOLOCK) ON tl.ToCostCodeId = ccode.CostCodeId -- does not work due to NULL on tl (trickle down)
		JOIN CostCenters ccent (NOLOCK) ON ccent.CostCenterId = ccode.CostCenterId
		JOIN BillingLines bl (NOLOCK) ON bl.CostCenterId = ccent.CostCenterId
		JOIN RateSheetHeaders rsh (NOLOCK) ON rsh.RateSheetHeaderId = bl.RateSheetHeaderId
		JOIN RateSheetLines rsl (NOLOCK) ON rsl.RateSheetHeaderId = rsh.RateSheetHeaderId
		LEFT JOIN ToolBrowser tb (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
			WHERE Assignment IS NOT NULL and Assignment != 'Yard' and bl.CostCenterId = tl.ToCostCenterId
				ORDER BY Assignment, ItemNumber
	

