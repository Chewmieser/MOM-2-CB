/*

 +-------------------------------+
 | MOM Inventory Supplier Export | MOM v6.2 -> CB 13.2
 +-------------------------------+---------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */
ITEM-001970, SUP-000024, MAIN, SFRM-000024
SELECT
	ltrim(rtrim((
		SELECT
			i.ItemCode
		FROM
			acdd.dbo.InventoryItem i
		WHERE
			i.ItemName = rtrim(ltrim(s.NUMBER))
	))) AS 'ItemCode',
	
	ltrim(rtrim((
		SELECT
			c.SupplierCode
		FROM
			acdd.dbo.Supplier c
		WHERE
			c.SupplierLegacyCode = rtrim(ltrim(s.SUPPLIER))+(CASE WHEN s.DROPSHIP = 1 THEN '-DS' ELSE '' END)
	))) AS 'SupplierCode',
	
	'MAIN' AS 'WarehouseCode',
	'EACH' AS 'UnitMeasureCode',
	'USD' AS 'CurrencyCode',
	
	ltrim(rtrim((
		SELECT
			x.ShipFromCode
		FROM
			acdd.dbo.SupplierShipFrom x
		WHERE
			x.SupplierCode = (
				SELECT
					c.SupplierCode
				FROM
					acdd.dbo.Supplier c
				WHERE
					c.SupplierLegacyCode = rtrim(ltrim(s.SUPPLIER))+(CASE WHEN s.DROPSHIP = 1 THEN '-DS' ELSE '' END)
			)
	))) AS 'ShipFromCode',
	
	ltrim(rtrim((
		SELECT
			c.SupplierName
		FROM
			acdd.dbo.Supplier c
		WHERE
			c.SupplierLegacyCode = rtrim(ltrim(s.SUPPLIER))+(CASE WHEN s.DROPSHIP = 1 THEN '-DS' ELSE '' END)
	))) AS 'ShipFromName',
	
	s.BUYDESC AS 'PartCode',
	NULL AS 'ManufacturerID',
	s.BUYDESC + CHAR(13) + CHAR(10) + s.BUYDESC2 AS 'ShortDescription',
	s.INSTRUCT1 + CHAR(13) + CHAR(10) + s.INSTRUCT2 + CHAR(13) + CHAR(10) + s.INSTRUCT3 AS 'ExtendedDescription',
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
FROM
	[MailOrderManager].[dbo].[BUYPRICE] s