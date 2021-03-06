/*

 +---------------------+
 | MOM Customer Export | MOM v6.2 -> CB 13.2
 +---------------------+-------------------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	NULL AS 'CustomerCode',
	
	/* Generate company name based on full name if needed - trim and Title Case */
	CASE WHEN c.COMPANY LIKE ''
		THEN (master.dbo.udf_TitleCase(LTRIM(RTRIM(c.FIRSTNAME))) + ' ' + master.dbo.udf_TitleCase(LTRIM(RTRIM(c.LASTNAME))))
		ELSE master.dbo.udf_TitleCase(c.COMPANY)
		END AS 'CustomerName',
		
	/* Convert country codes into country names */
	CASE c.COUNTRY
		WHEN 001 THEN 'United States of America'
		ELSE NULL
		END AS 'Country',
		
	'Default' AS 'ClassCode',
	'USD' AS 'CurrencyCode',
	'Default' AS 'GLClassCode',
	'None' AS 'PricingMethod',
	NULL AS 'DefaultPrice',
	NULL AS 'DefaultShipToCode',
	c.CUSTNUM AS 'CustomerLegacyCode',
	
	/* Trim, Title Case and nullify */
	CASE WHEN ltrim(rtrim(c.FIRSTNAME)) LIKE ''
		THEN NULL
		ELSE master.dbo.udf_TitleCase(ltrim(rtrim(c.FIRSTNAME)))
		END AS 'FirstName',
	
	0 AS 'Newsletter_DEV000972',
	
	/* Trim, Title Case and nullify */
	CASE WHEN ltrim(rtrim(c.LASTNAME)) LIKE ''
		THEN NULL
		ELSE master.dbo.udf_TitleCase(ltrim(rtrim(c.LASTNAME)))
		END AS 'LastName',
	
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
		
	'Unknown' AS 'SourceCode',
	NULL AS 'DefaultContact',
	NULL AS 'DefaultAPContact',
	NULL AS 'DefaultContractCode',
	0.00 AS 'Discount',
	NULL AS 'DiscountBand',
	NULL AS 'CreditCardCode',
	NULL AS 'WebUserName',
	NULL AS 'WebPassword',
	NULL AS 'Pricing',
	
	c.CREDIT_LIM AS 'CreditLimit',
	c.AR_BALANCE AS 'CustomerBalance',
	
	0.00 AS 'PricingPercent',
	~c.BADCHECK AS 'IsActive',
	c.BADCHECK AS 'IsCreditHold',
	
	CASE c.CUSTTYPE
		WHEN 'P' THEN 1
		ELSE 0
		END AS 'IsProspect',
	
	1 AS 'IsAllowBackOrder',
	0 AS 'IsWebAccess',
	NULL AS 'PricingLevel',
	
	/* Convert usernames into sales rep IDs */
	CASE c.SALES_ID /* May Change */
		WHEN 'TZ' THEN 'REP-000001'
		WHEN 'GD' THEN 'REP-000002'
		WHEN 'CH' THEN 'REP-000003'
		ELSE NULL
		END AS 'SalesRepGroupCode',
		
	'Sales Rep' AS 'Commission',
	NULL AS 'IsPrinted',
	0.00 AS 'CommissionPercent',
	NULL AS 'TaxNumber',
	NULL AS 'BusinessLicense',
	NULL AS 'RecallDate',
	NULL AS 'DebtChaser',
	NULL AS 'SendPreference',
	NULL AS 'DebtChaseStatus',
	NULL AS 'IsDocumentStop',
	NULL AS 'HeadOffice',
	0.00 AS 'Rank',
	NULL AS 'IsRTShipping',
	NULL AS 'RTShipRequest',
	NULL AS 'RTShipResponse',
	NULL AS 'LastStatementSentDate',
	NULL AS 'LastStatementSentBy',
	NULL AS 'CustomerGUID',
	NULL AS 'LastLetterSentDate',
	0.00 AS 'CreditRating',
	NULL AS 'LastIPAddress',
	NULL AS 'LastLetterSentBy',
	NULL AS 'CustomerSessionID',
	NULL AS 'LastCreditReview',
	NULL AS 'LastLetterSentType',
	NULL AS 'ProductFilterID',
	NULL AS 'CouponCode',
	NULL AS 'NextCreditReview',
	0 AS 'Over13Checked',
	NULL AS 'CustomerTypeCode',
	NULL AS 'DefaultBillingAddress',
	NULL AS 'SubscriptionExpiresOn',
	
	/* Convert company type */
	CASE c.CTYPE2 /* May Change */
		WHEN 'CH' THEN 'Church and Ministry'
		WHEN 'ED' THEN 'Education'
		WHEN 'EN' THEN 'Entertainment'
		WHEN 'FN' THEN 'Financial'
		WHEN 'GN' THEN 'General'
		WHEN 'GO' THEN 'Government'
		WHEN 'HE' THEN 'Health and Medical'
		WHEN 'IN' THEN 'Insurance'
		WHEN 'LG' THEN 'Legal'
		WHEN 'RE' THEN 'Real Estate'
		WHEN 'SP' THEN 'Sports'
		ELSE NULL
		END AS 'BusinessType',
	
	c.CUSTBAL AS 'Credit',
	
	NULL AS 'GiftRegistryGUID',
	NULL AS 'CustomerBalanceRate',
	0 AS 'IsFromProspect',
	NULL AS 'MaxDiscount',
	NULL AS 'IsCBN',
	NULL AS 'CBNNetworkID',
	NULL AS 'MiddleName',
	NULL AS 'CBNAccountStatusId',
	NULL AS 'AddressType',
	NULL AS 'PrintCount',
	NULL AS 'IsBlindShip',
	NULL AS 'LastRankCalculated',
	0 AS 'IsRankUserOverriden',
	0 AS 'ShowOnStoreLocator',
	
	/*  Convert usernames */
	CASE c.SALES_ID /* May Change */
		WHEN 'TZ' THEN 'tzwart'
		WHEN 'CH' THEN 'chall'
		WHEN 'GD' THEN 'gdownie'
		ELSE NULL
		END AS 'AssignedTo',
		
	s.AddonCode AS 'Plus4',
	NULL AS 'TeamCode',
	NULL AS 'TerritoryCode',
	NULL AS 'VersionCreated',
	NULL AS 'TotalCredits',
	NULL AS 'VersionModified',
	
	/* Residential code into text where applicable */
	CASE c.CTYPE
		WHEN 'C' THEN 'Residential'
		ELSE NULL
		END AS 'ResidenceType',
		
	NULL AS 'DiscountType',
	NULL AS 'AssociatedCompany_C',
	NULL AS 'ImportCustomerID_DEV000221',
	NULL AS 'ProductFilterTemplateNamePricingImport',
	NULL AS 'ImportSourceID_DEV000221',
	NULL AS 'ImportSourceBuyerID_DEV000221'
FROM
	(
		SELECT DISTINCT
			CUSTNUM
		FROM
			MailOrderManager.dbo.CMS
	) x
JOIN MailOrderManager.dbo.CUST c ON x.CUSTNUM = c.CUSTNUM /* Primary MOM DB */
JOIN momscripts.dbo.MomCustSanitized s ON c.CUSTNUM = s.CustomerID /* Sanitized data for addresses */
WHERE

	/* Hasn't been imported */
	(
		SELECT
			COUNT(z.CustomerLegacyCode)
		FROM
			acdd.dbo.Customer z
		WHERE
			z.CustomerLegacyCode = c.CUSTNUM
	) = 0
ORDER BY c.CUSTNUM ASC