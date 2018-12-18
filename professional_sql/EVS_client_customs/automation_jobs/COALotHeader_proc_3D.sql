
--COA Lot Cursor for 3D
--Created by: Cole Dixon
--03/01/2016
ALTER procedure [dbo].[sp_EVS_3D_COA_Lots]
	@intShipkey	int
as

DECLARE @LotNo VARCHAR(10)
DECLARE @Lots VARCHAR(200) --THIS CAN BE ADJUSTED IF NEEDED
DECLARE @ShipKey int

SET @ShipKey = @intshipkey -- SET SHIPKEY
SET @Lots = ''

IF OBJECT_ID('tempdb..#shiplots') > 0 DROP TABLE #shiplots
CREATE TABLE #shiplots (ShipKey int, Lots VARCHAR(250))

DECLARE _LotNo CURSOR FOR
SELECT COALESCE(LotNo,'N/A') 
	FROM vdv_o2_COA_Lotsbyshipment
	WHERE ShipKey = @ShipKey 


OPEN _LotNo

	FETCH NEXT FROM _LotNo
	INTO @LotNo
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		BEGIN
			SET @Lots = @Lots + LTRIM(RTRIM(@LotNo)) + ',  '
			
		END
		
		FETCH NEXT FROM _LotNo
		INTO @LotNo
	END
	
	SET @Lots = case when @lots = ' ' then ' ' else SUBSTRING(@Lots, 1, Len(@Lots) - 1) end
	INSERT INTO #shiplots VALUES(@ShipKey, @Lots)
	
		
CLOSE _LotNo
DEALLOCATE _LotNo

  SELECT vdv_o2_COA_SO_3D.NumericFinalResult
  , tarCustomer.CustName, voaShipmentAll.ShipKey
  , voaShipmentAll.CustPONo
  , voaShipmentAll.SO
  , vO2Item.ItemID
  , vO2Item.ShortDesc
  , vdv_o2_COA_SO_3D.TranNoRel
  , vdv_o2_COA_SO_3D.Seq
  , vdv_o2_COA_SO_3D.CompleteUserId
  , voaShipmentAll.CompanyID
  , vdv_o2_COA_SO_3D.itemid
  , vdv_o2_COA_CustSpecs.TestDesc
  , timCustItem.CustItemNo, vO2Item.ItemKey
  , vdv_o2_COA_CustSpecs.numericlow
  , vdv_o2_COA_CustSpecs.lowop
  , vdv_o2_COA_CustSpecs.highop
  , vdv_o2_COA_CustSpecs.NumericHigh
  , vO2Item.ItemClassKey
  , #shiplots.lots
 FROM   
 (((((mas500_app.dbo.vdv_o2_COA_SO_Frozen_3D vdv_o2_COA_SO_3D 
 INNER JOIN mas500_app.dbo.tarCustomer tarCustomer ON (vdv_o2_COA_SO_3D.CompanyID=tarCustomer.CompanyID) AND (vdv_o2_COA_SO_3D.custkey=tarCustomer.CustKey)) 
 INNER JOIN mas500_app.dbo.voaShipmentAll voaShipmentAll ON (vdv_o2_COA_SO_3D.CompanyID=voaShipmentAll.CompanyID) AND (vdv_o2_COA_SO_3D.ShipKey=voaShipmentAll.ShipKey)) 
 INNER JOIN mas500_app.dbo.vO2Item vO2Item ON (vdv_o2_COA_SO_3D.CompanyID=vO2Item.CompanyID) AND (vdv_o2_COA_SO_3D.itemkey=vO2Item.ItemKey)) 
 INNER JOIN mas500_app.dbo.vdv_o2_COA_CustSpecs vdv_o2_COA_CustSpecs ON (((vdv_o2_COA_SO_3D.custid=vdv_o2_COA_CustSpecs.custid) AND (vdv_o2_COA_SO_3D.CompanyID=vdv_o2_COA_CustSpecs.CompanyID)) AND (vdv_o2_COA_SO_3D.itemid=vdv_o2_COA_CustSpecs.itemid)) AND (vdv_o2_COA_SO_3D.QCTestKey=vdv_o2_COA_CustSpecs.QCtestKey)) 
 INNER JOIN #shiplots on #shiplots.shipkey = vdv_o2_COA_SO_3D.ShipKey
 LEFT OUTER JOIN mas500_app.dbo.vdv_o2_COA_Lots vdv_o2_COA_Lots ON (vdv_o2_COA_SO_3D.ownerkey=vdv_o2_COA_Lots.ownerkey) AND (vdv_o2_COA_SO_3D.itemkey=vdv_o2_COA_Lots.itemkey)) LEFT OUTER JOIN mas500_app.dbo.timCustItem timCustItem ON (vdv_o2_COA_SO_3D.custkey=timCustItem.CustKey) AND (vdv_o2_COA_SO_3D.itemkey=timCustItem.ItemKey)
 WHERE  voaShipmentAll.ShipKey=@intshipkey AND voaShipmentAll.CompanyID='pro' AND vO2Item.ItemClassKey=268
 ORDER BY vdv_o2_COA_SO_3D.TranNoRel, vdv_o2_COA_SO_3D.Seq







