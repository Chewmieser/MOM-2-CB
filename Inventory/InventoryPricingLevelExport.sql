/*

 +-------------------------------+
 | MOM Item Pricing Level Export | MOM v6.2 -> CB 13.2
 +-------------------------------+---------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	(
		SELECT
			i.ItemCode
		FROM
			acdd.dbo.InventoryItem i
		WHERE
			i.ItemName = rtrim(ltrim(s.NUMBER))
	) AS 'ItemCode',
	
	('[' + CAST(CAST(s.QTY AS INT) AS VARCHAR) + '] ' + ltrim(rtrim(s.NUMBER))) AS 'PricingLevel',
	s.NPOSITION AS 'LineNum',
	'EACH' AS 'UnitMeasureCode',
	'USD' AS 'CurrencyCode',
	NULL AS 'Description',
	s.QTY AS 'MinQuantity',
	'99999999.000000' AS 'MaxQuantity',
	'None' AS 'PricingMethod',
	0.00 AS 'Discount',
	s.DISCOUNT AS 'AmountPercent',
	
	(
		SELECT
			i.UNCOST
		FROM
			[MailOrderManager].[dbo].[STOCK] i
		WHERE
			i.NUMBER = s.NUMBER
	) AS 'CostPrice',
	
	s.PRICE AS 'UnitPrice',
	s.PRICE AS 'SalesPrice',
	NULL AS 'MaxDiscount'
FROM
	[MailOrderManager].[dbo].[PRICE] s