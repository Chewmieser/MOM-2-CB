/*

 +-------------------------------------+
 | MOM Customer Sales Quotation Detail | MOM v6.2 -> CB 13.2
 +-------------------------------------+---------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	(
		SELECT
			x.SalesOrderCode
		FROM
			acdd.dbo.CustomerSalesOrder x
		WHERE
			x.SourceSalesOrderCode = i.ORDERNO
	) AS 'SalesOrderCode',

	(
		SELECT
			x.ItemCode
		FROM
			acdd.dbo.InventoryItem x
		WHERE
			x.ItemName = ltrim(rtrim(i.ITEM))
	) AS 'ItemCode',
	
	i.SEQ AS 'LineNum',
	'MAIN' AS 'WarehouseCode',
	i.QUANTO AS 'QuantityOrdered',
	'EACH' AS 'UnitMeasureCode',
SalesAccountCode
	i.ORDERNO AS 'SourceSalesOrderCode',
	i.SEQ AS 'SourceLineNum',

	(
		SELECT
			x.SalesOrderCode
		FROM
			acdd.dbo.CustomerSalesOrder x
		WHERE
			x.SourceSalesOrderCode = CAST(i.ORDERNO AS VARCHAR)
	) AS 'RootDocumentCode',

	NULL AS 'SourceDocumentType',
	i.QUANTB AS 'QuantityBackOrdered',
	i.QUANTS AS 'QuantityShipped',
	i.QUANTP AS 'QuantityToBeShipped',
	i.QUANTF AS 'QuantityAllocated',
	0.00 AS 'QuantityAlReadyRMA', /* Needs testing */
	
	(
		SELECT
			CASE WHEN SUM(x.QUANTITY) IS NULL
				THEN 0
				ELSE SUM(x.QUANTITY)
				END
		FROM
			[MailOrderManager].[dbo].[RMAITEMS] x
		WHERE
			x.ITEM_ID = i.ITEM_ID
		GROUP BY
			i.ITEM_ID
	) AS 'QuantityReturned',
	
	0.00 AS 'ContractQuantity',

	(
		SELECT
			d.ItemDescription
		FROM
			acdd.dbo.InventoryItem x
			JOIN acdd.dbo.InventoryItemDescription d ON x.ItemCode = d.ItemCode
		WHERE
			x.ItemName = ltrim(rtrim(i.ITEM))
	) AS 'ItemDescription',

	0.00 AS 'ContractCalledOff',
	0.00 AS 'Discount',
	0.00 AS 'Markup',
	1.0 AS 'UnitMeasureQty',
	(i.IT_UNLIST * i.QUANTO) * (i.NTAXRATE + i.STAXRATE + i.CTAXRATE + i.ITAXRATE) AS 'SalesTaxAmount',
	(i.IT_UNLIST * i.QUANTO) * (i.NTAXRATE + i.STAXRATE + i.CTAXRATE + i.ITAXRATE) AS 'SalesTaxAmountRate',
	i.IT_UNLIST AS 'SalesPrice',
	i.IT_UNLIST AS 'SalesPriceRate',
	i.IT_UNLIST AS 'NetPrice',
	i.IT_UNLIST AS 'NetPriceRate',
	i.IT_UNLIST * i.QUANTO AS 'ExtPrice',
	i.IT_UNLIST * i.QUANTO AS 'ExtPriceRate',
	NULL AS 'CostingMethod',
	NULL AS 'SupplierCode',
	i.IT_UNCOST AS 'Cost',
	i.IT_UNCOST AS 'CostRate',
	i.IT_UNCOST * i.QUANTO AS 'ExtCost',
	i.IT_UNCOST * i.QUANTO AS 'ExtCostRate',
	i.IT_UNCOST AS 'ActualCost',
	i.IT_UNCOST AS 'ActualCostRate',
	i.IT_UNCOST * i.QUANTO AS 'ExtActualCost',
	i.IT_UNCOST * i.QUANTO AS 'ExtActualCostRate',
	(i.IT_UNLIST - i.IT_UNCOST) * i.QUANTO AS 'Profit',
	(i.IT_UNLIST - i.IT_UNCOST) * i.QUANTO AS 'ProfitRate',
	'Sales No Tax' AS 'TaxCode',
	((i.IT_UNLIST - i.IT_UNCOST) * i.QUANTO) / (i.IT_UNCOST * i.QUANTO) AS 'Margin',
Pricing /* Retail / Wholesale / Price list */
	i.DROPSHIP AS 'IsDropShip',
DropShipReference /* Needs PO conversion */
InventoryAccountCode
	0 AS 'MatrixBatch',
COGSAccountCode
	'Stock' AS 'ItemType',
	0.00 AS 'Volume',
	0.00 AS 'Weight',
	0.00 AS 'NetWeight',
	0.00 AS 'ExtWeight',
	0.00 AS 'ExtNetWeight',

	(
		SELECT
			dateadd(day, x.DUE_DAYS, x.ORD_DATE)
		FROM
			[MailOrderManager].[dbo].[CMS] x
		WHERE
			x.ORDERNO = i.ORDERNO
	) AS 'DueDate',
	
	NULL AS 'RevisedDueDate',
	0 AS 'IsConvert',
	0 AS 'IsConverted',
	i.PICKED AS 'IsPickingNotePrinted',
	i.PACKED AS 'IsPackingListPrinted',
	
	CASE WHEN ([PICKED]=1 AND [PACKED]=1)
		THEN 1
		ELSE 0
		END AS 'IsConfirmedPickedPacked',
		
	1 AS 'Commissionable',
	10 AS 'NOTC', /* Follows convention, but idk what it is */
	'Sales Rep' AS 'CommissionSource',
	'FOB' AS 'TermsOfDelivery',
	'Sales' AS 'CommissionApplyTo',
	0.00 AS 'CommissionPercent',
	0.00 AS 'CommissionAmount',
	0.00 AS 'CommissionAmountRate',
	0 AS 'IsIncludedInCoupon',
	0 AS 'SupUnitsReq',
	NULL AS 'CommodityCode',
	NULL AS 'ParentItemCode',
	NULL AS 'ParentType',
	NULL AS 'GroupCode',
	NULL AS 'CustomerItemCode',
	
	(
		SELECT
			d.ItemDescription
		FROM
			acdd.dbo.InventoryItem x
			JOIN acdd.dbo.InventoryItemDescription d ON x.ItemCode = d.ItemCode
		WHERE
			x.ItemName = ltrim(rtrim(i.ITEM))
	) AS 'InventoryDescription',
	
	1 AS 'IsInventoryDescription',
	NULL AS 'WebSiteCode',
	NULL AS 'ParentBundleItemCode',
	s.SEQ AS 'SortOrder',
	NULL AS 'CouponDiscount',
	NULL AS 'CouponDiscountRate',
	NULL AS 'SerializeLot',
	NULL AS 'QuantityReserved',
	NULL AS 'WeightInPounds',
	NULL AS 'NetWeightInPounds',
	NULL AS 'SourcePurchaseID_DEV000221',
	NULL AS 'SourceTaxCode',
	0.00 AS 'MaxDiscount',
	NULL AS 'ProcessID',
	0 AS 'IsSpecialOrder',
	NULL AS 'IsDiscountAmount',
	NULL AS 'DiscountAmount',
	NULL AS 'DiscountAmountRate',
	NULL AS 'SourceCommissionCharge_DEV000221',
	NULL AS 'SourceCommissionChargeRate_DEV000221',
	NULL AS 'SourceFulfillmentCost_DEV000221',
	NULL AS 'SourceFulfillmentCostRate_DEV000221'
FROM
	[MailOrderManager].[dbo].[ITEMS] i /*JOIN [MailOrderManager].[dbo].[STOCK] s*/
WHERE
	(
		SELECT
			s.QUOTATION
		FROM
			[MailOrderManager].[dbo].[CMS] s
		WHERE
			s.ORDERNO = i.ORDERNO
	) = 1