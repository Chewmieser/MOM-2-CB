/*

 +-------------------------------------+
 | MOM Customer Sales Quotation Export | MOM v6.2 -> CB 13.2
 +-------------------------------------+---------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	CASE ltrim(rtrim(s.PAYMETHOD))
		WHEN 'CC' THEN 'Credit Card'
		ELSE 'NET'+s.DUEDAYS
		END AS 'PaymentTermCode',

	CASE ltrim(rtrim(s.SHIPLIST))
		WHEN 'ABF' THEN 'Freight'
		WHEN 'DCN' THEN 'User Entered'
		WHEN 'DFR' THEN 'Ground'
		WHEN 'DU2' THEN '2nd Day'
		WHEN 'DU3' THEN '3 Day'
		WHEN 'DUN' THEN 'Next Day'
		WHEN 'DUP' THEN 'Ground'
		WHEN 'FG ' THEN 'Ground'
		WHEN 'FH ' THEN 'Ground'
		WHEN 'FRS' THEN 'Ground'
		WHEN 'FRT' THEN 'Freight'
		WHEN 'FX2' THEN '2nd Day'
		WHEN 'FX3' THEN '3 Day'
		WHEN 'FXG' THEN 'Ground'
		WHEN 'FXP' THEN 'Next Day'
		WHEN 'FXS' THEN 'Next Day'
		WHEN 'OTH' THEN 'User Entered'
		WHEN 'PKU' THEN 'No Shipping Required'
		WHEN 'UFT' THEN 'Freight'
		WHEN 'UP2' THEN '2nd Day'
		WHEN 'UP3' THEN '3 Day'
		WHEN 'UPC' THEN 'Ground'
		WHEN 'UPN' THEN 'Next Day'
		WHEN 'UPS' THEN 'Ground'
		ELSE 'User Entered'
		END AS 'ShippingMethodCode',
	
	'DEFAULT' AS 'ShippingMethodGroup',
	
	/* Will be generated */
	NULL AS 'ShipToCode',
	NULL AS 'BillToCode',
	NULL AS 'SalesOrderCode',
	NULL AS 'ContactCode',
	
	s.SHIP_DATE AS 'ShippingDate',
	s.SHIP_DATE AS 'LatestShipDate',
	1.0 AS 'ExchangeRate',
	'Sales Order' AS 'Type',
	'Sales' AS 'ApplyTo',
	
	'1100-0' AS 'ARAccountCode',
	'7100-1' AS 'DiscountAccountCode',
	'4100-1' AS 'FreightAccountCode',
	'4000-1' AS 'OtherAccountCode',

	NULL AS 'DiscountType',
	'Sales No Tax' AS 'FreightTaxCode',
	NULL AS 'OpportunityCode',

	'Sales No Tax' AS 'OtherTaxCode',
	'DEFAULT' AS 'PaymentTermGroup',
	NULL AS 'ReceivableCode',
	
	CASE ltrim(rtrim(s.ORDERTYPE))
		WHEN 'RETPHO' THEN 'Phone'
		WHEN 'NEWPHO' THEN 'Phone'
		WHEN 'RETWEB' THEN 'Web'
		WHEN 'NEWWEB' THEN 'Web'
		ELSE 'Unknown'
		END AS 'SourceCode',
	
	'MAIN' AS 'WarehouseCode',
	s.ORDERNO AS 'SourceSalesOrderCode',
	NULL AS 'RootDocumentCode',
	s.ORD_DATE AS 'SalesOrderDate',
	NULL AS 'ProjectCode',
	s.ORD_TOTAL - (s.OTHERCOST + s.SHIPPING + s.TAX) AS 'SubTotal',
	s.ORD_TOTAL - (s.OTHERCOST + s.SHIPPING + s.TAX) AS 'SubTotalRate',
	s.SHIPPING AS 'Freight',
	s.SHIPPING AS 'FreightRate',
	0.00 AS 'FreightTax',
	0.00 AS 'FreightTaxRate',
	s.TAX AS 'Tax',
	s.TAX AS 'TaxRate',
	s.ORD_TOTAL AS 'Total',
	s.ORD_TOTAL AS 'TotalRate',
	s.PONUMBER AS 'POCode',
	NULL AS 'SalesRepOrderCode',
	s.ORD_DATE AS 'PODate',
	dateadd(day, s.DUE_DAYS, s.ORD_DATE) AS 'DueDate',
	NULL AS 'CancelDate',
	s.CHECKAMOUN AS 'AmountPaid',
	s.CHECKAMOUN AS 'AmountPaidRate',
	
	CASE WHEN s.ORD_TOTAL <= s.CHECKAMOUN
		THEN 1
		ELSE 0
		END AS 'IsPaid',
	
	s.DUEDAYS AS 'DaysBeforeInterest',
	1 AS 'DiscountableDays',
	0.00 AS 'DiscountPercent',
	0.00 AS 'InterestPercent',
	'Net Days - From Invoice Date' AS 'DueType',
	NULL AS 'StartDate',
	NULL AS 'DatePaid',
	
	CASE s.ORD_ST2
		WHEN 'BI' THEN 'Open' /* Ready to invoice */
		WHEN 'BO' THEN 'Open' /* Back-ordered */
		WHEN 'CD' THEN 'Voided' /* Credit denied - Suspended */
		WHEN 'CN' THEN 'Voided' /* Canceled */
		WHEN 'FH' THEN 'Open' /* Fraud hold */
		WHEN 'GD' THEN 'Voided' /* Google Checkout - Canceled */
		WHEN 'GN' THEN 'Open' /* Google Checkout - Ready to charge */
		WHEN 'GS' THEN 'Completed' /* Google Checkout - Shipped */
		WHEN 'II' THEN 'Voided' /* Invalid credit info - Suspended */
		WHEN 'IN' THEN 'Open' /* Invoiced - Ready to pack */
		WHEN 'OR' THEN 'Open' /* Order on review */
		WHEN 'PE' THEN 'Open' /* Permanent hold */
		WHEN 'QO' THEN 'Open' /* Quotation */
		WHEN 'SH' THEN 'Completed' /* Shipped all merchandise */
		WHEN 'UO' THEN 'Open' /* Uncompleted - Order on hold */
		ELSE 'Open'
		END AS 'OrderStatus',
	
	/* Cardholder -> Bill-to info */
	/*CASE WHEN ltrim(rtrim(s.CARDHOLDER)) IS NOT NULL
		THEN master.dbo.udf_TitleCase(ltrim(rtrim(s.CARDHOLDER)))
		ELSE (master.dbo.udf_TitleCase(LTRIM(RTRIM(c.FIRSTNAME))) + ' ' + master.dbo.udf_TitleCase(LTRIM(RTRIM(c.LASTNAME))))*/

	BillToName
	
	/* Combine address lines */
	CASE WHEN bs.DeliveryLine1 IS NULL /* Fallback to MOM data */
		THEN CASE WHEN b.ADDR2 LIKE ''
			THEN CASE WHEN ltrim(rtrim(b.ADDR)) LIKE ''
				THEN NULL
				ELSE ltrim(rtrim(b.ADDR))
				END
			ELSE ltrim(rtrim(b.ADDR)) + CHAR(13) + CHAR(10) + ltrim(rtrim(b.ADDR2))
			END
		ELSE CASE WHEN bs.DeliveryLine2 IS NULL
			THEN CASE WHEN b.DeliveryLine1 IS NULL
				THEN NULL
				ELSE bs.DeliveryLine1
				END
			ELSE CONVERT(varchar(100), bs.DeliveryLine1) + CHAR(13) + CHAR(10) + CONVERT(varchar(100), bs.DeliveryLine2)
			END
		END AS 'BillToAddress',
	
	bs.CITY AS 'BillToCity',
	bs.STATE AS 'BillToState',
	bs.ZIPCode AS 'BillToPostalCode',
	bs.CountyName AS 'BillToCounty',
	
	CASE WHEN ltrim(rtrim(b.PHONE)) LIKE '-   -' OR ltrim(rtrim(b.PHONE)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(b.PHONE))
		END AS 'BillToPhone',

	NULL AS 'BillToPhoneExtension',
	
	CASE b.COUNTRY
		WHEN 001 THEN 'United States of America'
		ELSE NULL
		END AS 'BillToCountry',
		
	ShipToName
	
	/* Combine address lines */
	CASE WHEN hs.DeliveryLine1 IS NULL /* Fallback to MOM data */
		THEN CASE WHEN h.ADDR2 LIKE ''
			THEN CASE WHEN ltrim(rtrim(h.ADDR)) LIKE ''
				THEN NULL
				ELSE ltrim(rtrim(h.ADDR))
				END
			ELSE ltrim(rtrim(h.ADDR)) + CHAR(13) + CHAR(10) + ltrim(rtrim(h.ADDR2))
			END
		ELSE CASE WHEN hs.DeliveryLine2 IS NULL
			THEN CASE WHEN hs.DeliveryLine1 IS NULL
				THEN NULL
				ELSE hs.DeliveryLine1
				END
			ELSE CONVERT(varchar(100), hs.DeliveryLine1) + CHAR(13) + CHAR(10) + CONVERT(varchar(100), hs.DeliveryLine2)
			END
		END AS 'ShipToAddress',
	
	hs.CITY AS 'ShipToCity',
	hs.STATE AS 'ShipToState',
	hs.ZIPCode AS 'ShipToPostalCode',
	hs.CountyName AS 'ShipToCounty',
	
	CASE h.COUNTRY
		WHEN 001 THEN 'United States of America'
		ELSE NULL
		END AS 'ShipToCountry',
	
	CASE WHEN ltrim(rtrim(h.PHONE)) LIKE '-   -' OR ltrim(rtrim(h.PHONE)) LIKE ''
		THEN NULL
		ELSE ltrim(rtrim(h.PHONE))
		END AS 'ShipToPhone',

	NULL AS 'ShipToPhoneExtension',
	
	'USD' AS 'CurrencyCode',
	s.PROCSSD AS 'IsProcessed',
	1 AS 'IsAllowBackOrder',
	(s.ORD_TOTAL - s.CHECKAMOUN) AS 'Balance',
	(s.ORD_TOTAL - s.CHECKAMOUN) AS 'BalanceRate',
	0.00 AS 'AppliedCredit',
	0.00 AS 'AppliedCreditRate',
	0.00 AS 'Discount',
	0.00 AS 'DiscountRate',
	0.00 AS 'WriteOff',
	0.00 AS 'WriteOffRate',
	s.OTHERCOST AS 'Other',
	s.OTHERCOST AS 'OtherRate',
	NULL AS 'OtherName',
	0.00 AS 'OtherTax',
	'Sales No Tax' AS 'OtherTaxRate',
	
	(
		SELECT
			ltrim(rtrim(o.NOTES)) + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 
			ltrim(rtrim(o.FULFILL)) + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 
			ltrim(rtrim(o.DESC1)) + CHAR(13) + CHAR(10) + 
			ltrim(rtrim(o.DESC2)) + CHAR(13) + CHAR(10) + 
			ltrim(rtrim(o.DESC3)) + CHAR(13) + CHAR(10) + 
			ltrim(rtrim(o.DESC4)) + CHAR(13) + CHAR(10) + 
			ltrim(rtrim(o.DESC5)) + CHAR(13) + CHAR(10) + 
			ltrim(rtrim(o.DESC6))
		FROM
			[MailOrderManager].[dbo].[ORDMEMO] o
		WHERE
			o.ORDERNO = s.ORDERNO
	) AS 'Notes',
	
	CASE s.ORD_ST2
		WHEN 'CD' THEN 1 /* Credit denied - Suspended */
		WHEN 'CN' THEN 1 /* Canceled */
		WHEN 'GD' THEN 1 /* Google Checkout - Canceled */
		WHEN 'II' THEN 1 /* Invalid credit info - Suspended */
		ELSE 0
		END AS 'IsVoided',
	
	IsOnHold
	
	CASE WHEN s.SHIP_DATE IS NOT NULL
		THEN 1
		ELSE 0
		END AS 'IsPrinted',
		
	CASE WHEN s.SHIP_DATE IS NOT NULL
		THEN 1
		ELSE 0
		END AS 'PrintCount',
		
	0 AS 'IsOrderAcknowledged',
	0 AS 'IsFromContract',
	NULL AS 'RecurDocumentCode',
	
	(
		SELECT
			ltrim(rtrim(c.PROMO_CODE))
		FROM
			[MailOrderManager].[dbo].[ORDTOOLS] c
		WHERE
			c.ORDERNO = s.ORDERNO
	) AS 'CouponCode',
	
	NULL AS 'CouponType',
	
	(
		SELECT
			ltrim(rtrim(c.PROMO_CODE))
		FROM
			[MailOrderManager].[dbo].[ORDTOOLS] c
		WHERE
			c.ORDERNO = s.ORDERNO
	) AS 'CouponID',
	
	(
		SELECT
			c.AMOUNT
		FROM
			[MailOrderManager].[dbo].[ORDTOOLS] c
		WHERE
			c.ORDERNO = s.ORDERNO
	) AS 'CouponDiscount',
	
	(
		SELECT
			c.AMOUNT
		FROM
			[MailOrderManager].[dbo].[ORDTOOLS] c
		WHERE
			c.ORDERNO = s.ORDERNO
	) AS 'CouponDiscountRate',
	
	'Amount' AS 'CouponDiscountType',
	NULL AS 'CouponDiscountPercent',
	NULL AS 'CouponDiscountAmount',	
	~s.NO_PROMO AS 'CouponUsage',
	
	(
		SELECT
			CASE WHEN ltrim(rtrim(c.SHIP_VIA)) IS NOT NULL
				THEN 1
				ELSE 0
				END
		FROM
			[MailOrderManager].[dbo].[ORDTOOLS] c
		WHERE
			c.ORDERNO = s.ORDERNO
	) AS 'CouponDiscountIncludesFreeShipping',
	
	0 AS 'CouponRequiresMinimumOrderAmount',
	IsFreightOverwrite
	NULL AS 'WebSiteCode',
	NULL AS 'WaveCode',
	NULL AS 'SourceType',
	NULL AS 'POSWorkstationID',
	NULL AS 'POSClerkID',
	NULL AS 'DownloadEmailSentDate',
	NULL AS 'RootOrderCode',
	s.SHIP_DATE AS 'DateShipped',
	
	CASE WHEN s.SHIP_DATE IS NOT NULL
		THEN 1
		ELSE 0
		END AS 'IsShipped',
		
	NULL AS 'SaveCounterID',
	NULL AS 'CouponComputation',
	NULL AS 'TaxGroup1',
	NULL AS 'TaxGroup1Rate',
	NULL AS 'TaxGroup2',
	NULL AS 'TaxGroup2Rate',
	NULL AS 'TaxGroup3',
	NULL AS 'TaxGroup3Rate',
	NULL AS 'MerchantOrderID_DEV000221',
	NULL AS 'PaymentFailedEmailSent_DEV000221',
	NULL AS 'SourceFeedbackMessage_DEV000221',
	NULL AS 'SourceFeedbackType_DEV000221',
	NULL AS 'IsCBN',
	NULL AS 'CBNPO',
	NULL AS 'CBNSO',
	NULL AS 'CBNState',
	NULL AS 'InternalNotesCode',
	NULL AS 'InternalNotesDescription',
	NULL AS 'InternalNotes',
	NULL AS 'PublicNotesCode',
	NULL AS 'StoreMerchantID_DEV000221',
	NULL AS 'PublicNotesDescription',
	NULL AS 'PublicNotes',
	
	(
		SELECT
			r.RMA_TOTAL
		FROM
			[MailOrderManager].[dbo].[RMA] r
		WHERE
			r.ORDERNO = s.ORDERNO
	) AS 'ReturnedSubTotal',
	
	(
		SELECT
			r.RMA_TOTAL
		FROM
			[MailOrderManager].[dbo].[RMA] r
		WHERE
			r.ORDERNO = s.ORDERNO
	) AS 'ReturnedSubTotalRate',
	
	0.00 AS 'ReturnedTax',
	0.00 AS 'ReturnedTaxRate',
	
	CASE WHEN ltrim(rtrim(s.SHIPLIST)) = 'PKU'
		THEN 1
		ELSE 0
		END AS 'IsPickUp',
		
	NULL AS 'BillToAddressType',
	NULL AS 'ShipToAddressType',
	NULL AS 'WarehouseAddressType',
	NULL AS 'IsBlindShip',
	IsFreightQuoted
	NULL AS 'Signature',
	NULL AS 'SignatureSVG',
	NULL AS 'CBNMasterID',
	NULL AS 'BillToPlus4',
	NULL AS 'ShipToPlus4'
FROM
	[MailOrderManager].[dbo].[CMS] s
	
	/* Cross-reference with customer accounts */
	JOIN [MailOrderManager].[dbo].[CUST] b
		ON b.CUSTNUM = s.CUSTNUM
	JOIN [MailOrderManager].[dbo].[CUST] h
		ON h.CUSTNUM = (CASE WHEN s.SHIPNUM = 0 THEN s.CUSTNUM ELSE s.SHIPNUM END)
		
	/* Pull sanitized information */
	JOIN momscripts.dbo.MomCustSanitized bs
		ON bs.CustomerID = s.CUSTNUM
	JOIN momscripts.dbo.MomCustSanitized hs
		ON hs.CustomerID = (CASE WHEN s.SHIPNUM = 0 THEN s.CUSTNUM ELSE s.SHIPNUM END)
WHERE s.QUOTATION = 1