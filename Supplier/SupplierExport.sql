/*

 +---------------------+
 | MOM Supplier Export | MOM v6.2 -> CB 13.2
 +---------------------+-------------------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	NULL AS 'SupplierCode',
	s.NAME AS 'SupplierName',
	'DEFAULT' AS 'ClassCode',
	'DEFAULT' AS 'GLClassCode',
	'United States of America' AS 'Country',
	ShippingMethod
	PaymentTermCode
	WarehouseCode
	TaxCode
	PaymentGroup
	CurrencyCode
	SupplierLegacyCode
	IsActive
	Is1099Supplier
	IsPrinted
	SupplierContactCode
	DefaultAPContact
	DefaultContact
	Factor
	
	CASE WHEN LTRIM(RTRIM(s.L2)) LIKE ''
		THEN master.dbo.udf_TitleCase(LTRIM(RTRIM(s.L1))) + CHAR(13) + CHAR(10) + master.dbo.udf_TitleCase(LTRIM(RTRIM(s.L2)))
		ELSE master.dbo.udf_TitleCase(LTRIM(RTRIM(s.L1)))
		END AS 'Address',
	
	/* 
		City extraction
			Assumption: CITY is before ,
	*/
	CASE WHEN (L3 IS NOT NULL) AND (charindex(',', L3)>0)
		THEN ltrim(rtrim(left(
				L3,
				charindex(
					',',
					L3
				) - 1
			)))
		ELSE NULL
		END AS 'City',
	
	/* 
		State extraction
			Assumption: STATE is after , and before '  '
	*/
	CASE WHEN (L3 IS NOT NULL) AND (charindex(',', L3)>0) AND (charindex('  ', ltrim(rtrim(L3)))>0)
		THEN ltrim(rtrim(right(
				left(
					L3,
					charindex(
						'  ',
						L3
					) - 1
				),
				len(
					left(
						L3,
						charindex(
							'  ',
							L3
						) - 1
					)
				)
				- charindex(
					',',
					left(
						L3,
						charindex(
							'  ',
							L3
						) -1 
					)
				)
			)))
		ELSE NULL
		END AS 'State',
		
	/* 
		ZIP extraction
			Assumption: ZIP is after '  ' and before <END> OR -
	*/		
	CASE WHEN (L3 IS NOT NULL) AND (charindex('  ', ltrim(rtrim(L3)))>0)
		THEN CASE WHEN
			charindex('-', ltrim(rtrim(right(
				ltrim(rtrim(L3)),
				len(
					ltrim(rtrim(L3))
				)
				- charindex(
					'  ', 
					ltrim(rtrim(L3))
				)
			)))) > 0
			THEN
				left(
					ltrim(rtrim(right(
						ltrim(rtrim(L3)),
						len(
							ltrim(rtrim(L3))
						)
						- charindex(
							'  ', 
							ltrim(rtrim(L3))
						)
					))),
					charindex(
						'-',
						ltrim(rtrim(right(
							ltrim(rtrim(L3)),
							len(
								ltrim(rtrim(L3))
							)
							- charindex(
								'  ', 
								ltrim(rtrim(L3))
							)
						)))
					) - 1
				)
			ELSE
				ltrim(rtrim(right(
						ltrim(rtrim(L3)),
						len(
							ltrim(rtrim(L3))
						)
						- charindex(
							'  ', 
							ltrim(rtrim(L3))
						)
					)))
			END
		ELSE NULL
		END AS 'PostalCode',

	/* 
		Plus4 extraction
			Assumption: PLUS4 is after '-' and before <END> USING ZIP extraction
	*/	
	CASE WHEN (L3 IS NOT NULL) AND (charindex('-', ltrim(rtrim(L3)))>0)
		THEN CASE WHEN
			charindex('-', ltrim(rtrim(right(
				ltrim(rtrim(L3)),
				len(
					ltrim(rtrim(L3))
				)
				- charindex(
					'  ', 
					ltrim(rtrim(L3))
				)
			)))) > 0
			THEN
				right(
					ltrim(rtrim(right(
						ltrim(rtrim(L3)),
						len(
							ltrim(rtrim(L3))
						)
						- charindex(
							'  ', 
							ltrim(rtrim(L3))
						)
					))),
					charindex(
						'-',
						ltrim(rtrim(right(
							ltrim(rtrim(L3)),
							len(
								ltrim(rtrim(L3))
							)
							- charindex(
								'  ', 
								ltrim(rtrim(L3))
							)
						)))
					) - 2
				)
			ELSE NULL
			END
		ELSE NULL
		END AS 'Plus4',
	
	County
	Telephone
	TelephoneLocalNumber
	TelephoneExtension
	Fax
	FaxLocalNumber
	FaxExtension
	Email
	Website
	Source
	Notes
	ExpenseAccountCode
	HistoricalAccountCode
	SupplierAccountNumber
	CreditLimit
	LandedCostPercent
	NoOfReceiptsUnPosted
	NoOfReturnsUnPosted
	NoOfPaymentsUnPosted
	TotalCreditsUnPosted
	TotalReturnsUnPosted
	TotalPaymentsUnPosted
	NoOfReceipts
	NoOfReturns
	NoOfPayments
	TotalCredits
	TotalReturns
	TotalPayments
	LargestPaymentMade
	LowestPaymentMade
	LastReceiptCode
	LastReturnCode
	LastPaymentCode
	BankSortCode
	BankAccountNumber
	BankAccountName
	BankPaymentReference
	DebtChaseStatus
	DebtChaser
	RecallDate
	SendPreference
	PrintCount
	DefaultShipFromContact
	DefaultShipFrom
	TaxNumber
	AllowBackOrder
	IsCBN
	CBNNetworkID
	OrderFee
	OrderFeeRate
	AddressType
	MinOrderAmtPricingImport
	ItemPrefixPricingImport