/*

 +-------------------------+
 | MOM Item Pricing Export | MOM v6.2 -> CB 13.2
 +-------------------------+---------------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	'USD' AS 'CurrencyCode',
	
	(
		SELECT
			i.ItemCode
		FROM
			acdd.dbo.InventoryItem i
		WHERE
			i.ItemName = rtrim(ltrim(s.NUMBER))
	) AS 'ItemCode',
	
	'None' AS 'PricingMethod',
	s.UNCOST AS 'StandardCost',
	s.UNCOST AS 'PricingCost',
	s.PRICE1 AS 'WholesalePrice',
	s.PRICE1 AS 'RetailPrice',
	0.00 AS 'SuggestedRetailPrice',
	0.00 AS 'WholeSalePercentAmount',
	0.00 AS 'RetailPercentAmount',
	0.00 AS 'WholesalesMaxDiscount',
	0.00 AS 'RetailMaxDiscount'
FROM
	[MailOrderManager].[dbo].[STOCK] s