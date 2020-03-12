/* TODD CONSTRUCTION SANDBOX */

-------
--- Cole Dixon
--- 2020
-------

-----
-- location_reporting query wrk
-----

SELECT  toh.TransferHeaderId, YEAR(toh.CreatedOn) as Year, CAST(toh.CreatedOn as DATE) as TOLineDate, -- TO header info
	fromLoc.description as FromLocation, COALESCE(fromLoc.City,'') as City, COALESCE(fromLoc.Country,'') as County, toh.TransferredFromEntityId,-- from location
	toLoc.Description as ToLocation, COALESCE(toLoc.City,'') as City, COALESCE(toLoc.Country,'') as County, toh.TransferredToEntityId, -- to location
	tol.ItemId, tool.ItemNumber, tool.Category, tool.Model, COALESCE(tool.Serialnumber,'') as SerialNumber, COALESCE(tool.BarCode,'') as BarCode, tool.ItemType,  tool.PurchaseCost, tool.PurchaseDate, -- item info
	tol.Qty, tol.TransferLineId, toh.CreatedOn -- TO line info
FROM TransferHeaders toh
	JOIN TransferLines tol (NOLOCK) ON toh.TransferHeaderId = tol.TransferHeaderId
	LEFT JOIN Entities fromLoc (NOLOCK) ON fromLoc.EntityId = toh.TransferredFromEntityId
	LEFT JOIN Entities toLoc (NOLOCK) ON toLoc.EntityId = toh.TransferredToEntityId
	JOIN Items i (NOLOCK) ON i.ItemId = tol.ItemId
	--JOIN Models m (NOLOCK) ON m.ModelId = i.ModelId
	--JOIN Categories c (NOLOCK) ON c.CategoryId = m.CategoryId
	--JOIN Descriptions d (NOLOCK) ON d.DescriptionId = m.DescriptionId
	LEFT JOIN ToolBrowser tool (NOLOCK) ON tool.ItemId = tol.ItemId
		WHERE YEAR(toh.CreatedOn) IN('2019','2020') -- tax range
			UNION
SELECT  toh.TransferHeaderId, YEAR(toh.CreatedOn) as Year, CAST(toh.CreatedOn as DATE) as TOLineDate, -- TO header info
	fromLoc.description as FromLocation, COALESCE(fromLoc.City,'') as City, COALESCE(fromLoc.Country,'') as County, toh.TransferredFromEntityId,-- from location
	toLoc.Description as ToLocation, COALESCE(toLoc.City,'') as City, COALESCE(toLoc.Country,'') as County, toh.TransferredToEntityId, -- to location
	tol.ItemId, tool.ItemNumber, tool.Category, tool.Model, COALESCE(tool.Serialnumber,'') as SerialNumber, COALESCE(tool.BarCode,'') as BarCode, tool.ItemType,  tool.PurchaseCost, tool.PurchaseDate, -- item info
	tol.Qty, tol.TransferLineId, toh.CreatedOn -- TO line info
FROM TransferHeaders toh
	JOIN TransferLines tol (NOLOCK) ON toh.TransferHeaderId = tol.TransferHeaderId
	LEFT JOIN Entities fromLoc (NOLOCK) ON fromLoc.EntityId = toh.TransferredFromEntityId
	LEFT JOIN Entities toLoc (NOLOCK) ON toLoc.EntityId = toh.TransferredToEntityId
	JOIN Items i (NOLOCK) ON i.ItemId = tol.ItemId
	--JOIN Models m (NOLOCK) ON m.ModelId = i.ModelId
	--JOIN Categories c (NOLOCK) ON c.CategoryId = m.CategoryId
	--JOIN Descriptions d (NOLOCK) ON d.DescriptionId = m.DescriptionId
	LEFT JOIN ToolBrowser tool (NOLOCK) ON tool.ItemId = tol.ItemId
		WHERE YEAR(toh.CreatedOn) IN('2019','2020') -- tax range
		ORDER BY toh.CreatedOn DESC



-----
-- inventory_tracking query wrk
-----

