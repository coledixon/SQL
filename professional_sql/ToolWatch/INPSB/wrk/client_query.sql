--
---- CLIENT SUPPLIED QUERY (formatted) ------
--

select top 100
	Assignment,
	AssignmentEntityNumber as Job,
	LastTransferDate, LastTransferNumber, ItemNumber,
	ToolBrowser.Description, ToolBrowser.Quantity,
	RateSheetHeaders.Description as RateSheet,
	CostCodes.Description as CostCode,
	CostCenters.RateSheetIdTools, RatesheetLines.Type,
	RateSheetLines.MonthlyRate, CostCenters.Description,
	CASE
		WHEN RateSheetLines.MonthlyRate >0
		THEN RateSheetLines.MonthlyRate *176
	ELSE 0
	END AS 'Monthly Rate'
FROM Toolbrowser
	FULL JOIN Ratesheetlines ON Toolbrowser.ModelId = RatesheetLines.ModelId
	FULL JOIN TransferLines ON ToolBrowser.LastTransferLineId=TransferLineId
	FULL JOIN CostCenters ON TransferLines.ToCostCenterId=CostCenters.CostCenterId
	FULL JOIN CostCodes ON TransferLines.ToCostCodeId=CostCodes.CostCodeId
	FULL JOIN BillingLines On RateSheetLines.RatesheetLineID = BillingLines.RateSheetLineId
	INNER JOIN RateSheetHeaders ON CostCenters.RateSheetIdTools=RateSheetHeaders.RateSheetHeaderId
	INNER JOIN RateSheetLines as RS ON RateSheetHeaders.RateSheetHeaderId=RS.RateSheetHeaderId
		WHERE Assignment IS NOT NULL and Assignment != 'Yard' and BillingLines.CostCenterId = Transferlines.ToCostCenterId
		ORDER BY Assignment, ItemNumber