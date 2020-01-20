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

select * from Entities
where EntityId = '3EB1129F-7D69-4DA2-B4D4-E0C1AB2ADFD2'

select * from entities
where EntityId = '4626E8FF-F608-4C60-92CE-AEE99DB76983'