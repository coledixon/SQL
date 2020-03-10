-- resource for schema: https://developer.toolwatch.com/ReportingCloud

/*
	What I am looking for is detailed info (text I can import to excel) of each ITEM in our TOOL INVENTORY and it's LOCATION. 
	... where ITEMS were last year (2019), where ITEMS are this year (2020), and computes the CHANGE IN LOCATION.

	-- purchase

	-- VIEW FOR
	-- NEW / PURCHASED
	-- disposed/retired/discontinued VIEW (T,M,Q,K)	
		-- status (state?)
*/

-- SCHEMA: org_TODD1

-- find columns within schema
SELECT      COLUMN_NAME AS 'ColumnName', TABLE_NAME AS  'TableName'
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%purchasecost%' -- replace val with desired col name
ORDER BY    TableName, ColumnName

-- 'E' for employees, 'L' for locations (including stock locations)
select * from Entities where type = 'L'

-- 'T' for tools, 'M' for materials, 'A' for templates
select * from Categories

-- 	'T' for unique tools, 'Q' for quantity tools, 'K' for kits, 'M' for materials
select top 10 * from Models

-- 	'T' for unique tools, 'M' for materials -- no K or Q types on org_TODD1
	-- key = descriptionId --> Descriptions (for Tool / Material)
select * from Descriptions

-----
-- PICK TICKETS (items needed)
-----
-- pick headers (tickets to > from) PIVOT?
	-- pickFrom = LocationId (key = PickFromId)
	-- pickFor = JobSiteId (key = PickForId)
	-- pickeyBy = PickUser
select * from PickTicketHeaders

-- items picked (closed)
	-- FK = descriptionId / pickticketId / itemId / pickedFromId / PickedById
select * from PickTicketItemsPicked

-- items to pick (open)
select * from PickTicketItemsToPick

-----
-- ITEMS
-----
-- item master
select * from Items


-----
-- INVENTORY (but where?)
-----
-- Inventories tbl
	-- OwnerEntityId: the stock location that owns these assets
select * from Inventories
where ItemId = '34C98A57-38FD-4611-ADE9-86BB3936DACC'

select top 10 * from InventoryKeys


-----
-- STOCK (on hand?)
-----
select * from StockView


-----
-- TOOL INFO
-----

select top 100 * from ToolPurchaseCostInfo

select * from ToolPurchaseCostInfo
where ItemId = '34C98A57-38FD-4611-ADE9-86BB3936DACC'

select top 10 * from ToolInformation
order by ItemNumber

-----
-- TRANSFERS
-----
select top 10 b.Description, b.type, 
	CASE WHEN b.IsStockLocation > 1 THEN 'STOCK LOCATION' ELSE 'NOT STOCK LOCATION' END, TransferredFromEntityId as 'FROM', TransferredToEntityId as 'TO', * from TransferHeaders a
join Entities b (NOLOCK) on a.TransferredToEntityId = b.EntityId
where b.type = 'L'

select top 10 b.Description, b.type, 
	CASE WHEN b.IsStockLocation > 1 THEN 'STOCK LOCATION' ELSE 'NOT STOCK LOCATION' END, TransferredFromEntityId as 'FROM', TransferredToEntityId as 'TO', * from TransferHeaders a
join Entities b (NOLOCK) on a.TransferredToEntityId = b.EntityId
where b.type = 'L'

select * from TransferLines 
where TransferHeaderId = 'BC7A797E-9179-4BCF-A602-E73911578434'