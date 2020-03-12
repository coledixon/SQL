/* TODD CONSTRUCTION WRK */

-------
--- Cole Dixon
--- 2020
-------


select top 10 b.Description, b.type, 
	CASE WHEN b.IsStockLocation > 0 THEN 'STOCK LOCATION' ELSE 'NOT STOCK LOCATION' END, TransferredFromEntityId as 'FROM', TransferredToEntityId as 'TO', * from TransferHeaders a
join Entities b (NOLOCK) on a.TransferredToEntityId = b.EntityId
where b.type = 'L'

select top 10 b.Description, b.type, 
	CASE WHEN b.IsStockLocation > 0 THEN 'STOCK LOCATION' ELSE 'NOT STOCK LOCATION' END, TransferredFromEntityId as 'FROM', TransferredToEntityId as 'TO', * from TransferHeaders a
join Entities b (NOLOCK) on a.TransferredToEntityId = b.EntityId
where b.type = 'L'

select * from Entities

select * from Descriptions

-- inventory on-hand by owner location
select b.Description, b.type, CASE WHEN b.IsStockLocation > 0 THEN 'STOCK LOCATION' ELSE 'NOT STOCK LOCATION' END, * 
	from Inventories a
	join Entities b (NOLOCK)	ON a.OwnerEntityId = b.EntityId

-- inventory on-hand by return location
select b.Description, b.type, CASE WHEN b.IsStockLocation > 0 THEN 'STOCK LOCATION' ELSE 'NOT STOCK LOCATION' END, *
	from Inventories a
	join Entities b (NOLOCK) ON a.ReturnToEntityId = b.EntityId
	
	
select en.Description, 
	CASE WHEN en.IsStockLocation > 0 THEN 'STOCK LOCATION' ELSE 'NOT STOCK LOCATION' END, * 
		from StockView sv
		join items i (NOLOCK) on i.ItemId = sv.ItemId
		join Entities en (NOLOCK) on sv.OwnerEntityId = en.EntityId

select * from StockView

select  * from Inventories
order by ReturnDate desc


-------
-- job sites
select * from Entities
where type = 'L' and IsStockLocation = 0

-- TC owned locations
select * from Entities
where type = 'L' and IsStockLocation = 1


-------
/*
	StockView.LastTransferLineId --> TransferLines.TransferLineId
	TransferLines.InventoryKeyId --> InventoryKeys.InventoryKeyId (narrow down with TransferLines.ItemId --> InventoryKeys.ItemId)
	InventoryKeys.OwnerEntityId --> Entities.EntityId ()
	InventoryKeys.EntityId --> Entities.EntityId
*/
select * from StockView

select * from TransferLines 
where TransferLineId = 'AA1B32A4-9133-4AAF-B534-5E9B9EEAD78C'

select top 10 * from InventoryKeys 
where InventoryKeyId = '05AB8574-D6B9-4365-93ED-9756C3A22EC3' and ItemId = 'E196BFF6-F6B8-4548-9387-0043BB27AE86'
-----

-- transfer header id -- created on 2020-02-27 11:30:39.727
-- '91B2F118-6398-458E-8FE4-9A9973A022E5'

-- transfer lines
-- 'DF5B6C3E-07B9-4C89-903B-C334E27DFD7C' (line 1)
	-- itemid 'B21DF199-3A8F-49BD-A35A-41F870621108'
-- 'BBF2D101-C7E2-4008-B282-D6FA642E4D00' (line 2)
	-- itemid '18F92DCC-3F91-46B5-A696-30F666FA0835'

-- items on TO
select ItemId, m.ModelId, c.Description, d.Description, * from Items i
join models m on i.ModelId = m.ModelId 
join Categories c on m.CategoryId = c.CategoryId
join Descriptions d on m.DescriptionId = d.DescriptionId
where ItemId = '18F92DCC-3F91-46B5-A696-30F666FA0835'
or itemid = 'B21DF199-3A8F-49BD-A35A-41F870621108'

select * from inventories
where ItemId = '364880BD-4B45-469C-A72F-08B230BB8CCD'
or  ItemId = 'F875675C-BB3E-4ADB-84A9-C78C7DD4C58C'

select itemid, Cost, ItemCreatedOn from ToolBrowser
UNION
select itemid, Cost, ItemCreatedOn from ToolBrowser


select * from ToolPurchaseCostInfo where ItemNumber = 52740

-- trans from
select * from Entities
where EntityId = '23A92A1B-1CA6-4232-8BF2-408415C0FE97'

-- trans to
select * from entities
where EntityId = '773AB3B8-BD77-4C3D-9B61-B9D1D27174C9'


select top 10 * from TransferHeaders
order by CreatedOn desc

select top 10 * from TransferLines
where TransferHeaderId = 'B46110B5-9235-4937-B690-6348F5A2317E'

select * from Items where ItemId = '364880BD-4B45-469C-A72F-08B230BB8CCD'

select * from ToolBrowser where ItemId = '364880BD-4B45-469C-A72F-08B230BB8CCD'
order by LastTransferDate desc


select distinct itemid from ToolBrowser --where ItemId = '364880BD-4B45-469C-A72F-08B230BB8CCD'
order by LastTransferDate desc

select * from ToolPurchaseCostInfo where ItemId = '364880BD-4B45-469C-A72F-08B230BB8CCD'


--- tool views
select * from ToolBrowser
where ItemId = 'E2A10444-7755-4C2D-B72F-186B3BBA968C'

--select * from ToolInformation
--where ItemId = 'E2A10444-7755-4C2D-B72F-186B3BBA968C'

select * from ToolPurchaseCostInfo
where ItemId = 'E2A10444-7755-4C2D-B72F-186B3BBA968C'


----

select * from Items
where ItemId = 'E2A10444-7755-4C2D-B72F-186B3BBA968C'

select * from Inventories
where ItemId = 'E2A10444-7755-4C2D-B72F-186B3BBA968C'

select * from StockView
where itemid = 'E2A10444-7755-4C2D-B72F-186B3BBA968C'

select * 
from TransferHeaders toh
join TransferLines tol (NOLOCK) on toh.TransferHeaderId = tol.TransferHeaderId
	LEFT JOIN Entities fromLoc (NOLOCK) ON fromLoc.EntityId = toh.TransferredFromEntityId
	LEFT JOIN Entities toLoc (NOLOCK) ON toLoc.EntityId = toh.TransferredToEntityId
		WHERE YEAR(toh.CreatedOn) IN('2019','2020') -- tax range
		ORDER BY toh.CreatedOn DESC
