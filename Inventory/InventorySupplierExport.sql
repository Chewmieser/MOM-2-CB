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
			i.ItemName = rtrim(ltrim(c.NUMBER))
	) AS 'ItemCode',
	
	(
		SELECT
			s.SupplierCode
		FROM
			[CBERP\CBERPSQL].acdd.dbo.Supplier s
		WHERE
			s.SupplierLegacyCode = rtrim(ltrim(c.SUPPLIER))
	) AS 'SupplierCode',
	
	'MAIN' AS 'WarehouseCode',
	'EACH' AS 'UnitMeasureCode',
	CurrencyCode
	ShipFromCode
	ShipFromName
	PartCode
	ManufacturerID
	ShortDescription
	ExtendedDescription
	LeadTime
	DefaultCost
	CurrencyCost
	PricingMethod
	DiscountPercent
	DiscountBefore
	DiscountAfter
	Priority
	DefaultSupplier
	LastCost
	MinLevel
	MaxLevel
	PurchaseTaxCode
	PurchaseReorderLevel
	PurchaseTaxOption
	LastCostDate
	UsualQtyOrder
	DefaultReaderQty
	IsDropShip
	IsProvideShippingLabel
	QtyInStock
	ShipFromCountry
	ShipFromAddress
	ShipFromCity
	IsDefaultSupplierShipFrom
	ShipFromState
	ShipFromPostalCode
	ShipFromCounty
	PerItemFee
	PerOrderFee
	CBNItemVersion
	IsTemp
	PerItemFeeRate
	ShipFromPlus4