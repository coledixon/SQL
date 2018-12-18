
DECLARE @ReportId int
SELECT TOP 1 @ReportId = (ReportId + 1) 
	FROM toaMastReport
	ORDER BY ReportId DESC

-- POReceiptLabel_Allergen
IF NOT EXISTS(SELECT TOP 1 1 FROM toaMastReport WHERE Filename = 'POReceiptLabel_Allergen.rpt')
BEGIN
	INSERT INTO dbo.toaMastReport (CompanyID, ReportID, ReportType, Filename, Description, IsVersionOf, PrintTo) 
	VALUES ('BMR', @ReportId, 0, 'POReceiptLabel_Allergen.rpt', 'POReceiptLabel_Allergen', 0, 'Label 4')

	INSERT INTO dbo.toaSysReport(CompanyID, ReportId, SystemReportID, Command, Description, EntryType, Module, IsERPReport, IsO2Report, ShowOnMenu) 
	VALUES ('BMR', @ReportId, 'POReceiptLabel_Allergen', '', 'POReceiptLabel_Allergen', 'R', 'PO', 0, 0, 'Y')
END

GO

-- validate report were created
SELECT * FROM toaMastReport a
	JOIN toaSysReport b (NOLOCK) ON a.ReportID = b.ReportID
	WHERE Filename LIKE '%Allergen%'

GO