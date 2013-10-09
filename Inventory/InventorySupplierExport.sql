/*

 +-------------------------------+
 | MOM Inventory Supplier Export | MOM v6.2 -> CB 13.2
 +-------------------------------+---------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	(
		SELECT
			i.ItemCode
		FROM
			[CBERP\CBERPSQL].acdd.dbo.InventoryItem i
		WHERE
			i.ItemName = rtrim(ltrim(s.NUMBER))
	) AS 'ItemCode',
	
	(
		SELECT
			c.SupplierCode
		FROM
			[CBERP\CBERPSQL].acdd.dbo.Supplier c
		WHERE
			c.SupplierLegacyCode = rtrim(ltrim(s.SUPPLIER))
	) AS 'SupplierCode',
	
	'MAIN' AS 'WarehouseCode',
	'EACH' AS 'UnitMeasureCode',
	'USD' AS 'CurrencyCode',
	
	/* Will be populated by later query */
	NULL AS 'ShipFromCode',
	
	(
		SELECT
			c.SupplierName
		FROM
			[CBERP\CBERPSQL].acdd.dbo.Supplier c
		WHERE
			c.SupplierLegacyCode = rtrim(ltrim(s.SUPPLIER))
	) AS 'ShipFromName',
	
	'' AS 'PartCode',
	NULL AS 'ManufacturerID',
	NULL AS 'ShortDescription',
	NULL AS 'ExtendedDescription',
	s.LEAD_COUNT AS 'LeadTime',
	s.UNIT_PRICE AS 'DefaultCost',
	s.UNIT_PRICE AS 'CurrencyCost',
	NULL AS 'PricingMethod',
	NULL AS 'DiscountPercent',
	NULL AS 'DiscountBefore',
	NULL AS 'DiscountAfter',
	s.NLEVEL AS 'Priority',
	CASE WHEN s.NLEVEL=1 THEN 1 ELSE 0 END AS 'DefaultSupplier',
	s.UNIT_PRICE AS 'LastCost',
	s.QUANTITY AS 'MinLevel',
	NULL AS 'MaxLevel',
	NULL AS 'PurchaseTaxCode',
	NULL AS 'PurchaseReorderLevel',
	NULL AS 'PurchaseTaxOption',
	NULL AS 'LastCostDate',
	NULL AS 'UsualQtyOrder',
	NULL AS 'DefaultReaderQty',
	s.DROPSHIP AS 'IsDropShip',
	NULL AS 'IsProvideShippingLabel',
	NULL AS 'QtyInStock',
	'United States of America' AS 'ShipFromCountry',
	NULL AS 'ShipFromAddress',
	NULL AS 'ShipFromCity',
	1 AS 'IsDefaultSupplierShipFrom',
	NULL AS 'ShipFromState',
	NULL AS 'ShipFromPostalCode',
	NULL AS 'ShipFromCounty',
	0 AS 'PerItemFee',
	0 AS 'PerOrderFee',
	0 AS 'CBNItemVersion',
	NULL AS 'IsTemp',
	0 AS 'PerItemFeeRate',
	NULL AS 'ShipFromPlus4'
FROM [MailOrderManager].[dbo].[BUYPRICE] s