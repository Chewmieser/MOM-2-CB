/*

 +--------------------+
 | MOM Contact Export | MOM v6.2 -> CB 13.2
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
			c.CUSTNUM = z.CustomerLegacyCode
	) AS 'EntityCode',
	
	CASE WHEN ltrim(rtrim(c.SALU)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.SALU))
		END AS 'ContactSalutationCode',

	CASE WHEN ltrim(rtrim(c.HONO)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.HONO))
		END AS 'ContactSuffixCode',
	
	/*  Convert usernames */
	CASE c.SALES_ID /* May Change */
		WHEN 'TZ' THEN 'tzwart'
		WHEN 'CH' THEN 'chall'
		WHEN 'GD' THEN 'gdownie'
		ELSE NULL
		END AS 'AssignedTo',

	CASE WHEN ltrim(rtrim(c.FIRSTNAME)) LIKE ''
		THEN master.dbo.udf_TitleCase(ltrim(rtrim(c.COMPANY)))
		ELSE master.dbo.udf_TitleCase(LTRIM(RTRIM(c.FIRSTNAME)))
		END AS 'ContactFirstName',

	CASE WHEN ltrim(rtrim(c.LASTNAME)) LIKE ''
		THEN NULL
		ELSE master.dbo.udf_TitleCase(LTRIM(RTRIM(c.LASTNAME)))
		END AS 'ContactLastName',

	/* Convert country codes into country names */
	CASE c.COUNTRY
		WHEN 001 THEN 'United States of America'
		ELSE NULL
		END AS 'Country',
	
	/* Trim and nullify */
	CASE WHEN ltrim(rtrim(c.PHONE)) LIKE '-   -' OR ltrim(rtrim(c.PHONE)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.PHONE))
		END AS 'BusinessPhone',

	/* Trim and nullify */
	CASE WHEN ltrim(rtrim(c.PHONE2)) LIKE '-   -' OR ltrim(rtrim(c.PHONE2)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.PHONE2))
		END AS 'BusinessFax',

	/* Trim and nullify */
	CASE WHEN ltrim(rtrim(c.EMAIL)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(c.EMAIL))
		END AS 'Email1',
		
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
		
	~c.NOCALL AS 'IsOkToCall',
	~c.NOEMAIL AS 'IsOkToEmail',
	~c.NOFAX AS 'IsOkToFax',
	s.CITY AS 'City',
	s.STATE AS 'State',
	s.ZIPCode AS 'PostalCode',
	s.CountyName AS 'County',
	c.CUSTNUM AS 'ContactLegacyCode',
	~c.BADCHECK AS 'IsActive',
	s.AddonCode AS 'Plus4',
	
	'CustomerContact' AS 'Type',
	'(GMT-05:00) Eastern Time (US & Canada)' AS 'TimeZone',
	'English - United States' AS 'LanguageCode', 

	NULL AS 'AddressType',
	NULL AS 'BusinessPhoneExtension',
	NULL AS 'BusinessFaxExtension',
	NULL AS 'ContactCode',
	NULL AS 'AssistantFirstName',
	NULL AS 'AssistantLastName',
	NULL AS 'AssistantMiddleName',
	NULL AS 'AssistantPhone',
	NULL AS 'AssistantPhoneExtension',
	NULL AS 'AssistantPhoneLocalNumber',
	NULL AS 'AssistantSalutationCode',
	NULL AS 'AssistantSuffixCode',
	NULL AS 'Mobile',
	NULL AS 'MobileExtension',
	NULL AS 'MobileLocalNumber',
	NULL AS 'Pager',
	NULL AS 'PagerExtension',
	NULL AS 'PagerLocalNumber',
	NULL AS 'BusinessFaxLocalNumber',
	NULL AS 'BusinessPhoneLocalNumber',
	NULL AS 'BusinessTitle',
	NULL AS 'HomeFax',
	NULL AS 'HomeFaxExtension',
	NULL AS 'HomeFaxLocalNumber',
	NULL AS 'HomePhone',
	NULL AS 'HomePhoneExtension',
	NULL AS 'HomePhoneLocalNumber',
	NULL AS 'ISDN',
	NULL AS 'ISDNExtension',
	NULL AS 'ISDNLocalNumber',
	NULL AS 'ContactMiddleName',
	NULL AS 'Password',
	NULL AS 'PasswordIV',
	NULL AS 'PasswordSalt',
	NULL AS 'Email2',
	NULL AS 'EmailRule',
	NULL AS 'Username',
	NULL AS 'WebSiteCode',
	NULL AS 'IsAllowWebAccess',
	NULL AS 'DepartmentCode',
	NULL AS 'JobRoleCode',
	NULL AS 'ManagerCode',
	NULL AS 'TemplateCodePricingImport',
	NULL AS 'ProductFilteringTemplateNamePricingImport',
	NULL AS 'ProductFilterID',
	
	(
		SELECT
			z.CustomerCode
		FROM
			acdd.dbo.Customer z
		WHERE
			c.CUSTNUM = z.CustomerLegacyCode
	) AS 'DefaultBillingCode',
	
	NULL AS 'DefaultShippingCode',
	NULL AS 'ContactGUID',
	NULL AS 'SubscriptionExpirationOn'
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
	(
		SELECT
			z.CustomerCode
		FROM
			acdd.dbo.Customer z
		WHERE
			z.CustomerLegacyCode = x.CUSTNUM
	) IS NOT NULL

	AND

	/* Hasn't been imported */
	(
		SELECT
			COUNT(z.ContactLegacyCode)
		FROM
			acdd.dbo.CRMContact z
		WHERE
			z.ContactLegacyCode = x.CUSTNUM
	) = 0
ORDER BY c.CUSTNUM ASC	