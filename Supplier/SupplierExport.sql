/*

 +---------------------+
 | MOM Supplier Export | MOM v6.2 -> CB 13.2
 +---------------------+-------------------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	NULL AS 'SupplierCode',
	master.dbo.udf_TitleCase(LTRIM(RTRIM(s.NAME))) AS 'SupplierName',
	'DEFAULT' AS 'ClassCode',
	'DEFAULT' AS 'GLClassCode',
	'United States of America' AS 'Country',
	'User Entered' AS 'ShippingMethod',
	'NET' + ltrim(rtrim(s.DUE_DAYS)) AS 'PaymentTermCode',
	'MAIN' AS 'WarehouseCode',
	'Purchases No Tax' AS 'TaxCode',
	'Check Only' AS 'PaymentGroup',
	'USD' AS 'CurrencyCode',
	s.CODE AS 'SupplierLegacyCode',
	~s.INACTIVE AS 'IsActive',
	0 AS 'Is1099Supplier',
	NULL AS 'IsPrinted',
	
	/* Will be populated by later query */
	NULL AS 'SupplierContactCode',
	NULL AS 'DefaultAPContact',
	NULL AS 'DefaultContact',
	
	NULL AS 'Factor',
	
	CASE WHEN LTRIM(RTRIM(s.L2)) LIKE ''
		THEN master.dbo.udf_TitleCase(LTRIM(RTRIM(s.L1))) + CHAR(13) + CHAR(10) + master.dbo.udf_TitleCase(LTRIM(RTRIM(s.L2)))
		ELSE master.dbo.udf_TitleCase(LTRIM(RTRIM(s.L1)))
		END AS 'Address',
	
	/* 
		City extraction
			Assumption: CITY is before ,
	*/
	CASE WHEN (s.L3 IS NOT NULL) AND (charindex(',', s.L3)>0)
		THEN master.dbo.udf_TitleCase(ltrim(rtrim(left(
				s.L3,
				charindex(
					',',
					s.L3
				) - 1
			))))
		ELSE NULL
		END AS 'City',

	/* 
		State extraction
			Assumption: STATE is after , and before '  '
	*/
	CASE WHEN (s.L3 IS NOT NULL) AND (charindex(',', s.L3)>0) AND (charindex('  ', ltrim(rtrim(s.L3)))>0)
		THEN ltrim(rtrim(right(
				left(
					s.L3,
					charindex(
						'  ',
						s.L3
					) - 1
				),
				len(
					left(
						s.L3,
						charindex(
							'  ',
							s.L3
						) - 1
					)
				)
				- charindex(
					',',
					left(
						s.L3,
						charindex(
							'  ',
							s.L3
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
	CASE WHEN (s.L3 IS NOT NULL) AND (charindex('  ', ltrim(rtrim(s.L3)))>0)
		THEN CASE WHEN
			charindex('-', ltrim(rtrim(right(
				ltrim(rtrim(s.L3)),
				len(
					ltrim(rtrim(s.L3))
				)
				- charindex(
					'  ', 
					ltrim(rtrim(s.L3))
				)
			)))) > 0
			THEN
				left(
					ltrim(rtrim(right(
						ltrim(rtrim(s.L3)),
						len(
							ltrim(rtrim(s.L3))
						)
						- charindex(
							'  ', 
							ltrim(rtrim(s.L3))
						)
					))),
					charindex(
						'-',
						ltrim(rtrim(right(
							ltrim(rtrim(s.L3)),
							len(
								ltrim(rtrim(s.L3))
							)
							- charindex(
								'  ', 
								ltrim(rtrim(s.L3))
							)
						)))
					) - 1
				)
			ELSE
				ltrim(rtrim(right(
						ltrim(rtrim(s.L3)),
						len(
							ltrim(rtrim(s.L3))
						)
						- charindex(
							'  ', 
							ltrim(rtrim(s.L3))
						)
					)))
			END
		ELSE NULL
		END AS 'PostalCode',

	/* 
		Plus4 extraction
			Assumption: PLUS4 is after '-' and before <END> USING ZIP extraction
	*/	
	CASE WHEN (s.L3 IS NOT NULL) AND (charindex('-', ltrim(rtrim(s.L3)))>0)
		THEN CASE WHEN
			charindex('-', ltrim(rtrim(right(
				ltrim(rtrim(s.L3)),
				len(
					ltrim(rtrim(s.L3))
				)
				- charindex(
					'  ', 
					ltrim(rtrim(s.L3))
				)
			)))) > 0
			THEN
				right(
					ltrim(rtrim(right(
						ltrim(rtrim(s.L3)),
						len(
							ltrim(rtrim(s.L3))
						)
						- charindex(
							'  ', 
							ltrim(rtrim(s.L3))
						)
					))),
					charindex(
						'-',
						ltrim(rtrim(right(
							ltrim(rtrim(s.L3)),
							len(
								ltrim(rtrim(s.L3))
							)
							- charindex(
								'  ', 
								ltrim(rtrim(s.L3))
							)
						)))
					) - 2
				)
			ELSE NULL
			END
		ELSE NULL
		END AS 'Plus4',
	
	/* THIS WILL PROBABLY FAIL VALIDATION! */
	NULL AS 'County',
	
	s.PHONE AS 'Telephone',
	NULL AS 'TelephoneLocalNumber',
	s.PHONEEXT AS 'TelephoneExtension',
	s.FAX AS 'Fax',
	NULL AS 'FaxLocalNumber',
	NULL AS 'FaxExtension',
	s.EMAIL AS 'Email',
	NULL AS 'Website',
	'Unknown' AS 'Source',
	
	(
		'Instructions:'
		+ CHAR(13) + CHAR(10) +
		LTRIM(RTRIM(s.INSTRUCT1))
		+ CHAR(13) + CHAR(10) +
		LTRIM(RTRIM(s.INSTRUCT2))
		+ CHAR(13) + CHAR(10) +
		LTRIM(RTRIM(s.INSTRUCT3))
		+ CHAR(13) + CHAR(10) +
		+ CHAR(13) + CHAR(10) +
		'Notes:'
		+ CHAR(13) + CHAR(10) +
		LTRIM(RTRIM(s.NOTE1))
		+ CHAR(13) + CHAR(10) +
		LTRIM(RTRIM(s.NOTE2))
		+ CHAR(13) + CHAR(10) +
		LTRIM(RTRIM(s.NOTE3))
	) AS 'Notes',
	
	NULL AS 'ExpenseAccountCode',
	NULL AS 'HistoricalAccountCode',
	s.ACCOUNT AS 'SupplierAccountNumber',
	0 AS 'CreditLimit',
	NULL AS 'LandedCostPercent',
	
	/* Will consider these */
	0 AS 'NoOfReceiptsUnPosted',
	0 AS 'NoOfReturnsUnPosted',
	0 AS 'NoOfPaymentsUnPosted',
	0 AS 'TotalCreditsUnPosted',
	0 AS 'TotalReturnsUnPosted',
	0 AS 'TotalPaymentsUnPosted',
	0 AS 'NoOfReceipts',
	0 AS 'NoOfReturns',
	0 AS 'NoOfPayments',
	0 AS 'TotalCredits',
	0 AS 'TotalReturns',
	0 AS 'TotalPayments',
	0 AS 'LargestPaymentMade',
	0 AS 'LowestPaymentMade',
	
	NULL AS 'LastReceiptCode',
	NULL AS 'LastReturnCode',
	NULL AS 'LastPaymentCode',
	NULL AS 'BankSortCode',
	NULL AS 'BankAccountNumber',
	NULL AS 'BankAccountName',
	NULL AS 'BankPaymentReference',
	NULL AS 'DebtChaseStatus',
	NULL AS 'DebtChaser',
	NULL AS 'RecallDate',
	NULL AS 'SendPreference',
	NULL AS 'PrintCount',
	
	/* Will be populated by later query */
	NULL AS 'DefaultShipFromContact',
	NULL AS 'DefaultShipFrom',
	
	NULL AS 'TaxNumber',
	1 AS 'AllowBackOrder',
	NULL AS 'IsCBN',
	NULL AS 'CBNNetworkID',
	NULL AS 'OrderFee',
	NULL AS 'OrderFeeRate',
	NULL AS 'AddressType',
	0 AS 'MinOrderAmtPricingImport',
	NULL AS 'ItemPrefixPricingImport'
FROM [MailOrderManager].[dbo].[SUPPLIER] s