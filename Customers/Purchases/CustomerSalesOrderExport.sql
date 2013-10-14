/*

 +---------------------------------+
 | MOM Customer Sales Order Export | MOM v6.2 -> CB 13.2
 +---------------------------------+-------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

ORDER_TYPE

ABF - Freight
DCN - Recip shipping No
DFR - Free Ship UPS
DU2 - UPS 2nd day air
DU3 - UPS 3 day
DUN - UPs next day
DUP - UPS GRD
FG  - Fedex Gnd Comm
FH  - Fedex Commercial
FRS - Free ship UPS GND
FRT - Freight
FX2 - Fedex Express 2 day air
FX3 - Fedex Express 3 day saver
FXG - Fedex Ground
FXP - Fedex Priority Overnight
FXS - Fedex Standard Overnight
OTH - Other
PKU - Customer pickup
UFT - UPS Freight
UP2 - UPS Second Day Air
UP3 - UPS 3 day select
UPC - UPS Ground - comm
UPN - UPS Nxt day air
UPS - UPS Ground

CUSTNUM BILL
SHIPNUM
SOLDNUM (hardly used)

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
	ShipToCode
	NULL AS 'SalesOrderCode',
	BillToCode
	s.SHIP_DATE AS 'ShippingDate',
	s.SHIP_DATE AS 'LatestShipDate',
	ExchangeRate
	'Sales Order' AS 'Type',
	'Sales' AS 'ApplyTo',
ARAccountCode
	BillToCountry
	BillToPostalCode
	ContactCode
	CouponCode
	CouponType
DiscountAccountCode
	NULL AS 'DiscountType',
FreightAccountCode
	FreightTaxCode
	OpportunityCode
OtherAccountCode
	OtherTaxCode
	PaymentTermGroup
	ReceivableCode
	ShipToCountry
	ShipToName
	ShipToPostalCode
	SourceCode
	'MAIN' AS 'WarehouseCode',
	NULL AS 'SourceSalesOrderCode',
	NULL AS 'RootDocumentCode',
	s.ORD_DATE AS 'SalesOrderDate',
	NULL AS 'ProjectCode',
	BillToName
	s.ORD_TOTAL - (s.OTHERCOST + s.SHIPPING + s.TAX) AS 'SubTotal',
	s.ORD_TOTAL - (s.OTHERCOST + s.SHIPPING + s.TAX) AS 'SubTotalRate',
	s.SHIPPING AS 'Freight',
	FreightRate
	FreightTax
	FreightTaxRate
	s.TAX AS 'Tax',
	s.TAX AS 'TaxRate',
	s.ORD_TOTAL AS 'Total',
	s.ORD_TOTAL AS 'TotalRate',
	s.PONUMBER AS 'POCode',
	SalesRepOrderCode
	PODate
	DueDate
	CancelDate
	AmountPaid
	AmountPaidRate
	IsPaid
	s.DUEDAYS AS 'DaysBeforeInterest',
	DiscountableDays
	DiscountPercent
	InterestPercent
	DueType
	StartDate
	DatePaid
	OrderStatus
	BillToAddress
	BillToCity
	BillToState
	BillToCounty
	BillToPhone
	BillToPhoneExtension
	ShipToAddress
	ShipToCity
	ShipToState
	ShipToCounty
	ShipToPhone
	ShipToPhoneExtension
	'USD' AS 'CurrencyCode',
	s.PROCSSD AS 'IsProcessed',
	1 AS 'IsAllowBackOrder',
	Balance
	BalanceRate
	AppliedCredit
	AppliedCreditRate
	Discount
	DiscountRate
	0.00 AS 'WriteOff',
	0.00 AS 'WriteOffRate',
	s.OTHERCOST AS 'Other',
	s.OTHERCOST AS 'OtherRate',
	OtherName
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
			ltrim(rtrim(o.DESC6)) + CHAR(13) + CHAR(10)
		FROM
			[MailOrderManager].[dbo].[ORDMEMO] o
		WHERE
			o.ORDERNO = s.ORDERNO
	) AS 'Notes',
	
	IsVoided
	IsOnHold
	IsPrinted
	IsOrderAcknowledged
	IsFromContract
	NULL AS 'RecurDocumentCode',
	PrintCount
	CouponID
	CouponDiscount
	CouponDiscountRate
	CouponDiscountType
	CouponDiscountPercent
	CouponDiscountAmount
	CouponUsage
	CouponDiscountIncludesFreeShipping
	CouponRequiresMinimumOrderAmount
	IsFreightOverwrite
	WebSiteCode
	NULL AS 'WaveCode',
	SourceType
	NULL AS 'POSWorkstationID',
	NULL AS 'POSClerkID',
	NULL AS 'DownloadEmailSentDate',
	RootOrderCode
	DateShipped
	IsShipped
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
	ReturnedSubTotal
	ReturnedSubTotalRate
	ReturnedTax
	ReturnedTaxRate
	
	CASE WHEN ltrim(rtrim(s.SHIPLIST)) = 'PKU'
		THEN 1
		ELSE 0
		END AS 'IsPickUp',
		
	NULL AS 'BillToAddressType',
	NULL AS 'ShipToAddressType',
	WarehouseAddressType
	NULL AS 'IsBlindShip',
	IsFreightQuoted
	Signature
	SignatureSVG
	NULL AS 'CBNMasterID',
	NULL AS 'BillToPlus4',
	NULL AS 'ShipToPlus4'
WHERE s.QUOTATION = 0