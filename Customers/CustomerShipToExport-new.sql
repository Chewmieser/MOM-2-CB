/*

 +--------------------+
 | MOM Ship-To Export | MOM v6.2 -> CB 13.2
 +--------------------+--------------------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	(
		SELECT
			z.CustomerCode
		FROM
			acdd.dbo.Customer z
		WHERE
			z.CustomerLegacyCode = x.CUSTNUM
	) AS 'CustomerCode',

	NULL AS 'ShipToCode',
	'Sales No Tax' AS 'TaxCode',
	'Sales No Tax' AS 'OtherTax',
	'Sales No Tax' AS 'FreightTax',
	'User Entered' AS 'ShippingMethod',
	'DEFAULT' AS 'ShippingMethodGroup',
	'MAIN' AS 'WarehouseCode',
	NULL AS 'ContactCode',
	NULL AS 'OpenTime',
	NULL AS 'CloseTime',
	NULL AS 'SpecialInstructions',
	NULL AS 'TruckSize',
	NULL AS 'IsBookTimeDateAndBay',
	NULL AS 'RouteCode',
	NULL AS 'PaymentTermGroup',
	NULL AS 'PaymentTermCode',
	
	CASE WHEN ltrim(rtrim(c.FIRSTNAME)) LIKE ''
		THEN master.dbo.udf_TitleCase(ltrim(rtrim(c.COMPANY)))
		ELSE (master.dbo.udf_TitleCase(LTRIM(RTRIM(c.FIRSTNAME))) + ' ' + master.dbo.udf_TitleCase(LTRIM(RTRIM(c.LASTNAME))))
		END AS 'ShipToName',
	
	/* Convert country codes into country names */
	CASE c.COUNTRY
		WHEN 001 THEN 'United States of America'
		ELSE NULL
		END AS 'Country',
	
	'Default' AS 'ClassCode',
	'USD' AS 'CurrencyCode',
	'Default' AS 'GLClassCode',
	'None' AS 'PricingMethod',
	x.SHIPNUM AS 'ShipToLegacyCode',

	/* Combine address lines */
	CASE WHEN s.DeliveryLine1 IS NULL /* Fallback to MOM data */
		THEN CASE WHEN c.ADDR2 LIKE ''
			THEN CASE WHEN ltrim(rtrim(c.ADDR)) LIKE ''
				THEN NULL
				ELSE ltrim(rtrim(c.ADDR))
				END
			ELSE ltrim(rtrim(c.ADDR)) + CHAR(13) + CHAR(10) + ltrim(rtrim(c.ADDR2))
			END
		ELSE CASE WHEN s.DeliveryLine2 IS NULL
			THEN CASE WHEN s.DeliveryLine1 IS NULL
				THEN NULL
				ELSE s.DeliveryLine1
				END
			ELSE CONVERT(varchar(100), s.DeliveryLine1) + CHAR(13) + CHAR(10) + CONVERT(varchar(100), s.DeliveryLine2)
			END
		END AS 'Address',
	
	s.CITY AS 'City',
	s.STATE AS 'State',
	s.ZIPCode AS 'PostalCode',
	s.CountyName AS 'County',

	/* Trim and nullify */
	CASE WHEN ltrim(rtrim(c.PHONE)) LIKE '-   -' OR ltrim(rtrim(c.PHONE)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.PHONE))
		END AS 'Telephone',

	NULL AS 'TelephoneExtension',

	/* Trim and nullify */
	CASE WHEN ltrim(rtrim(c.PHONE2)) LIKE '-   -' OR ltrim(rtrim(c.PHONE2)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.PHONE2))
		END AS 'Fax',
	
	NULL AS 'FaxExtension',

	/* Trim and nullify */
	CASE WHEN ltrim(rtrim(c.EMAIL)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.EMAIL))
		END AS 'Email',

	/* Trim and nullify */
	CASE WHEN ltrim(rtrim(c.WEB)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.WEB))
		END AS 'Website',

	/* Combine comment lines - Warn for fraud */
	CASE WHEN c.COMMENT2 LIKE ''
		THEN CASE WHEN c.BADCHECK = 1
			THEN '[FRAUD]' + CHAR(13) + CHAR(10) + ltrim(rtrim(c.COMMENT))
			ELSE ltrim(rtrim(c.COMMENT))
			END
		ELSE CASE WHEN c.BADCHECK = 1
			THEN '[FRAUD]' + CHAR(13) + CHAR(10) + ltrim(rtrim(c.COMMENT)) + CHAR(13) + CHAR(10) + ltrim(rtrim(c.COMMENT2))
			ELSE ltrim(rtrim(c.COMMENT)) + CHAR(13) + CHAR(10) + ltrim(rtrim(c.COMMENT2))
			END
		END AS 'Notes',
	
	0.00 AS 'CreditLimit',
	0.00 AS 'PricingPercent',
	~c.BADCHECK AS 'IsActive',
	c.BADCHECK AS 'IsCreditHold',

	1 AS 'IsAllowBackOrder',
	NULL AS 'PricingLevel',

	/* Convert usernames into sales rep IDs */
	CASE c.SALES_ID /* May Change */
		WHEN 'TZ' THEN 'REP-000001'
		WHEN 'GD' THEN 'REP-000002'
		WHEN 'CH' THEN 'REP-000003'
		ELSE NULL
		END AS 'SalesRepGroupCode',
	
	'Sales Rep' AS 'Commission',
	0.00 AS 'CommissionPercent',
	NULL AS 'TaxNumber',
	NULL AS 'BusinessLicense',
	NULL AS 'AddressType',
	s.AddonCode AS 'Plus4'
FROM
	(
		SELECT DISTINCT
			CASE WHEN ((z.SHIPNUM = 0) OR (z.SHIPNUM IS NULL))
				THEN z.CUSTNUM
				ELSE z.SHIPNUM
				END AS SHIPNUM,
			z.CUSTNUM
		FROM
			MailOrderManager.dbo.CMS z
	) x
JOIN MailOrderManager.dbo.CUST c ON x.SHIPNUM = c.CUSTNUM /* Primary MOM DB */
JOIN momscripts.dbo.MomCustSanitized s ON c.CUSTNUM = s.CustomerID /* Sanitized data for addresses */
WHERE
	(
		SELECT
			z.CustomerCode
		FROM
			acdd.dbo.Customer z
		WHERE
			z.CustomerLegacyCode = CAST(x.CUSTNUM AS VARCHAR(50))
	) IS NOT NULL
	
	AND

	/* Hasn't been imported */
	(
		SELECT
			COUNT(z.ShipToLegacyCode)
		FROM
			acdd.dbo.CustomerShipTo z
		WHERE
			z.ShipToLegacyCode = CAST(x.SHIPNUM AS VARCHAR(50))
	) = 0
ORDER BY c.CUSTNUM ASC