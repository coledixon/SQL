/*
	CUSTOM NOTES

	- add posted per cost center to view
	- total billed (posted) for life of cost center
	- new col: TotalPostToDate
	- Pinkard uses jobCost + Billing = RateSheet
*/

-- find columns within schema
SELECT      COLUMN_NAME AS 'ColumnName', TABLE_NAME AS  'TableName'
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%billingheaderid%' -- replace val with desired col name
ORDER BY    TableName, ColumnName

--
------ WORK -----
--

-- number = 1223.
-- costcenterid = 33E0B36E-0D0D-4F66-B946-FD5869B4BCD7
select * from CostCenters
where number = '1223.'

select * from BillingHeaders
where ItemGroup in ('Tools & Equipment', 'Materials & Consumables')
	and PostingNumber IS NOT NULL
order by PostedOn desc

select SUM(bl.Quantity * bl.ChargeEach) as a from BillingHeaders bh
join BillingLines bl with (nolock) on bh.BillingHeaderId = bl.BillingHeaderId
join RateSheetLines rsl with (nolock) on rsl.RateSheetLineId = bl.RateSheetLineId
where CostCenterId = '33E0B36E-0D0D-4F66-B946-FD5869B4BCD7'
	and bh.PostingNumber IS NOT NULL and bl.type like '%charge'
	--and bh.IsPostable = 1
	--and bh.ItemGroup in ('Tools & Equipment', 'Materials & Consumables')
	and bl.ItemGroup = 'Tools & Equipment'

select SUM(Charge) from BillingMiscCharges
where CostCenterId = '33E0B36E-0D0D-4F66-B946-FD5869B4BCD7'
	and PostingNumber IS NOT NULL


select * from RateSheetLines

select * from CostCodes


/*
	DEV NOTES
	Cost Center to use is #1223.  - Kavod Senior Life
	To date postings amount to: $107,801.96 (as of 05/07/2021 @ 12:27pm) -- 107847.3500
	the postings consist of TOOLS & EQUIPMENT, MATERIALS & CONSUMABLES, and MISC CHARGES (misc charges I believe are in their own view)
	They will want to reference the billing side of the rate sheets

	-- tools & equipment SQL = 77138.6704 (select sum(quantity * chargeeach))	REPORT 77,138.67 GOOD
	-- materials & consumables SQL = 30157.5596	(cursor)	REPORT = 30,157.56  GOOD
	-- misc charges SQL = 505.73 (select SUM())		REPORT = 505.73 GOOD
*/

--
---- ORIGINAL CUSTOM ------
--

-- currently pulling 520 rows
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
WHERE tb.Assignment IS NOT NULL and tb.Assignment <> 'Yard' --/* CD DEBUG */ and cent.Number = '1223.'
	and (rsl.Type <> 'Job Costing' OR rsl.type IS NULL) -- CD 05/20202
ORDER BY tb.Assignment desc, tb.ItemNumber desc



select bl.PostedOn, bl.* from BillingHeaders bh
join BillingLines bl with (nolock) on bh.BillingHeaderId = bl.BillingHeaderId
join RateSheetLines rsl with (nolock) on rsl.RateSheetLineId = bl.RateSheetLineId
where CostCenterId = '33E0B36E-0D0D-4F66-B946-FD5869B4BCD7'
	and bh.PostingNumber IS NOT NULL and bl.type like '%charge'
	and bh.ItemGroup in ('Tools & Equipment', 'Materials & Consumables')
order by bl.PostedOn desc


-- total 
declare @quantity int
declare @chargeeach numeric(18,2)
declare @total numeric(18,2)

set @total = 0

declare d cursor for
select quantity, chargeeach from BillingLines
where CostCenterId = '33E0B36E-0D0D-4F66-B946-FD5869B4BCD7'
	and PostingNumber IS NOT NULL 
	and ItemGroup = 'Tools & Equipment'
	--and ItemGroup in ('Tools & Equipment', 'Materials & Consumables')
	and type like '%charge'

open d
fetch next from d into @quantity, @chargeeach

while @@FETCH_STATUS = 0
begin
	set @total = @total + (@quantity * @chargeeach)
	print @total

	fetch next from d into @quantity, @chargeeach
end

close d
deallocate d