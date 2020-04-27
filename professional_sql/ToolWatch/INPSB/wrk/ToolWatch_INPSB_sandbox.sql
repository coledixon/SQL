
-- client query
SELECT DISTINCT Assignment, AssignmentEntityNumber as Job, LastTransferDate, LastTransferNumber, ItemNumber,
	tb.Description, tb.Quantity, rsh.Description as RateSheet,
	code.Description as CostCode, cent.RateSheetIdTools, rsl.Type, rsl.MonthlyRate, cent.Description,
	CASE WHEN rsl.MonthlyRate >0 
		THEN rsl.MonthlyRate * 176 ELSE 0 END AS 'Monthly Rate'
FROM Toolbrowser tb
	JOIN Ratesheetlines rsl (NOLOCK) ON tb.ModelId = rsl.ModelId 
	JOIN TransferLines tl (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId -- done
	JOIN CostCenters cent (NOLOCK) ON tl.ToCostCenterId = cent.CostCenterId -- done
	JOIN CostCodes code (NOLOCK) ON tl.ToCostCodeId = code.CostCodeId -- done
	JOIN BillingLines bl (NOLOCK) ON rsl.RatesheetLineID = bl.RateSheetLineId
	INNER JOIN RateSheetHeaders rsh (NOLOCK) ON cent.RateSheetIdTools = rsh.RateSheetHeaderId
	INNER JOIN RateSheetLines rs (NOLOCK) ON rsh.RateSheetHeaderId = rs.RateSheetHeaderId
		WHERE Assignment IS NOT NULL and Assignment != 'Yard' and bl.CostCenterId = tl.ToCostCenterId
		ORDER BY Assignment, ItemNumber



-- WORK

SELECT  * /*
	Assignment, AssignmentEntityNumber as Job, LastTransferDate, LastTransferNumber, ItemNumber,
	tb.Description, tb.Quantity, --rsh.Description as RateSheet,
	code.Description as CostCode, cent.RateSheetIdTools, rsl.Type, rsl.MonthlyRate, cent.Description,
	CASE WHEN rsl.MonthlyRate >0 
		THEN rsl.MonthlyRate * 176 ELSE 0 END AS 'Monthly Rate'
*/
	FROM TransferHeaders th
		JOIN TransferLines tl (NOLOCK) ON th.TransferHeaderId = tl. TransferHeaderId AND th.CostCenterIdTo IS NOT NULL -- if header has CostCenterIdTo, either header or line has a cost code to COALESCE()
		JOIN CostCenters ccent (NOLOCK) ON ccent.CostCenterId = tl.ToCostCenterId
		JOIN RateSheetHeaders rsh (NOLOCK) ON rsh.RateSheetHeaderId = ccent.RateSheetIdTools
		-- move to end?? need to elim head v. line -- JOIN CostCodes ccode (NOLOCK) ON COALESCE(tl.ToCostCodeId, th.CostCodeIDTo) = ccode.CostCodeId -- elim NULLs
		JOIN BillingLines bl (NOLOCK) ON bl.CostCenterId = ccent.CostCenterId
		JOIN RateSheetLines rsl (NOLOCK) ON rsl.RateSheetHeaderId = rsh.RateSheetHeaderId
		LEFT JOIN ToolBrowser tb (NOLOCK) ON tb.LastTransferLineId = tl.TransferLineId
			WHERE Assignment IS NOT NULL and Assignment != 'Yard' and bl.CostCenterId = tl.ToCostCenterId
				ORDER BY Assignment, ItemNumber
	










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
	

