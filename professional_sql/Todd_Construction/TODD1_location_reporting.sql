/*
	TODD CONSTRUCTION TOOL LOCATION REPORTING 
		Cole Dixon :: Copyright 2020
*/
-- PURPOSE: tracking tool locations for tax reporting / auditing
-- NOTES: add JOIN ToolBrowser to get PurchaseDate / PurchaseCost (or find relevent VIEW)

-- ToolBrowser / ToolCost... / ToolInformation ???


SELECT  toh.TransferHeaderId, YEAR(toh.CreatedOn) as Year, CAST(toh.CreatedOn as DATE) as TOLineDate, -- TO header info
	fromLoc.description as FromLocation, COALESCE(fromLoc.City,'') as City, COALESCE(fromLoc.Country,'') as County, toh.TransferredFromEntityId,-- from
	toLoc.Description as ToLocation, COALESCE(toLoc.City,'') as City, COALESCE(toLoc.Country,'') as County, toh.TransferredToEntityId, -- to
	tol.ItemId, i.number, c.Description as CategoryDesc, d.Description as ModelDesc, COALESCE(i.Serialnumber,'') as SerialNumber, COALESCE(i.BarCode,'') as BarCode, m.Type, --inv.PurchaseCost, inv.PurchaseDate,  -- item info
	tol.Qty, tol.TransferLineId -- TO line info
FROM TransferHeaders toh
	JOIN TransferLines tol (NOLOCK) ON toh.TransferHeaderId = tol.TransferHeaderId
	LEFT JOIN Entities fromLoc (NOLOCK) ON fromLoc.EntityId = toh.TransferredFromEntityId
	LEFT JOIN Entities toLoc (NOLOCK) ON toLoc.EntityId = toh.TransferredToEntityId
	JOIN Items i (NOLOCK) ON i.ItemId = tol.ItemId
	JOIN Models m (NOLOCK) ON m.ModelId = i.ModelId
	JOIN Categories c (NOLOCK) ON c.CategoryId = m.CategoryId
	JOIN Descriptions d (NOLOCK) ON d.DescriptionId = m.DescriptionId 
		WHERE YEAR(toh.CreatedOn) IN('2019','2020') -- tax range
		ORDER BY toh.CreatedOn DESC