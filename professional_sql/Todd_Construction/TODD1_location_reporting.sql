/*
	TODD CONSTRUCTION TOOL LOCATION REPORTING 
		Cole Dixon :: Copyright 2020
*/
-- PURPOSE: tracking tool locations for tax reporting / auditing


SELECT  toh.TransferHeaderId, YEAR(toh.CreatedOn) as Year, CAST(toh.CreatedOn as DATE) as TOLineDate, -- TO header info
	fromLoc.description as FromLocation, COALESCE(fromLoc.City,'') as City, COALESCE(fromLoc.Country,'') as County, toh.TransferredFromEntityId,-- from location
	toLoc.Description as ToLocation, COALESCE(toLoc.City,'') as City, COALESCE(toLoc.Country,'') as County, toh.TransferredToEntityId, -- to location
	tol.ItemId, COALESCE(tool.ItemNumber, i.Number) as ItemNumber, COALESCE(tool.Category, c.Description) as Catergory, COALESCE(tool.Model, m.ManufacturerModel) as Model, COALESCE(tool.Serialnumber,'') as SerialNumber, COALESCE(tool.BarCode,'') as BarCode, COALESCE(tool.ItemType, m.Type) as ItemType, tool.Cost as PurchaseCost, tool.ItemCreatedOn as Purchasedate, -- item info
	tol.Qty, tol.TransferLineId, toh.CreatedOn -- TO line info
FROM TransferHeaders toh
	JOIN TransferLines tol (NOLOCK) ON toh.TransferHeaderId = tol.TransferHeaderId
	LEFT JOIN Entities fromLoc (NOLOCK) ON fromLoc.EntityId = toh.TransferredFromEntityId
	LEFT JOIN Entities toLoc (NOLOCK) ON toLoc.EntityId = toh.TransferredToEntityId
	JOIN Items i (NOLOCK) ON i.ItemId = tol.ItemId
	JOIN Models m (NOLOCK) ON i.ModelId = m.ModelId
	JOIN Categories c (NOLOCK) ON m.CategoryId = c.CategoryId
	LEFT JOIN ToolBrowser tool (NOLOCK) ON tool.ItemId = tol.ItemId
WHERE YEAR(toh.CreatedOn) IN('2019','2020') -- tax range
	UNION
SELECT  toh.TransferHeaderId, YEAR(toh.CreatedOn) as Year, CAST(toh.CreatedOn as DATE) as TOLineDate, -- TO header info
	fromLoc.description as FromLocation, COALESCE(fromLoc.City,'') as City, COALESCE(fromLoc.Country,'') as County, toh.TransferredFromEntityId,-- from location
	toLoc.Description as ToLocation, COALESCE(toLoc.City,'') as City, COALESCE(toLoc.Country,'') as County, toh.TransferredToEntityId, -- to location
	tol.ItemId, COALESCE(tool.ItemNumber, i.Number) as ItemNumber, COALESCE(tool.Category, c.Description) as Catergory, COALESCE(tool.Model, m.ManufacturerModel) as Model, COALESCE(tool.Serialnumber,'') as SerialNumber, COALESCE(tool.BarCode,'') as BarCode, COALESCE(tool.ItemType, m.Type) as ItemType, tool.Cost as PurchaseCost, tool.ItemCreatedOn as Purchasedate, -- item info
	tol.Qty, tol.TransferLineId, toh.CreatedOn -- TO line info
FROM TransferHeaders toh
	JOIN TransferLines tol (NOLOCK) ON toh.TransferHeaderId = tol.TransferHeaderId
	LEFT JOIN Entities fromLoc (NOLOCK) ON fromLoc.EntityId = toh.TransferredFromEntityId
	LEFT JOIN Entities toLoc (NOLOCK) ON toLoc.EntityId = toh.TransferredToEntityId
	JOIN Items i (NOLOCK) ON i.ItemId = tol.ItemId
	JOIN Models m (NOLOCK) ON i.ModelId = m.ModelId
	JOIN Categories c (NOLOCK) ON m.CategoryId = c.CategoryId
	LEFT JOIN ToolBrowser tool (NOLOCK) ON tool.ItemId = tol.ItemId
WHERE YEAR(toh.CreatedOn) IN('2019','2020') -- tax range
ORDER BY toh.CreatedOn DESC

