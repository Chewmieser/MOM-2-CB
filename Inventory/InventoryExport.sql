/*

 +----------------------+
 | MOM Inventory Export | MOM v6.2 -> CB 13.2
 +----------------------+------------------------------------------+
 | Sanitizes and translates between MOM and CB database structures |
 +-----------------------------------------------------------------+

 */

SELECT
	rtrim(ltrim(i.NUMBER)) AS 'ItemName',
	NULL AS 'ItemCode',
	'Stock' AS 'ItemType',
	'A' AS 'Status',
	'Average Cost' AS 'CostingMethod',
	'DEFAULT-STOCK' AS 'ClassCode',
	'DEFAULT-STOCK' AS 'GLClassCode',
	rtrim(ltrim(i.NOTATION)) AS 'Notes',
	1 AS 'IsCommissionable',
	i.DROPSHIP AS 'IsDropShip',
	0 AS 'IsSpecialOrder',
	i.UNCOST AS 'StandardCost',
	i.UNCOST AS 'CurrentCost',
	i.UNCOST AS 'AverageCost',
	
	/* -- SKU -> MFD Translation -- */
	CASE WHEN charindex('-',i.NUMBER) > 0
		THEN
			CASE left(i.NUMBER, charindex('-', i.NUMBER)-1)
				WHEN 'ACA' THEN 'Academy Computer Serviced'
				WHEN 'ACL' THEN 'Ace Label'
				WHEN 'ACR' THEN 'Acronova Technology'
				WHEN 'ADT' THEN 'Adaptec'
				WHEN 'ALP' THEN 'All Pro'
				WHEN 'AMT' THEN 'Aron Services'
				WHEN 'ARO' THEN 'Aron Services'
				WHEN 'ASA' THEN 'ASAP Inc'
				WHEN 'ATZ' THEN 'Atarza'
				WHEN 'BPG' THEN 'Blair Packaging'
				WHEN 'CAN' THEN 'Cannon'
				WHEN 'CAP' THEN 'Captaris'
				WHEN 'CD' THEN 'General'
				WHEN 'CDD' THEN 'CD Dimensions'
				WHEN 'CDR' THEN 'General'
				WHEN 'CHY' THEN 'Dexxon'
				WHEN 'DER' THEN 'Dering'
				WHEN 'DGS' THEN 'Dexxon'
				WHEN 'DIG' THEN 'Digitech'
				WHEN 'DIS' THEN 'Microboards'
				WHEN 'DLK' THEN 'Wynit'
				WHEN 'DM' THEN 'Data Memory'
				WHEN 'DSL' THEN 'ILY Enterprises'
				WHEN 'DVD' THEN 'ILY Enterprises'
				WHEN 'DYM' THEN 'Sanford Brands'
				WHEN 'EAS' THEN 'Accutech'
				WHEN 'EM' THEN 'Emtec'
				WHEN 'EMT' THEN 'Emtec'
				WHEN 'ENP' THEN 'Information Packaging'
				WHEN 'EPS' THEN 'Epson'
				WHEN 'ES' THEN 'EasyStore'
				WHEN 'FJI' THEN 'Fujitsu'
				WHEN 'FLC' THEN 'Falcon'
				WHEN 'FUJ' THEN 'Fuji'
				WHEN 'GDW' THEN 'Global Discware'
				WHEN 'GEN' THEN 'General'
				WHEN 'HEX' THEN 'Hexalock'
				WHEN 'HP' THEN 'Hewlett Packard'
				WHEN 'IBM' THEN 'IBM'
				WHEN 'IL' THEN 'Lite-On'
				WHEN 'IMA' THEN 'Imatation'
				WHEN 'INF' THEN 'Information Packaging'
				WHEN 'JVC' THEN 'JVC'
				WHEN 'KNG' THEN 'Kingston'
				WHEN 'KOD' THEN 'Kodak'
				WHEN 'KRU' THEN 'Kanguru'
				WHEN 'LEN' THEN 'Lenovo'
				WHEN 'LTO' THEN 'Lite-On'
				WHEN 'MAM' THEN 'MAM-A'
				WHEN 'MAR' THEN 'Martin Yale'
				WHEN 'MAX' THEN 'Maxell'
				WHEN 'MEM' THEN 'Memorex'
				WHEN 'MFD' THEN 'Formats Unlimited'
				WHEN 'MIC' THEN 'Microboards'
				WHEN 'MTC' THEN 'Tri-Pillar'
				WHEN 'NEX' THEN 'Nexcopy'
				WHEN 'NOR' THEN 'Norazza'
				WHEN 'OCT' THEN 'Open Text'
				WHEN 'OLY' THEN 'Olypus'
				WHEN 'OT' THEN 'Open Text'
				WHEN 'OTC' THEN 'Open Text'
				WHEN 'PAN' THEN 'Panasonic'
				WHEN 'PAS' THEN 'Perm-a-Store'
				WHEN 'PD' THEN 'Atarza'
				WHEN 'PDE' THEN 'PDE Technology'
				WHEN 'PHI' THEN 'Philips'
				WHEN 'PIO' THEN 'Pioneer'
				WHEN 'PNT' THEN 'PoINT'
				WHEN 'PNY' THEN 'PNY'
				WHEN 'PR' THEN 'Promethean'
				WHEN 'PRI' THEN 'Primera'
				WHEN 'PRO' THEN 'Prodisc'
				WHEN 'QDL' THEN 'Microboards'
				WHEN 'QTM' THEN 'Quantum'
				WHEN 'REC' THEN 'Recordex'
				WHEN 'RIC' THEN 'Ricoh'
				WHEN 'RIM' THEN 'Rimage'
				WHEN 'RIT' THEN 'Ritek'
				WHEN 'RQT' THEN 'R-Quest'
				WHEN 'S' THEN 'Open Text'
				WHEN 'SAM' THEN 'Samsung'
				WHEN 'SAN' THEN 'SanDisk'
				WHEN 'SCH' THEN 'Martin Yale'
				WHEN 'SD' THEN 'SanDisk'
				WHEN 'SDL' THEN 'SansDigital'
				WHEN 'SG' THEN 'Sustainable Group'
				WHEN 'SKC' THEN 'SKmax'
				WHEN 'SON' THEN 'Sony'
				WHEN 'SPI' THEN 'SmartPants'
				WHEN 'SPN' THEN 'Spinergy'
				WHEN 'SPX' THEN 'Spin X'
				WHEN 'STQ' THEN 'Microboards'
				WHEN 'TAI' THEN 'Taiyo Yuden'
				WHEN 'TAS' THEN 'Tascam'
				WHEN 'TDK' THEN 'TDK'
				WHEN 'TEA' THEN 'Teac'
				WHEN 'TEC' THEN 'General'
				WHEN 'TUX' THEN 'Taiyo Yuden'
				WHEN 'VER' THEN 'Verity'
				WHEN 'VRB' THEN 'Verbatim'
				WHEN 'WIT' THEN 'Whitaker Brothers'
				WHEN 'WYN' THEN 'Wynit'
				WHEN 'XER' THEN 'Xerox'
				WHEN 'XLN' THEN 'Nexis'
				ELSE NULL
			END
		ELSE NULL
	END AS 'ManufacturerCode',
		
	NULL AS 'SpecialOrderPopupName',
	i.SERIAL AS 'SerializeLot',
	NULL AS 'CBNItemID',
	NULL AS 'IsCBN'
FROM
	[MailOrderManager].[dbo].[STOCK] i
