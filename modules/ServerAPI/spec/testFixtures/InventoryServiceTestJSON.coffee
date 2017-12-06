((exports) ->
	exports.getContainersInLocationResponse = [
		containerBarcode: "C1099920"
		containerCodeName: "CONT-6069440"
		locationCodeName: "CONT-6069436"
	,
		containerBarcode: "C1100304"
		containerCodeName: "CONT-6069443"
		locationCodeName: "CONT-6069436"
	,
		containerBarcode: "C1100488"
		containerCodeName: "CONT-6069444"
		locationCodeName: "CONT-6069436"
	]

	exports.getContainerCodesByLabelsResponseResponse = [
		codeName: "CONT-3076"
		label: "hitpicker"
	]

	exports.getContainersByLabelsResponse = [
		label: "C1100032"
		codeName: "CONT-6069441"
		container:
			codeName: "CONT-6069441"
			deleted: false
			id: 12122886
			ignored: false
			lsKind: "plate"
			lsLabels: [
				deleted: false
				id: 6060230
				ignored: false
				labelText: "C1100032"
				lsKind: "barcode"
				lsTransaction: 50
				lsType: "barcode"
				lsTypeAndKind: "barcode_barcode"
				physicallyLabled: true
				preferred: true
				recordedBy: "acas"
				recordedDate: 1456838346180
				version: 0
			]
			lsStates: [
				deleted: false
				id: 3509824
				ignored: false
				lsKind: "information"
				lsTransaction: 50
				lsType: "metadata"
				lsTypeAndKind: "metadata_information"
				lsValues: [
					codeTypeAndKind: "null_null"
					dateValue: 1279291311000
					deleted: false
					id: 14011985
					ignored: false
					lsKind: "registration date"
					lsTransaction: 50
					lsType: "dateValue"
					lsTypeAndKind: "dateValue_registration date"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					unitTypeAndKind: "null_null"
					version: 0
				,
					codeKind: "plate type"
					codeOrigin: "ACAS DDICT"
					codeType: "plate type"
					codeTypeAndKind: "plate type_plate type"
					codeValue: "screen system plate"
					deleted: false
					id: 14012385
					ignored: false
					lsKind: "plate type"
					lsTransaction: 50
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_plate type"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					unitTypeAndKind: "null_null"
					version: 0
				,
					codeTypeAndKind: "null_null"
					dateValue: 1279291311000
					deleted: false
					id: 14011984
					ignored: false
					lsKind: "created date"
					lsTransaction: 50
					lsType: "dateValue"
					lsTypeAndKind: "dateValue_created date"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					unitTypeAndKind: "null_null"
					version: 0
				,
					codeKind: "availability"
					codeType: "availability"
					codeTypeAndKind: "availability_availability"
					codeValue: "0"
					deleted: false
					id: 14012169
					ignored: false
					lsKind: "availability"
					lsTransaction: 50
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_availability"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					unitTypeAndKind: "null_null"
					version: 0
				,
					codeTypeAndKind: "null_null"
					deleted: false
					id: 14011797
					ignored: false
					lsKind: "created user"
					lsTransaction: 50
					lsType: "stringValue"
					lsTypeAndKind: "stringValue_created user"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					stringValue: "rmaldonado"
					unitTypeAndKind: "null_null"
					version: 0
				,
					codeKind: "supplier code"
					codeOrigin: "KPLATE"
					codeType: "supplier code"
					codeTypeAndKind: "supplier code_supplier code"
					codeValue: "ACD001"
					deleted: false
					id: 14012451
					ignored: false
					lsKind: "supplier code"
					lsTransaction: 50
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_supplier code"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					unitTypeAndKind: "null_null"
					version: 0
				,
					codeTypeAndKind: "null_null"
					deleted: false
					id: 14011796
					ignored: false
					lsKind: "description"
					lsTransaction: 50
					lsType: "stringValue"
					lsTypeAndKind: "stringValue_description"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					stringValue: "ACD001:AV 5UL"
					unitTypeAndKind: "null_null"
					version: 0
				,
					codeKind: "kplate id"
					codeOrigin: "KPLATE"
					codeType: "kplate id"
					codeTypeAndKind: "kplate id_kplate id"
					codeValue: "17405"
					deleted: false
					id: 14012271
					ignored: false
					lsKind: "k plate id"
					lsTransaction: 50
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_k plate id"
					operatorTypeAndKind: "null_null"
					publicData: true
					recordedBy: "acas"
					recordedDate: 1456838346180
					unitTypeAndKind: "null_null"
					version: 0
				]
				recordedBy: "acas"
				recordedDate: 1456838346180
				version: 0
			]
			lsTransaction: 50
			lsType: "container"
			lsTypeAndKind: "container_plate"
			recordedBy: "acas"
			recordedDate: 1456838346180
			version: 0
	]
	exports.getWellCodesByPlateBarcodesResponse = [
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1539"
			wellLabel: "A001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1540"
			wellLabel: "A002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1541"
			wellLabel: "A003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1542"
			wellLabel: "A004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1543"
			wellLabel: "A005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1544"
			wellLabel: "A006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1545"
			wellLabel: "A007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1546"
			wellLabel: "A008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1547"
			wellLabel: "A009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1548"
			wellLabel: "A010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1549"
			wellLabel: "A011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1550"
			wellLabel: "A012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1551"
			wellLabel: "A013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1552"
			wellLabel: "A014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1553"
			wellLabel: "A015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1554"
			wellLabel: "A016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1555"
			wellLabel: "A017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1556"
			wellLabel: "A018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1557"
			wellLabel: "A019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1558"
			wellLabel: "A020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1559"
			wellLabel: "A021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1560"
			wellLabel: "A022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1561"
			wellLabel: "A023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1562"
			wellLabel: "A024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1563"
			wellLabel: "A025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1564"
			wellLabel: "A026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1565"
			wellLabel: "A027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1566"
			wellLabel: "A028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1567"
			wellLabel: "A029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1568"
			wellLabel: "A030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1569"
			wellLabel: "A031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1570"
			wellLabel: "A032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1571"
			wellLabel: "A033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1572"
			wellLabel: "A034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1573"
			wellLabel: "A035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1574"
			wellLabel: "A036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1575"
			wellLabel: "A037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1576"
			wellLabel: "A038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1577"
			wellLabel: "A039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1578"
			wellLabel: "A040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1579"
			wellLabel: "A041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1580"
			wellLabel: "A042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1581"
			wellLabel: "A043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1582"
			wellLabel: "A044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1583"
			wellLabel: "A045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1584"
			wellLabel: "A046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1585"
			wellLabel: "A047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1586"
			wellLabel: "A048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1587"
			wellLabel: "AA001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1588"
			wellLabel: "AA002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1589"
			wellLabel: "AA003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1590"
			wellLabel: "AA004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1591"
			wellLabel: "AA005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1592"
			wellLabel: "AA006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1593"
			wellLabel: "AA007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1594"
			wellLabel: "AA008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1595"
			wellLabel: "AA009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1596"
			wellLabel: "AA010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1597"
			wellLabel: "AA011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1598"
			wellLabel: "AA012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1599"
			wellLabel: "AA013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1600"
			wellLabel: "AA014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1601"
			wellLabel: "AA015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1602"
			wellLabel: "AA016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1603"
			wellLabel: "AA017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1604"
			wellLabel: "AA018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1605"
			wellLabel: "AA019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1606"
			wellLabel: "AA020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1607"
			wellLabel: "AA021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1608"
			wellLabel: "AA022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1609"
			wellLabel: "AA023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1610"
			wellLabel: "AA024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1611"
			wellLabel: "AA025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1612"
			wellLabel: "AA026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1613"
			wellLabel: "AA027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1614"
			wellLabel: "AA028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1615"
			wellLabel: "AA029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1616"
			wellLabel: "AA030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1617"
			wellLabel: "AA031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1618"
			wellLabel: "AA032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1619"
			wellLabel: "AA033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1620"
			wellLabel: "AA034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1621"
			wellLabel: "AA035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1622"
			wellLabel: "AA036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1623"
			wellLabel: "AA037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1624"
			wellLabel: "AA038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1625"
			wellLabel: "AA039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1626"
			wellLabel: "AA040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1627"
			wellLabel: "AA041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1628"
			wellLabel: "AA042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1629"
			wellLabel: "AA043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1630"
			wellLabel: "AA044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1631"
			wellLabel: "AA045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1632"
			wellLabel: "AA046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1633"
			wellLabel: "AA047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1634"
			wellLabel: "AA048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1635"
			wellLabel: "AB001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1636"
			wellLabel: "AB002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1637"
			wellLabel: "AB003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1638"
			wellLabel: "AB004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1639"
			wellLabel: "AB005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1640"
			wellLabel: "AB006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1641"
			wellLabel: "AB007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1642"
			wellLabel: "AB008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1643"
			wellLabel: "AB009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1644"
			wellLabel: "AB010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1645"
			wellLabel: "AB011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1646"
			wellLabel: "AB012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1647"
			wellLabel: "AB013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1648"
			wellLabel: "AB014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1649"
			wellLabel: "AB015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1650"
			wellLabel: "AB016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1651"
			wellLabel: "AB017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1652"
			wellLabel: "AB018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1653"
			wellLabel: "AB019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1654"
			wellLabel: "AB020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1655"
			wellLabel: "AB021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1656"
			wellLabel: "AB022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1657"
			wellLabel: "AB023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1658"
			wellLabel: "AB024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1659"
			wellLabel: "AB025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1660"
			wellLabel: "AB026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1661"
			wellLabel: "AB027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1662"
			wellLabel: "AB028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1663"
			wellLabel: "AB029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1664"
			wellLabel: "AB030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1665"
			wellLabel: "AB031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1666"
			wellLabel: "AB032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1667"
			wellLabel: "AB033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1668"
			wellLabel: "AB034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1669"
			wellLabel: "AB035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1670"
			wellLabel: "AB036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1671"
			wellLabel: "AB037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1672"
			wellLabel: "AB038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1673"
			wellLabel: "AB039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1674"
			wellLabel: "AB040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1675"
			wellLabel: "AB041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1676"
			wellLabel: "AB042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1677"
			wellLabel: "AB043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1678"
			wellLabel: "AB044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1679"
			wellLabel: "AB045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1680"
			wellLabel: "AB046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1681"
			wellLabel: "AB047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1682"
			wellLabel: "AB048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1683"
			wellLabel: "AC001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1684"
			wellLabel: "AC002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1685"
			wellLabel: "AC003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1686"
			wellLabel: "AC004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1687"
			wellLabel: "AC005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1688"
			wellLabel: "AC006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1689"
			wellLabel: "AC007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1690"
			wellLabel: "AC008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1691"
			wellLabel: "AC009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1692"
			wellLabel: "AC010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1693"
			wellLabel: "AC011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1694"
			wellLabel: "AC012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1695"
			wellLabel: "AC013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1696"
			wellLabel: "AC014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1697"
			wellLabel: "AC015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1698"
			wellLabel: "AC016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1699"
			wellLabel: "AC017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1700"
			wellLabel: "AC018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1701"
			wellLabel: "AC019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1702"
			wellLabel: "AC020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1703"
			wellLabel: "AC021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1704"
			wellLabel: "AC022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1705"
			wellLabel: "AC023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1706"
			wellLabel: "AC024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1707"
			wellLabel: "AC025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1708"
			wellLabel: "AC026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1709"
			wellLabel: "AC027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1710"
			wellLabel: "AC028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1711"
			wellLabel: "AC029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1712"
			wellLabel: "AC030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1713"
			wellLabel: "AC031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1714"
			wellLabel: "AC032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1715"
			wellLabel: "AC033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1716"
			wellLabel: "AC034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1717"
			wellLabel: "AC035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1718"
			wellLabel: "AC036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1719"
			wellLabel: "AC037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1720"
			wellLabel: "AC038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1721"
			wellLabel: "AC039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1722"
			wellLabel: "AC040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1723"
			wellLabel: "AC041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1724"
			wellLabel: "AC042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1725"
			wellLabel: "AC043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1726"
			wellLabel: "AC044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1727"
			wellLabel: "AC045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1728"
			wellLabel: "AC046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1729"
			wellLabel: "AC047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1730"
			wellLabel: "AC048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1731"
			wellLabel: "AD001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1732"
			wellLabel: "AD002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1733"
			wellLabel: "AD003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1734"
			wellLabel: "AD004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1735"
			wellLabel: "AD005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1736"
			wellLabel: "AD006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1737"
			wellLabel: "AD007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1738"
			wellLabel: "AD008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1739"
			wellLabel: "AD009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1740"
			wellLabel: "AD010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1741"
			wellLabel: "AD011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1742"
			wellLabel: "AD012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1743"
			wellLabel: "AD013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1744"
			wellLabel: "AD014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1745"
			wellLabel: "AD015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1746"
			wellLabel: "AD016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1747"
			wellLabel: "AD017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1748"
			wellLabel: "AD018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1749"
			wellLabel: "AD019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1750"
			wellLabel: "AD020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1751"
			wellLabel: "AD021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1752"
			wellLabel: "AD022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1753"
			wellLabel: "AD023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1754"
			wellLabel: "AD024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1755"
			wellLabel: "AD025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1756"
			wellLabel: "AD026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1757"
			wellLabel: "AD027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1758"
			wellLabel: "AD028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1759"
			wellLabel: "AD029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1760"
			wellLabel: "AD030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1761"
			wellLabel: "AD031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1762"
			wellLabel: "AD032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1763"
			wellLabel: "AD033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1764"
			wellLabel: "AD034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1765"
			wellLabel: "AD035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1766"
			wellLabel: "AD036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1767"
			wellLabel: "AD037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1768"
			wellLabel: "AD038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1769"
			wellLabel: "AD039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1770"
			wellLabel: "AD040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1771"
			wellLabel: "AD041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1772"
			wellLabel: "AD042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1773"
			wellLabel: "AD043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1774"
			wellLabel: "AD044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1775"
			wellLabel: "AD045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1776"
			wellLabel: "AD046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1777"
			wellLabel: "AD047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1778"
			wellLabel: "AD048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1779"
			wellLabel: "AE001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1780"
			wellLabel: "AE002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1781"
			wellLabel: "AE003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1782"
			wellLabel: "AE004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1783"
			wellLabel: "AE005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1784"
			wellLabel: "AE006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1785"
			wellLabel: "AE007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1786"
			wellLabel: "AE008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1787"
			wellLabel: "AE009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1788"
			wellLabel: "AE010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1789"
			wellLabel: "AE011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1790"
			wellLabel: "AE012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1791"
			wellLabel: "AE013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1792"
			wellLabel: "AE014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1793"
			wellLabel: "AE015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1794"
			wellLabel: "AE016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1795"
			wellLabel: "AE017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1796"
			wellLabel: "AE018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1797"
			wellLabel: "AE019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1798"
			wellLabel: "AE020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1799"
			wellLabel: "AE021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1800"
			wellLabel: "AE022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1801"
			wellLabel: "AE023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1802"
			wellLabel: "AE024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1803"
			wellLabel: "AE025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1804"
			wellLabel: "AE026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1805"
			wellLabel: "AE027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1806"
			wellLabel: "AE028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1807"
			wellLabel: "AE029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1808"
			wellLabel: "AE030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1809"
			wellLabel: "AE031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1810"
			wellLabel: "AE032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1811"
			wellLabel: "AE033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1812"
			wellLabel: "AE034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1813"
			wellLabel: "AE035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1814"
			wellLabel: "AE036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1815"
			wellLabel: "AE037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1816"
			wellLabel: "AE038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1817"
			wellLabel: "AE039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1818"
			wellLabel: "AE040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1819"
			wellLabel: "AE041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1820"
			wellLabel: "AE042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1821"
			wellLabel: "AE043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1822"
			wellLabel: "AE044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1823"
			wellLabel: "AE045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1824"
			wellLabel: "AE046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1825"
			wellLabel: "AE047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1826"
			wellLabel: "AE048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1827"
			wellLabel: "AF001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1828"
			wellLabel: "AF002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1829"
			wellLabel: "AF003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1830"
			wellLabel: "AF004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1831"
			wellLabel: "AF005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1832"
			wellLabel: "AF006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1833"
			wellLabel: "AF007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1834"
			wellLabel: "AF008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1835"
			wellLabel: "AF009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1836"
			wellLabel: "AF010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1837"
			wellLabel: "AF011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1838"
			wellLabel: "AF012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1839"
			wellLabel: "AF013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1840"
			wellLabel: "AF014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1841"
			wellLabel: "AF015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1842"
			wellLabel: "AF016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1843"
			wellLabel: "AF017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1844"
			wellLabel: "AF018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1845"
			wellLabel: "AF019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1846"
			wellLabel: "AF020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1847"
			wellLabel: "AF021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1848"
			wellLabel: "AF022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1849"
			wellLabel: "AF023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1850"
			wellLabel: "AF024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1851"
			wellLabel: "AF025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1852"
			wellLabel: "AF026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1853"
			wellLabel: "AF027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1854"
			wellLabel: "AF028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1855"
			wellLabel: "AF029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1856"
			wellLabel: "AF030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1857"
			wellLabel: "AF031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1858"
			wellLabel: "AF032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1859"
			wellLabel: "AF033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1860"
			wellLabel: "AF034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1861"
			wellLabel: "AF035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1862"
			wellLabel: "AF036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1863"
			wellLabel: "AF037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1864"
			wellLabel: "AF038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1865"
			wellLabel: "AF039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1866"
			wellLabel: "AF040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1867"
			wellLabel: "AF041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1868"
			wellLabel: "AF042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1869"
			wellLabel: "AF043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1870"
			wellLabel: "AF044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1871"
			wellLabel: "AF045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1872"
			wellLabel: "AF046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1873"
			wellLabel: "AF047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1874"
			wellLabel: "AF048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1875"
			wellLabel: "B001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1876"
			wellLabel: "B002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1877"
			wellLabel: "B003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1878"
			wellLabel: "B004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1879"
			wellLabel: "B005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1880"
			wellLabel: "B006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1881"
			wellLabel: "B007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1882"
			wellLabel: "B008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1883"
			wellLabel: "B009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1884"
			wellLabel: "B010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1885"
			wellLabel: "B011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1886"
			wellLabel: "B012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1887"
			wellLabel: "B013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1888"
			wellLabel: "B014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1889"
			wellLabel: "B015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1890"
			wellLabel: "B016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1891"
			wellLabel: "B017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1892"
			wellLabel: "B018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1893"
			wellLabel: "B019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1894"
			wellLabel: "B020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1895"
			wellLabel: "B021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1896"
			wellLabel: "B022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1897"
			wellLabel: "B023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1898"
			wellLabel: "B024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1899"
			wellLabel: "B025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1900"
			wellLabel: "B026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1901"
			wellLabel: "B027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1902"
			wellLabel: "B028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1903"
			wellLabel: "B029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1904"
			wellLabel: "B030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1905"
			wellLabel: "B031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1906"
			wellLabel: "B032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1907"
			wellLabel: "B033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1908"
			wellLabel: "B034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1909"
			wellLabel: "B035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1910"
			wellLabel: "B036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1911"
			wellLabel: "B037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1912"
			wellLabel: "B038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1913"
			wellLabel: "B039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1914"
			wellLabel: "B040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1915"
			wellLabel: "B041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1916"
			wellLabel: "B042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1917"
			wellLabel: "B043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1918"
			wellLabel: "B044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1919"
			wellLabel: "B045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1920"
			wellLabel: "B046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1921"
			wellLabel: "B047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1922"
			wellLabel: "B048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1923"
			wellLabel: "C001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1924"
			wellLabel: "C002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1925"
			wellLabel: "C003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1926"
			wellLabel: "C004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1927"
			wellLabel: "C005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1928"
			wellLabel: "C006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1929"
			wellLabel: "C007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1930"
			wellLabel: "C008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1931"
			wellLabel: "C009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1932"
			wellLabel: "C010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1933"
			wellLabel: "C011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1934"
			wellLabel: "C012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1935"
			wellLabel: "C013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1936"
			wellLabel: "C014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1937"
			wellLabel: "C015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1938"
			wellLabel: "C016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1939"
			wellLabel: "C017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1940"
			wellLabel: "C018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1941"
			wellLabel: "C019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1942"
			wellLabel: "C020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1943"
			wellLabel: "C021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1944"
			wellLabel: "C022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1945"
			wellLabel: "C023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1946"
			wellLabel: "C024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1947"
			wellLabel: "C025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1948"
			wellLabel: "C026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1949"
			wellLabel: "C027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1950"
			wellLabel: "C028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1951"
			wellLabel: "C029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1952"
			wellLabel: "C030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1953"
			wellLabel: "C031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1954"
			wellLabel: "C032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1955"
			wellLabel: "C033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1956"
			wellLabel: "C034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1957"
			wellLabel: "C035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1958"
			wellLabel: "C036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1959"
			wellLabel: "C037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1960"
			wellLabel: "C038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1961"
			wellLabel: "C039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1962"
			wellLabel: "C040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1963"
			wellLabel: "C041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1964"
			wellLabel: "C042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1965"
			wellLabel: "C043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1966"
			wellLabel: "C044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1967"
			wellLabel: "C045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1968"
			wellLabel: "C046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1969"
			wellLabel: "C047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1970"
			wellLabel: "C048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1971"
			wellLabel: "D001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1972"
			wellLabel: "D002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1973"
			wellLabel: "D003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1974"
			wellLabel: "D004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1975"
			wellLabel: "D005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1976"
			wellLabel: "D006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1977"
			wellLabel: "D007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1978"
			wellLabel: "D008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1979"
			wellLabel: "D009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1980"
			wellLabel: "D010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1981"
			wellLabel: "D011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1982"
			wellLabel: "D012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1983"
			wellLabel: "D013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1984"
			wellLabel: "D014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1985"
			wellLabel: "D015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1986"
			wellLabel: "D016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1987"
			wellLabel: "D017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1988"
			wellLabel: "D018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1989"
			wellLabel: "D019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1990"
			wellLabel: "D020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1991"
			wellLabel: "D021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1992"
			wellLabel: "D022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1993"
			wellLabel: "D023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1994"
			wellLabel: "D024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1995"
			wellLabel: "D025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1996"
			wellLabel: "D026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1997"
			wellLabel: "D027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1998"
			wellLabel: "D028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-1999"
			wellLabel: "D029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2000"
			wellLabel: "D030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2001"
			wellLabel: "D031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2002"
			wellLabel: "D032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2003"
			wellLabel: "D033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2004"
			wellLabel: "D034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2005"
			wellLabel: "D035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2006"
			wellLabel: "D036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2007"
			wellLabel: "D037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2008"
			wellLabel: "D038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2009"
			wellLabel: "D039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2010"
			wellLabel: "D040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2011"
			wellLabel: "D041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2012"
			wellLabel: "D042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2013"
			wellLabel: "D043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2014"
			wellLabel: "D044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2015"
			wellLabel: "D045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2016"
			wellLabel: "D046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2017"
			wellLabel: "D047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2018"
			wellLabel: "D048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2019"
			wellLabel: "E001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2020"
			wellLabel: "E002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2021"
			wellLabel: "E003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2022"
			wellLabel: "E004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2023"
			wellLabel: "E005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2024"
			wellLabel: "E006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2025"
			wellLabel: "E007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2026"
			wellLabel: "E008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2027"
			wellLabel: "E009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2028"
			wellLabel: "E010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2029"
			wellLabel: "E011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2030"
			wellLabel: "E012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2031"
			wellLabel: "E013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2032"
			wellLabel: "E014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2033"
			wellLabel: "E015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2034"
			wellLabel: "E016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2035"
			wellLabel: "E017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2036"
			wellLabel: "E018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2037"
			wellLabel: "E019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2038"
			wellLabel: "E020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2039"
			wellLabel: "E021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2040"
			wellLabel: "E022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2041"
			wellLabel: "E023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2042"
			wellLabel: "E024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2043"
			wellLabel: "E025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2044"
			wellLabel: "E026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2045"
			wellLabel: "E027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2046"
			wellLabel: "E028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2047"
			wellLabel: "E029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2048"
			wellLabel: "E030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2049"
			wellLabel: "E031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2050"
			wellLabel: "E032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2051"
			wellLabel: "E033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2052"
			wellLabel: "E034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2053"
			wellLabel: "E035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2054"
			wellLabel: "E036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2055"
			wellLabel: "E037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2056"
			wellLabel: "E038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2057"
			wellLabel: "E039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2058"
			wellLabel: "E040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2059"
			wellLabel: "E041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2060"
			wellLabel: "E042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2061"
			wellLabel: "E043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2062"
			wellLabel: "E044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2063"
			wellLabel: "E045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2064"
			wellLabel: "E046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2065"
			wellLabel: "E047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2066"
			wellLabel: "E048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2067"
			wellLabel: "F001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2068"
			wellLabel: "F002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2069"
			wellLabel: "F003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2070"
			wellLabel: "F004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2071"
			wellLabel: "F005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2072"
			wellLabel: "F006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2073"
			wellLabel: "F007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2074"
			wellLabel: "F008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2075"
			wellLabel: "F009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2076"
			wellLabel: "F010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2077"
			wellLabel: "F011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2078"
			wellLabel: "F012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2079"
			wellLabel: "F013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2080"
			wellLabel: "F014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2081"
			wellLabel: "F015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2082"
			wellLabel: "F016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2083"
			wellLabel: "F017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2084"
			wellLabel: "F018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2085"
			wellLabel: "F019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2086"
			wellLabel: "F020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2087"
			wellLabel: "F021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2088"
			wellLabel: "F022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2089"
			wellLabel: "F023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2090"
			wellLabel: "F024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2091"
			wellLabel: "F025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2092"
			wellLabel: "F026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2093"
			wellLabel: "F027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2094"
			wellLabel: "F028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2095"
			wellLabel: "F029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2096"
			wellLabel: "F030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2097"
			wellLabel: "F031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2098"
			wellLabel: "F032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2099"
			wellLabel: "F033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2100"
			wellLabel: "F034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2101"
			wellLabel: "F035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2102"
			wellLabel: "F036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2103"
			wellLabel: "F037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2104"
			wellLabel: "F038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2105"
			wellLabel: "F039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2106"
			wellLabel: "F040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2107"
			wellLabel: "F041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2108"
			wellLabel: "F042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2109"
			wellLabel: "F043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2110"
			wellLabel: "F044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2111"
			wellLabel: "F045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2112"
			wellLabel: "F046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2113"
			wellLabel: "F047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2114"
			wellLabel: "F048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2115"
			wellLabel: "G001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2116"
			wellLabel: "G002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2117"
			wellLabel: "G003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2118"
			wellLabel: "G004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2119"
			wellLabel: "G005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2120"
			wellLabel: "G006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2121"
			wellLabel: "G007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2122"
			wellLabel: "G008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2123"
			wellLabel: "G009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2124"
			wellLabel: "G010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2125"
			wellLabel: "G011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2126"
			wellLabel: "G012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2127"
			wellLabel: "G013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2128"
			wellLabel: "G014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2129"
			wellLabel: "G015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2130"
			wellLabel: "G016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2131"
			wellLabel: "G017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2132"
			wellLabel: "G018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2133"
			wellLabel: "G019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2134"
			wellLabel: "G020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2135"
			wellLabel: "G021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2136"
			wellLabel: "G022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2137"
			wellLabel: "G023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2138"
			wellLabel: "G024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2139"
			wellLabel: "G025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2140"
			wellLabel: "G026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2141"
			wellLabel: "G027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2142"
			wellLabel: "G028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2143"
			wellLabel: "G029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2144"
			wellLabel: "G030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2145"
			wellLabel: "G031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2146"
			wellLabel: "G032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2147"
			wellLabel: "G033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2148"
			wellLabel: "G034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2149"
			wellLabel: "G035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2150"
			wellLabel: "G036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2151"
			wellLabel: "G037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2152"
			wellLabel: "G038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2153"
			wellLabel: "G039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2154"
			wellLabel: "G040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2155"
			wellLabel: "G041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2156"
			wellLabel: "G042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2157"
			wellLabel: "G043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2158"
			wellLabel: "G044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2159"
			wellLabel: "G045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2160"
			wellLabel: "G046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2161"
			wellLabel: "G047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2162"
			wellLabel: "G048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2163"
			wellLabel: "H001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2164"
			wellLabel: "H002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2165"
			wellLabel: "H003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2166"
			wellLabel: "H004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2167"
			wellLabel: "H005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2168"
			wellLabel: "H006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2169"
			wellLabel: "H007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2170"
			wellLabel: "H008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2171"
			wellLabel: "H009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2172"
			wellLabel: "H010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2173"
			wellLabel: "H011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2174"
			wellLabel: "H012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2175"
			wellLabel: "H013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2176"
			wellLabel: "H014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2177"
			wellLabel: "H015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2178"
			wellLabel: "H016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2179"
			wellLabel: "H017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2180"
			wellLabel: "H018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2181"
			wellLabel: "H019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2182"
			wellLabel: "H020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2183"
			wellLabel: "H021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2184"
			wellLabel: "H022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2185"
			wellLabel: "H023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2186"
			wellLabel: "H024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2187"
			wellLabel: "H025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2188"
			wellLabel: "H026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2189"
			wellLabel: "H027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2190"
			wellLabel: "H028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2191"
			wellLabel: "H029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2192"
			wellLabel: "H030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2193"
			wellLabel: "H031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2194"
			wellLabel: "H032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2195"
			wellLabel: "H033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2196"
			wellLabel: "H034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2197"
			wellLabel: "H035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2198"
			wellLabel: "H036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2199"
			wellLabel: "H037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2200"
			wellLabel: "H038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2201"
			wellLabel: "H039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2202"
			wellLabel: "H040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2203"
			wellLabel: "H041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2204"
			wellLabel: "H042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2205"
			wellLabel: "H043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2206"
			wellLabel: "H044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2207"
			wellLabel: "H045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2208"
			wellLabel: "H046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2209"
			wellLabel: "H047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2210"
			wellLabel: "H048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2211"
			wellLabel: "I001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2212"
			wellLabel: "I002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2213"
			wellLabel: "I003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2214"
			wellLabel: "I004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2215"
			wellLabel: "I005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2216"
			wellLabel: "I006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2217"
			wellLabel: "I007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2218"
			wellLabel: "I008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2219"
			wellLabel: "I009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2220"
			wellLabel: "I010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2221"
			wellLabel: "I011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2222"
			wellLabel: "I012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2223"
			wellLabel: "I013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2224"
			wellLabel: "I014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2225"
			wellLabel: "I015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2226"
			wellLabel: "I016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2227"
			wellLabel: "I017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2228"
			wellLabel: "I018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2229"
			wellLabel: "I019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2230"
			wellLabel: "I020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2231"
			wellLabel: "I021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2232"
			wellLabel: "I022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2233"
			wellLabel: "I023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2234"
			wellLabel: "I024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2235"
			wellLabel: "I025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2236"
			wellLabel: "I026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2237"
			wellLabel: "I027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2238"
			wellLabel: "I028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2239"
			wellLabel: "I029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2240"
			wellLabel: "I030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2241"
			wellLabel: "I031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2242"
			wellLabel: "I032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2243"
			wellLabel: "I033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2244"
			wellLabel: "I034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2245"
			wellLabel: "I035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2246"
			wellLabel: "I036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2247"
			wellLabel: "I037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2248"
			wellLabel: "I038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2249"
			wellLabel: "I039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2250"
			wellLabel: "I040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2251"
			wellLabel: "I041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2252"
			wellLabel: "I042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2253"
			wellLabel: "I043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2254"
			wellLabel: "I044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2255"
			wellLabel: "I045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2256"
			wellLabel: "I046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2257"
			wellLabel: "I047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2258"
			wellLabel: "I048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2259"
			wellLabel: "J001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2260"
			wellLabel: "J002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2261"
			wellLabel: "J003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2262"
			wellLabel: "J004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2263"
			wellLabel: "J005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2264"
			wellLabel: "J006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2265"
			wellLabel: "J007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2266"
			wellLabel: "J008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2267"
			wellLabel: "J009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2268"
			wellLabel: "J010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2269"
			wellLabel: "J011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2270"
			wellLabel: "J012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2271"
			wellLabel: "J013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2272"
			wellLabel: "J014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2273"
			wellLabel: "J015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2274"
			wellLabel: "J016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2275"
			wellLabel: "J017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2276"
			wellLabel: "J018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2277"
			wellLabel: "J019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2278"
			wellLabel: "J020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2279"
			wellLabel: "J021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2280"
			wellLabel: "J022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2281"
			wellLabel: "J023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2282"
			wellLabel: "J024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2283"
			wellLabel: "J025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2284"
			wellLabel: "J026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2285"
			wellLabel: "J027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2286"
			wellLabel: "J028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2287"
			wellLabel: "J029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2288"
			wellLabel: "J030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2289"
			wellLabel: "J031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2290"
			wellLabel: "J032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2291"
			wellLabel: "J033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2292"
			wellLabel: "J034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2293"
			wellLabel: "J035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2294"
			wellLabel: "J036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2295"
			wellLabel: "J037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2296"
			wellLabel: "J038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2297"
			wellLabel: "J039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2298"
			wellLabel: "J040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2299"
			wellLabel: "J041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2300"
			wellLabel: "J042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2301"
			wellLabel: "J043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2302"
			wellLabel: "J044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2303"
			wellLabel: "J045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2304"
			wellLabel: "J046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2305"
			wellLabel: "J047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2306"
			wellLabel: "J048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2307"
			wellLabel: "K001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2308"
			wellLabel: "K002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2309"
			wellLabel: "K003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2310"
			wellLabel: "K004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2311"
			wellLabel: "K005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2312"
			wellLabel: "K006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2313"
			wellLabel: "K007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2314"
			wellLabel: "K008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2315"
			wellLabel: "K009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2316"
			wellLabel: "K010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2317"
			wellLabel: "K011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2318"
			wellLabel: "K012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2319"
			wellLabel: "K013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2320"
			wellLabel: "K014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2321"
			wellLabel: "K015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2322"
			wellLabel: "K016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2323"
			wellLabel: "K017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2324"
			wellLabel: "K018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2325"
			wellLabel: "K019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2326"
			wellLabel: "K020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2327"
			wellLabel: "K021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2328"
			wellLabel: "K022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2329"
			wellLabel: "K023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2330"
			wellLabel: "K024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2331"
			wellLabel: "K025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2332"
			wellLabel: "K026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2333"
			wellLabel: "K027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2334"
			wellLabel: "K028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2335"
			wellLabel: "K029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2336"
			wellLabel: "K030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2337"
			wellLabel: "K031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2338"
			wellLabel: "K032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2339"
			wellLabel: "K033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2340"
			wellLabel: "K034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2341"
			wellLabel: "K035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2342"
			wellLabel: "K036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2343"
			wellLabel: "K037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2344"
			wellLabel: "K038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2345"
			wellLabel: "K039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2346"
			wellLabel: "K040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2347"
			wellLabel: "K041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2348"
			wellLabel: "K042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2349"
			wellLabel: "K043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2350"
			wellLabel: "K044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2351"
			wellLabel: "K045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2352"
			wellLabel: "K046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2353"
			wellLabel: "K047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2354"
			wellLabel: "K048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2355"
			wellLabel: "L001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2356"
			wellLabel: "L002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2357"
			wellLabel: "L003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2358"
			wellLabel: "L004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2359"
			wellLabel: "L005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2360"
			wellLabel: "L006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2361"
			wellLabel: "L007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2362"
			wellLabel: "L008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2363"
			wellLabel: "L009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2364"
			wellLabel: "L010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2365"
			wellLabel: "L011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2366"
			wellLabel: "L012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2367"
			wellLabel: "L013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2368"
			wellLabel: "L014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2369"
			wellLabel: "L015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2370"
			wellLabel: "L016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2371"
			wellLabel: "L017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2372"
			wellLabel: "L018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2373"
			wellLabel: "L019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2374"
			wellLabel: "L020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2375"
			wellLabel: "L021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2376"
			wellLabel: "L022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2377"
			wellLabel: "L023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2378"
			wellLabel: "L024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2379"
			wellLabel: "L025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2380"
			wellLabel: "L026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2381"
			wellLabel: "L027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2382"
			wellLabel: "L028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2383"
			wellLabel: "L029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2384"
			wellLabel: "L030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2385"
			wellLabel: "L031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2386"
			wellLabel: "L032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2387"
			wellLabel: "L033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2388"
			wellLabel: "L034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2389"
			wellLabel: "L035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2390"
			wellLabel: "L036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2391"
			wellLabel: "L037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2392"
			wellLabel: "L038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2393"
			wellLabel: "L039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2394"
			wellLabel: "L040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2395"
			wellLabel: "L041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2396"
			wellLabel: "L042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2397"
			wellLabel: "L043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2398"
			wellLabel: "L044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2399"
			wellLabel: "L045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2400"
			wellLabel: "L046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2401"
			wellLabel: "L047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2402"
			wellLabel: "L048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2403"
			wellLabel: "M001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2404"
			wellLabel: "M002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2405"
			wellLabel: "M003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2406"
			wellLabel: "M004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2407"
			wellLabel: "M005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2408"
			wellLabel: "M006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2409"
			wellLabel: "M007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2410"
			wellLabel: "M008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2411"
			wellLabel: "M009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2412"
			wellLabel: "M010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2413"
			wellLabel: "M011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2414"
			wellLabel: "M012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2415"
			wellLabel: "M013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2416"
			wellLabel: "M014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2417"
			wellLabel: "M015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2418"
			wellLabel: "M016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2419"
			wellLabel: "M017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2420"
			wellLabel: "M018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2421"
			wellLabel: "M019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2422"
			wellLabel: "M020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2423"
			wellLabel: "M021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2424"
			wellLabel: "M022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2425"
			wellLabel: "M023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2426"
			wellLabel: "M024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2427"
			wellLabel: "M025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2428"
			wellLabel: "M026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2429"
			wellLabel: "M027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2430"
			wellLabel: "M028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2431"
			wellLabel: "M029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2432"
			wellLabel: "M030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2433"
			wellLabel: "M031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2434"
			wellLabel: "M032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2435"
			wellLabel: "M033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2436"
			wellLabel: "M034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2437"
			wellLabel: "M035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2438"
			wellLabel: "M036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2439"
			wellLabel: "M037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2440"
			wellLabel: "M038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2441"
			wellLabel: "M039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2442"
			wellLabel: "M040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2443"
			wellLabel: "M041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2444"
			wellLabel: "M042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2445"
			wellLabel: "M043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2446"
			wellLabel: "M044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2447"
			wellLabel: "M045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2448"
			wellLabel: "M046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2449"
			wellLabel: "M047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2450"
			wellLabel: "M048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2451"
			wellLabel: "N001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2452"
			wellLabel: "N002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2453"
			wellLabel: "N003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2454"
			wellLabel: "N004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2455"
			wellLabel: "N005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2456"
			wellLabel: "N006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2457"
			wellLabel: "N007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2458"
			wellLabel: "N008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2459"
			wellLabel: "N009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2460"
			wellLabel: "N010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2461"
			wellLabel: "N011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2462"
			wellLabel: "N012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2463"
			wellLabel: "N013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2464"
			wellLabel: "N014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2465"
			wellLabel: "N015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2466"
			wellLabel: "N016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2467"
			wellLabel: "N017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2468"
			wellLabel: "N018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2469"
			wellLabel: "N019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2470"
			wellLabel: "N020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2471"
			wellLabel: "N021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2472"
			wellLabel: "N022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2473"
			wellLabel: "N023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2474"
			wellLabel: "N024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2475"
			wellLabel: "N025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2476"
			wellLabel: "N026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2477"
			wellLabel: "N027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2478"
			wellLabel: "N028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2479"
			wellLabel: "N029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2480"
			wellLabel: "N030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2481"
			wellLabel: "N031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2482"
			wellLabel: "N032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2483"
			wellLabel: "N033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2484"
			wellLabel: "N034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2485"
			wellLabel: "N035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2486"
			wellLabel: "N036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2487"
			wellLabel: "N037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2488"
			wellLabel: "N038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2489"
			wellLabel: "N039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2490"
			wellLabel: "N040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2491"
			wellLabel: "N041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2492"
			wellLabel: "N042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2493"
			wellLabel: "N043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2494"
			wellLabel: "N044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2495"
			wellLabel: "N045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2496"
			wellLabel: "N046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2497"
			wellLabel: "N047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2498"
			wellLabel: "N048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2499"
			wellLabel: "O001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2500"
			wellLabel: "O002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2501"
			wellLabel: "O003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2502"
			wellLabel: "O004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2503"
			wellLabel: "O005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2504"
			wellLabel: "O006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2505"
			wellLabel: "O007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2506"
			wellLabel: "O008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2507"
			wellLabel: "O009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2508"
			wellLabel: "O010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2509"
			wellLabel: "O011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2510"
			wellLabel: "O012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2511"
			wellLabel: "O013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2512"
			wellLabel: "O014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2513"
			wellLabel: "O015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2514"
			wellLabel: "O016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2515"
			wellLabel: "O017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2516"
			wellLabel: "O018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2517"
			wellLabel: "O019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2518"
			wellLabel: "O020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2519"
			wellLabel: "O021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2520"
			wellLabel: "O022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2521"
			wellLabel: "O023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2522"
			wellLabel: "O024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2523"
			wellLabel: "O025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2524"
			wellLabel: "O026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2525"
			wellLabel: "O027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2526"
			wellLabel: "O028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2527"
			wellLabel: "O029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2528"
			wellLabel: "O030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2529"
			wellLabel: "O031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2530"
			wellLabel: "O032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2531"
			wellLabel: "O033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2532"
			wellLabel: "O034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2533"
			wellLabel: "O035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2534"
			wellLabel: "O036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2535"
			wellLabel: "O037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2536"
			wellLabel: "O038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2537"
			wellLabel: "O039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2538"
			wellLabel: "O040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2539"
			wellLabel: "O041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2540"
			wellLabel: "O042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2541"
			wellLabel: "O043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2542"
			wellLabel: "O044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2543"
			wellLabel: "O045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2544"
			wellLabel: "O046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2545"
			wellLabel: "O047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2546"
			wellLabel: "O048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2547"
			wellLabel: "P001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2548"
			wellLabel: "P002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2549"
			wellLabel: "P003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2550"
			wellLabel: "P004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2551"
			wellLabel: "P005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2552"
			wellLabel: "P006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2553"
			wellLabel: "P007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2554"
			wellLabel: "P008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2555"
			wellLabel: "P009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2556"
			wellLabel: "P010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2557"
			wellLabel: "P011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2558"
			wellLabel: "P012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2559"
			wellLabel: "P013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2560"
			wellLabel: "P014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2561"
			wellLabel: "P015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2562"
			wellLabel: "P016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2563"
			wellLabel: "P017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2564"
			wellLabel: "P018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2565"
			wellLabel: "P019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2566"
			wellLabel: "P020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2567"
			wellLabel: "P021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2568"
			wellLabel: "P022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2569"
			wellLabel: "P023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2570"
			wellLabel: "P024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2571"
			wellLabel: "P025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2572"
			wellLabel: "P026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2573"
			wellLabel: "P027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2574"
			wellLabel: "P028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2575"
			wellLabel: "P029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2576"
			wellLabel: "P030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2577"
			wellLabel: "P031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2578"
			wellLabel: "P032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2579"
			wellLabel: "P033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2580"
			wellLabel: "P034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2581"
			wellLabel: "P035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2582"
			wellLabel: "P036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2583"
			wellLabel: "P037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2584"
			wellLabel: "P038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2585"
			wellLabel: "P039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2586"
			wellLabel: "P040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2587"
			wellLabel: "P041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2588"
			wellLabel: "P042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2589"
			wellLabel: "P043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2590"
			wellLabel: "P044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2591"
			wellLabel: "P045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2592"
			wellLabel: "P046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2593"
			wellLabel: "P047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2594"
			wellLabel: "P048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2595"
			wellLabel: "Q001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2596"
			wellLabel: "Q002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2597"
			wellLabel: "Q003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2598"
			wellLabel: "Q004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2599"
			wellLabel: "Q005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2600"
			wellLabel: "Q006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2601"
			wellLabel: "Q007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2602"
			wellLabel: "Q008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2603"
			wellLabel: "Q009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2604"
			wellLabel: "Q010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2605"
			wellLabel: "Q011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2606"
			wellLabel: "Q012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2607"
			wellLabel: "Q013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2608"
			wellLabel: "Q014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2609"
			wellLabel: "Q015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2610"
			wellLabel: "Q016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2611"
			wellLabel: "Q017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2612"
			wellLabel: "Q018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2613"
			wellLabel: "Q019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2614"
			wellLabel: "Q020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2615"
			wellLabel: "Q021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2616"
			wellLabel: "Q022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2617"
			wellLabel: "Q023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2618"
			wellLabel: "Q024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2619"
			wellLabel: "Q025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2620"
			wellLabel: "Q026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2621"
			wellLabel: "Q027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2622"
			wellLabel: "Q028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2623"
			wellLabel: "Q029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2624"
			wellLabel: "Q030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2625"
			wellLabel: "Q031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2626"
			wellLabel: "Q032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2627"
			wellLabel: "Q033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2628"
			wellLabel: "Q034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2629"
			wellLabel: "Q035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2630"
			wellLabel: "Q036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2631"
			wellLabel: "Q037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2632"
			wellLabel: "Q038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2633"
			wellLabel: "Q039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2634"
			wellLabel: "Q040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2635"
			wellLabel: "Q041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2636"
			wellLabel: "Q042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2637"
			wellLabel: "Q043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2638"
			wellLabel: "Q044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2639"
			wellLabel: "Q045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2640"
			wellLabel: "Q046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2641"
			wellLabel: "Q047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2642"
			wellLabel: "Q048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2643"
			wellLabel: "R001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2644"
			wellLabel: "R002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2645"
			wellLabel: "R003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2646"
			wellLabel: "R004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2647"
			wellLabel: "R005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2648"
			wellLabel: "R006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2649"
			wellLabel: "R007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2650"
			wellLabel: "R008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2651"
			wellLabel: "R009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2652"
			wellLabel: "R010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2653"
			wellLabel: "R011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2654"
			wellLabel: "R012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2655"
			wellLabel: "R013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2656"
			wellLabel: "R014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2657"
			wellLabel: "R015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2658"
			wellLabel: "R016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2659"
			wellLabel: "R017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2660"
			wellLabel: "R018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2661"
			wellLabel: "R019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2662"
			wellLabel: "R020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2663"
			wellLabel: "R021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2664"
			wellLabel: "R022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2665"
			wellLabel: "R023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2666"
			wellLabel: "R024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2667"
			wellLabel: "R025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2668"
			wellLabel: "R026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2669"
			wellLabel: "R027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2670"
			wellLabel: "R028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2671"
			wellLabel: "R029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2672"
			wellLabel: "R030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2673"
			wellLabel: "R031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2674"
			wellLabel: "R032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2675"
			wellLabel: "R033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2676"
			wellLabel: "R034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2677"
			wellLabel: "R035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2678"
			wellLabel: "R036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2679"
			wellLabel: "R037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2680"
			wellLabel: "R038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2681"
			wellLabel: "R039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2682"
			wellLabel: "R040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2683"
			wellLabel: "R041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2684"
			wellLabel: "R042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2685"
			wellLabel: "R043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2686"
			wellLabel: "R044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2687"
			wellLabel: "R045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2688"
			wellLabel: "R046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2689"
			wellLabel: "R047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2690"
			wellLabel: "R048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2691"
			wellLabel: "S001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2692"
			wellLabel: "S002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2693"
			wellLabel: "S003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2694"
			wellLabel: "S004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2695"
			wellLabel: "S005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2696"
			wellLabel: "S006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2697"
			wellLabel: "S007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2698"
			wellLabel: "S008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2699"
			wellLabel: "S009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2700"
			wellLabel: "S010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2701"
			wellLabel: "S011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2702"
			wellLabel: "S012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2703"
			wellLabel: "S013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2704"
			wellLabel: "S014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2705"
			wellLabel: "S015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2706"
			wellLabel: "S016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2707"
			wellLabel: "S017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2708"
			wellLabel: "S018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2709"
			wellLabel: "S019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2710"
			wellLabel: "S020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2711"
			wellLabel: "S021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2712"
			wellLabel: "S022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2713"
			wellLabel: "S023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2714"
			wellLabel: "S024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2715"
			wellLabel: "S025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2716"
			wellLabel: "S026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2717"
			wellLabel: "S027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2718"
			wellLabel: "S028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2719"
			wellLabel: "S029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2720"
			wellLabel: "S030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2721"
			wellLabel: "S031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2722"
			wellLabel: "S032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2723"
			wellLabel: "S033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2724"
			wellLabel: "S034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2725"
			wellLabel: "S035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2726"
			wellLabel: "S036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2727"
			wellLabel: "S037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2728"
			wellLabel: "S038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2729"
			wellLabel: "S039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2730"
			wellLabel: "S040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2731"
			wellLabel: "S041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2732"
			wellLabel: "S042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2733"
			wellLabel: "S043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2734"
			wellLabel: "S044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2735"
			wellLabel: "S045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2736"
			wellLabel: "S046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2737"
			wellLabel: "S047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2738"
			wellLabel: "S048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2739"
			wellLabel: "T001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2740"
			wellLabel: "T002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2741"
			wellLabel: "T003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2742"
			wellLabel: "T004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2743"
			wellLabel: "T005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2744"
			wellLabel: "T006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2745"
			wellLabel: "T007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2746"
			wellLabel: "T008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2747"
			wellLabel: "T009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2748"
			wellLabel: "T010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2749"
			wellLabel: "T011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2750"
			wellLabel: "T012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2751"
			wellLabel: "T013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2752"
			wellLabel: "T014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2753"
			wellLabel: "T015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2754"
			wellLabel: "T016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2755"
			wellLabel: "T017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2756"
			wellLabel: "T018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2757"
			wellLabel: "T019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2758"
			wellLabel: "T020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2759"
			wellLabel: "T021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2760"
			wellLabel: "T022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2761"
			wellLabel: "T023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2762"
			wellLabel: "T024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2763"
			wellLabel: "T025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2764"
			wellLabel: "T026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2765"
			wellLabel: "T027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2766"
			wellLabel: "T028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2767"
			wellLabel: "T029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2768"
			wellLabel: "T030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2769"
			wellLabel: "T031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2770"
			wellLabel: "T032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2771"
			wellLabel: "T033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2772"
			wellLabel: "T034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2773"
			wellLabel: "T035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2774"
			wellLabel: "T036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2775"
			wellLabel: "T037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2776"
			wellLabel: "T038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2777"
			wellLabel: "T039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2778"
			wellLabel: "T040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2779"
			wellLabel: "T041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2780"
			wellLabel: "T042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2781"
			wellLabel: "T043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2782"
			wellLabel: "T044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2783"
			wellLabel: "T045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2784"
			wellLabel: "T046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2785"
			wellLabel: "T047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2786"
			wellLabel: "T048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2787"
			wellLabel: "U001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2788"
			wellLabel: "U002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2789"
			wellLabel: "U003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2790"
			wellLabel: "U004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2791"
			wellLabel: "U005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2792"
			wellLabel: "U006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2793"
			wellLabel: "U007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2794"
			wellLabel: "U008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2795"
			wellLabel: "U009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2796"
			wellLabel: "U010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2797"
			wellLabel: "U011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2798"
			wellLabel: "U012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2799"
			wellLabel: "U013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2800"
			wellLabel: "U014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2801"
			wellLabel: "U015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2802"
			wellLabel: "U016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2803"
			wellLabel: "U017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2804"
			wellLabel: "U018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2805"
			wellLabel: "U019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2806"
			wellLabel: "U020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2807"
			wellLabel: "U021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2808"
			wellLabel: "U022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2809"
			wellLabel: "U023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2810"
			wellLabel: "U024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2811"
			wellLabel: "U025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2812"
			wellLabel: "U026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2813"
			wellLabel: "U027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2814"
			wellLabel: "U028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2815"
			wellLabel: "U029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2816"
			wellLabel: "U030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2817"
			wellLabel: "U031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2818"
			wellLabel: "U032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2819"
			wellLabel: "U033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2820"
			wellLabel: "U034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2821"
			wellLabel: "U035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2822"
			wellLabel: "U036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2823"
			wellLabel: "U037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2824"
			wellLabel: "U038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2825"
			wellLabel: "U039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2826"
			wellLabel: "U040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2827"
			wellLabel: "U041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2828"
			wellLabel: "U042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2829"
			wellLabel: "U043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2830"
			wellLabel: "U044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2831"
			wellLabel: "U045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2832"
			wellLabel: "U046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2833"
			wellLabel: "U047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2834"
			wellLabel: "U048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2835"
			wellLabel: "V001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2836"
			wellLabel: "V002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2837"
			wellLabel: "V003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2838"
			wellLabel: "V004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2839"
			wellLabel: "V005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2840"
			wellLabel: "V006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2841"
			wellLabel: "V007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2842"
			wellLabel: "V008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2843"
			wellLabel: "V009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2844"
			wellLabel: "V010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2845"
			wellLabel: "V011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2846"
			wellLabel: "V012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2847"
			wellLabel: "V013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2848"
			wellLabel: "V014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2849"
			wellLabel: "V015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2850"
			wellLabel: "V016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2851"
			wellLabel: "V017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2852"
			wellLabel: "V018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2853"
			wellLabel: "V019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2854"
			wellLabel: "V020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2855"
			wellLabel: "V021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2856"
			wellLabel: "V022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2857"
			wellLabel: "V023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2858"
			wellLabel: "V024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2859"
			wellLabel: "V025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2860"
			wellLabel: "V026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2861"
			wellLabel: "V027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2862"
			wellLabel: "V028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2863"
			wellLabel: "V029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2864"
			wellLabel: "V030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2865"
			wellLabel: "V031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2866"
			wellLabel: "V032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2867"
			wellLabel: "V033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2868"
			wellLabel: "V034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2869"
			wellLabel: "V035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2870"
			wellLabel: "V036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2871"
			wellLabel: "V037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2872"
			wellLabel: "V038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2873"
			wellLabel: "V039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2874"
			wellLabel: "V040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2875"
			wellLabel: "V041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2876"
			wellLabel: "V042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2877"
			wellLabel: "V043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2878"
			wellLabel: "V044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2879"
			wellLabel: "V045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2880"
			wellLabel: "V046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2881"
			wellLabel: "V047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2882"
			wellLabel: "V048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2883"
			wellLabel: "W001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2884"
			wellLabel: "W002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2885"
			wellLabel: "W003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2886"
			wellLabel: "W004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2887"
			wellLabel: "W005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2888"
			wellLabel: "W006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2889"
			wellLabel: "W007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2890"
			wellLabel: "W008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2891"
			wellLabel: "W009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2892"
			wellLabel: "W010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2893"
			wellLabel: "W011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2894"
			wellLabel: "W012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2895"
			wellLabel: "W013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2896"
			wellLabel: "W014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2897"
			wellLabel: "W015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2898"
			wellLabel: "W016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2899"
			wellLabel: "W017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2900"
			wellLabel: "W018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2901"
			wellLabel: "W019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2902"
			wellLabel: "W020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2903"
			wellLabel: "W021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2904"
			wellLabel: "W022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2905"
			wellLabel: "W023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2906"
			wellLabel: "W024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2907"
			wellLabel: "W025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2908"
			wellLabel: "W026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2909"
			wellLabel: "W027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2910"
			wellLabel: "W028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2911"
			wellLabel: "W029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2912"
			wellLabel: "W030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2913"
			wellLabel: "W031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2914"
			wellLabel: "W032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2915"
			wellLabel: "W033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2916"
			wellLabel: "W034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2917"
			wellLabel: "W035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2918"
			wellLabel: "W036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2919"
			wellLabel: "W037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2920"
			wellLabel: "W038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2921"
			wellLabel: "W039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2922"
			wellLabel: "W040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2923"
			wellLabel: "W041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2924"
			wellLabel: "W042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2925"
			wellLabel: "W043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2926"
			wellLabel: "W044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2927"
			wellLabel: "W045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2928"
			wellLabel: "W046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2929"
			wellLabel: "W047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2930"
			wellLabel: "W048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2931"
			wellLabel: "X001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2932"
			wellLabel: "X002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2933"
			wellLabel: "X003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2934"
			wellLabel: "X004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2935"
			wellLabel: "X005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2936"
			wellLabel: "X006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2937"
			wellLabel: "X007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2938"
			wellLabel: "X008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2939"
			wellLabel: "X009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2940"
			wellLabel: "X010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2941"
			wellLabel: "X011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2942"
			wellLabel: "X012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2943"
			wellLabel: "X013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2944"
			wellLabel: "X014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2945"
			wellLabel: "X015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2946"
			wellLabel: "X016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2947"
			wellLabel: "X017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2948"
			wellLabel: "X018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2949"
			wellLabel: "X019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2950"
			wellLabel: "X020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2951"
			wellLabel: "X021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2952"
			wellLabel: "X022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2953"
			wellLabel: "X023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2954"
			wellLabel: "X024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2955"
			wellLabel: "X025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2956"
			wellLabel: "X026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2957"
			wellLabel: "X027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2958"
			wellLabel: "X028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2959"
			wellLabel: "X029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2960"
			wellLabel: "X030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2961"
			wellLabel: "X031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2962"
			wellLabel: "X032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2963"
			wellLabel: "X033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2964"
			wellLabel: "X034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2965"
			wellLabel: "X035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2966"
			wellLabel: "X036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2967"
			wellLabel: "X037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2968"
			wellLabel: "X038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2969"
			wellLabel: "X039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2970"
			wellLabel: "X040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2971"
			wellLabel: "X041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2972"
			wellLabel: "X042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2973"
			wellLabel: "X043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2974"
			wellLabel: "X044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2975"
			wellLabel: "X045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2976"
			wellLabel: "X046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2977"
			wellLabel: "X047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2978"
			wellLabel: "X048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2979"
			wellLabel: "Y001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2980"
			wellLabel: "Y002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2981"
			wellLabel: "Y003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2982"
			wellLabel: "Y004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2983"
			wellLabel: "Y005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2984"
			wellLabel: "Y006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2985"
			wellLabel: "Y007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2986"
			wellLabel: "Y008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2987"
			wellLabel: "Y009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2988"
			wellLabel: "Y010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2989"
			wellLabel: "Y011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2990"
			wellLabel: "Y012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2991"
			wellLabel: "Y013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2992"
			wellLabel: "Y014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2993"
			wellLabel: "Y015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2994"
			wellLabel: "Y016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2995"
			wellLabel: "Y017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2996"
			wellLabel: "Y018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2997"
			wellLabel: "Y019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2998"
			wellLabel: "Y020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-2999"
			wellLabel: "Y021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3000"
			wellLabel: "Y022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3001"
			wellLabel: "Y023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3002"
			wellLabel: "Y024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3003"
			wellLabel: "Y025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3004"
			wellLabel: "Y026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3005"
			wellLabel: "Y027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3006"
			wellLabel: "Y028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3007"
			wellLabel: "Y029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3008"
			wellLabel: "Y030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3009"
			wellLabel: "Y031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3010"
			wellLabel: "Y032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3011"
			wellLabel: "Y033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3012"
			wellLabel: "Y034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3013"
			wellLabel: "Y035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3014"
			wellLabel: "Y036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3015"
			wellLabel: "Y037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3016"
			wellLabel: "Y038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3017"
			wellLabel: "Y039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3018"
			wellLabel: "Y040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3019"
			wellLabel: "Y041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3020"
			wellLabel: "Y042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3021"
			wellLabel: "Y043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3022"
			wellLabel: "Y044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3023"
			wellLabel: "Y045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3024"
			wellLabel: "Y046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3025"
			wellLabel: "Y047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3026"
			wellLabel: "Y048"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3027"
			wellLabel: "Z001"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3028"
			wellLabel: "Z002"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3029"
			wellLabel: "Z003"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3030"
			wellLabel: "Z004"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3031"
			wellLabel: "Z005"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3032"
			wellLabel: "Z006"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3033"
			wellLabel: "Z007"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3034"
			wellLabel: "Z008"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3035"
			wellLabel: "Z009"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3036"
			wellLabel: "Z010"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3037"
			wellLabel: "Z011"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3038"
			wellLabel: "Z012"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3039"
			wellLabel: "Z013"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3040"
			wellLabel: "Z014"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3041"
			wellLabel: "Z015"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3042"
			wellLabel: "Z016"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3043"
			wellLabel: "Z017"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3044"
			wellLabel: "Z018"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3045"
			wellLabel: "Z019"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3046"
			wellLabel: "Z020"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3047"
			wellLabel: "Z021"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3048"
			wellLabel: "Z022"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3049"
			wellLabel: "Z023"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3050"
			wellLabel: "Z024"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3051"
			wellLabel: "Z025"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3052"
			wellLabel: "Z026"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3053"
			wellLabel: "Z027"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3054"
			wellLabel: "Z028"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3055"
			wellLabel: "Z029"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3056"
			wellLabel: "Z030"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3057"
			wellLabel: "Z031"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3058"
			wellLabel: "Z032"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3059"
			wellLabel: "Z033"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3060"
			wellLabel: "Z034"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3061"
			wellLabel: "Z035"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3062"
			wellLabel: "Z036"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3063"
			wellLabel: "Z037"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3064"
			wellLabel: "Z038"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3065"
			wellLabel: "Z039"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3066"
			wellLabel: "Z040"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3067"
			wellLabel: "Z041"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3068"
			wellLabel: "Z042"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3069"
			wellLabel: "Z043"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3070"
			wellLabel: "Z044"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3071"
			wellLabel: "Z045"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3072"
			wellLabel: "Z046"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3073"
			wellLabel: "Z047"
		,
			plateBarcode: "C1138822"
			plateCodeName: "CONT-2"
			wellCodeName: "CONT-3074"
			wellLabel: "Z048"
	]

	exports.getWellContentResponse = [
		amount: 5
		amountUnits: "uL"
		batchCode: "CMPD000023564::3"
		batchConcUnits: "mM"
		batchConcentration: 1
		columnIndex: 29
		containerCodeName: "CONT-6069690"
		level: null
		message: null
		physicalState: "liquid"
		recordedBy: "acas"
		recordedDate: 1456838364133
		rowIndex: 29
		solventCode: "DMSO"
		wellName: "AC029"
	,
		amount: 5
		amountUnits: "uL"
		batchCode: "CMPD000684210::1"
		batchConcUnits: "mM"
		batchConcentration: 1
		columnIndex: 30
		containerCodeName: "CONT-6069691"
		level: null
		message: null
		physicalState: "liquid"
		recordedBy: "acas"
		recordedDate: 1456838364133
		rowIndex: 29
		solventCode: "DMSO"
		wellName: "AC030"
	]

	exports.getContainerAndDefinitionContainerByContainerByLabelResponse = [
		barcode: "12"
		codeName: "CONT-00000002"
		description: null
		plateSize: 1536
		numberOfRows: 32
		numberOfColumns: 48
		type: null
		status: null
		createdDate: null
		supplier: null
	]

	exports.getBreadCrumbByContainerCodeResponse = [
		containerID: 12122883
		containerCode: "CONT-6069438"
		currentLocationID: 12122880
		currentLocationCode: "CONT-6069435"
		currentLocationLabel: "screening system"
		labelBreadCrumb: "screening system"
	,
		containerID: 12122884
		containerCode: "CONT-6069439"
		currentLocationID: 12122880
		currentLocationCode: "CONT-6069435"
		currentLocationLabel: "screening system"
		labelBreadCrumb: "screening system"
	,
		containerID: 12122885
		containerCode: "CONT-6069440"
		currentLocationID: 12122881
		currentLocationCode: "CONT-6069436"
		currentLocationLabel: "hitpicker"
		labelBreadCrumb: "hitpicker"
	,
		containerID: 12122886
		containerCode: "CONT-6069441"
		currentLocationID: 12122880
		currentLocationCode: "CONT-6069435"
		currentLocationLabel: "screening system"
		labelBreadCrumb: "screening system"
	]

	exports.getWellCodesByContainerCodesResponse = [
		requestCodeName: "CONT-6069438"
		wellCodeNames: [ "CONT-6069594", "CONT-6069595", "CONT-6069596", "CONT-6069597"]
	,
		requestCodeName: "CONT-6069439"
		wellCodeNames: [ "CONT-6071068", "CONT-6071069", "CONT-6071070", "CONT-6071071"]
	,
		requestCodeName: "CONT-6069440"
		wellCodeNames: [ "CONT-6072718", "CONT-6072719", "CONT-6072720", "CONT-6072721"]
	,
		requestCodeName: "CONT-6069441"
		wellCodeNames: [ "CONT-6074144", "CONT-6074145", "CONT-6074146", "CONT-6074147"]
	]

	exports.updatePlateMetadataAndDefinitionMetadataByPlateBarcodeResponse = [
		barcode: "C1138792999999999"
		codeName: "CONT-17307711"
		description: "test"
		plateSize: 1536
		numberOfRows: 32
		numberOfColumns: 48
		type: "test2"
		status: "at step"
		createdDate: 1457975001000
		supplier: "brianss"
		recordedBy: "bbolts"
	]

	exports.searchContainersInternalResponse = [
		"description": "test description",
		"plateSize": 1536,
		"numberOfRows": 32,
		"numberOfColumns": 48,
		"barcode": "TESTBARCODE-123",
		"codeName": "CONT-00000001",
		"definitionCodeName": "CONT-00000002",
		"recordedBy": "acas"
		,
		"description": "test description 2",
		"status": "active",
		"type": "screening plate",
		"plateSize": 1536,
		"numberOfRows": 32,
		"numberOfColumns": 48,
		"barcode": "TESTBARCODE-124",
		"codeName": "CONT-00003075",
		"definitionCodeName": "CONT-00000002",
		"recordedBy": "acas"
	]

	exports.definitionContainers = [
		plate = [
			{
				deleted: false,
				ignored: false,
				lsKind: "plate",
				lsLabels: [
					{
						deleted: false,
						ignored: false,
						labelText: "96",
						lsKind: "common",
						lsType: "name",
						lsTypeAndKind: "name_common",
						physicallyLabled: true,
						preferred: true,
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsStates: [
					{
						deleted: false,
						ignored: false,
						lsKind: "format",
						lsType: "constants",
						lsTypeAndKind: "constants_format",
						lsValues: [
							{
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "columns",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_columns",
								numericValue: 12,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "wells",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_wells",
								numericValue: 96,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "rows",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_rows",
								numericValue: 8,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								codeValue: "A001",
								deleted: false,
								ignored: false,
								lsKind: "subcontainer naming convention",
								lsType: "codeValue",
								lsTypeAndKind: "codeValue_subcontainer naming convention",
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}
						],
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsType: "definition container",
				lsTypeAndKind: "definition container_plate",
				recordedBy: "acas",
				recordedDate: 1456179684968
			}, {
				deleted: false,
				ignored: false,
				lsKind: "plate",
				lsLabels: [
					{
						deleted: false,
						ignored: false,
						labelText: "384",
						lsKind: "common",
						lsType: "name",
						lsTypeAndKind: "name_common",
						physicallyLabled: true,
						preferred: true,
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsStates: [
					{
						deleted: false,
						ignored: false,
						lsKind: "format",
						lsType: "constants",
						lsTypeAndKind: "constants_format",
						lsValues: [
							{
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "columns",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_columns",
								numericValue: 24,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "wells",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_wells",
								numericValue: 384,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "rows",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_rows",
								numericValue: 16,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								codeValue: "A001",
								deleted: false,
								ignored: false,
								lsKind: "subcontainer naming convention",
								lsType: "codeValue",
								lsTypeAndKind: "codeValue_subcontainer naming convention",
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}
						],
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsType: "definition container",
				lsTypeAndKind: "definition container_plate",
				recordedBy: "acas",
				recordedDate: 1456179684968
			}, {
				deleted: false,
				ignored: false,
				lsKind: "plate",
				lsLabels: [
					{
						deleted: false,
						ignored: false,
						labelText: "1536",
						lsKind: "common",
						lsType: "name",
						lsTypeAndKind: "name_common",
						physicallyLabled: true,
						preferred: true,
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsStates: [
					{
						deleted: false,
						ignored: false,
						lsKind: "format",
						lsType: "constants",
						lsTypeAndKind: "constants_format",
						lsValues: [
							{
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "columns",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_columns",
								numericValue: 48,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "wells",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_wells",
								numericValue: 1536,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "rows",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_rows",
								numericValue: 32,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								codeValue: "A001",
								deleted: false,
								ignored: false,
								lsKind: "subcontainer naming convention",
								lsType: "codeValue",
								lsTypeAndKind: "codeValue_subcontainer naming convention",
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}
						],
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsType: "definition container",
				lsTypeAndKind: "definition container_plate",
				recordedBy: "acas",
				recordedDate: 1456179684968
			}
		],tube = [
			{
				deleted: false,
				ignored: false,
				lsKind: "tube",
				lsLabels: [
					{
						deleted: false,
						ignored: false,
						labelText: "Vial",
						lsKind: "common",
						lsType: "name",
						lsTypeAndKind: "name_common",
						physicallyLabled: true,
						preferred: true,
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsStates: [
					{
						deleted: false,
						ignored: false,
						lsKind: "format",
						lsType: "constants",
						lsTypeAndKind: "constants_format",
						lsValues: [
							{
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "columns",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_columns",
								numericValue: 1,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "wells",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_wells",
								numericValue: 1,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								deleted: false,
								ignored: false,
								lsKind: "rows",
								lsType: "numericValue",
								lsTypeAndKind: "numericValue_rows",
								numericValue: 1,
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}, {
								codeTypeAndKind: "null_null",
								codeValue: "A001",
								deleted: false,
								ignored: false,
								lsKind: "subcontainer naming convention",
								lsType: "codeValue",
								lsTypeAndKind: "codeValue_subcontainer naming convention",
								operatorTypeAndKind: "null_null",
								publicData: true,
								recordedBy: "acas",
								recordedDate: 1456179684968,
								unitTypeAndKind: "null_null"
							}
						],
						recordedBy: "acas",
						recordedDate: 1456179684968
					}
				],
				lsType: "definition container",
				lsTypeAndKind: "definition container_tube",
				recordedBy: "acas",
				recordedDate: 1456179684968
			}
		]
	]

	exports.containerLog = [
		codeName : "CONT-0001"
		entryType : "vial expired"
		entry : "DV to MINI Process"
		recordedBy : "acas"
		recordedDate : 1456179684968 #optional
		lsTransaction : 1234 #optional
		additionalValues : [ #optional
			lsType : "numericValue"
			lsKind : "amount"
			numericValue : 1302.7
			unitKind : "uL"
		]
	,
		codeName : "CONT-0002"
		entryType : "vial solvated"
		entry : ""
		recordedBy : "acas"
		recordedDate : 1456179684968
		additionalValues : [
			lsType : "numericValue"
			lsKind : "amount"
			numericValue : 1302.7
			unitKind : "uL"
		]
	,
		codeName : "CONT-0001"
		entryType : "solid transfer destination"
		entry : ""
		recordedBy : "acas"
		recordedDate : 1456179684968
		additionalValues : [
			lsType : "numericValue"
			lsKind : "amount"
			numericValue : 6.6
			unitKind : "mg"
		,
			lsType : "codeValue"
			lsKind : "parent"
			codeValue : "DV750150"
		]
	]

	exports.vial =
		deleted: false
		ignored: false
		lsKind: "tube"
		lsLabels: [
			deleted: false
			ignored: false
			labelText: "VIAL-00001"
			lsKind: "barcode"
			lsType: "barcode"
			lsTypeAndKind: "barcode_barcode"
			physicallyLabled: true
			preferred: true
			recordedBy: "acas"
			recordedDate: 1462585654689
			version: 0
		]
		lsStates: [
			deleted: false
			ignored: false
			lsKind: "information"
			lsType: "constants"
			lsTypeAndKind: "constants_information"
			lsValues: [
				codeTypeAndKind: "null_null"
				deleted: false
				ignored: false
				lsKind: "tare weight"
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_tare weight"
				numericValue: 5668.27
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitKind: "mg"
				unitTypeAndKind: "null_mg"
				version: 0
			]
			recordedBy: "acas"
			recordedDate: 1462585654689
			version: 0
		,
			deleted: false
			ignored: false
			lsKind: "information"
			lsType: "metadata"
			lsTypeAndKind: "metadata_information"
			lsValues: [
				codeTypeAndKind: "null_null"
				dateValue: 1380930856000
				deleted: false
				ignored: false
				lsKind: "created date"
				lsType: "dateValue"
				lsTypeAndKind: "dateValue_created date"
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitTypeAndKind: "null_null"
				version: 0
			,
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				codeType: "status"
				codeTypeAndKind: "status_status"
				codeValue: "created"
				deleted: false
				ignored: false
				lsKind: "status"
				lsType: "codeValue"
				lsTypeAndKind: "codeValue_status"
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitTypeAndKind: "null_null"
				version: 0
			,
				codeKind: "type"
				codeOrigin: "ACAS DDICT"
				codeType: "type"
				codeTypeAndKind: "type_type"
				codeValue: "powder vial"
				deleted: false
				ignored: false
				lsKind: "type"
				lsType: "codeValue"
				lsTypeAndKind: "codeValue_type"
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitTypeAndKind: "null_null"
				version: 0
			,
				codeTypeAndKind: "null_null"
				dateValue: 1383289200000
				deleted: false
				ignored: false
				lsKind: "registration date"
				lsType: "dateValue"
				lsTypeAndKind: "dateValue_registration date"
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitTypeAndKind: "null_null"
				version: 0
			,
				codeKind: "availability"
				codeType: "availability"
				codeTypeAndKind: "availability_availability"
				codeValue: "0"
				deleted: false
				ignored: false
				lsKind: "availability"
				lsType: "codeValue"
				lsTypeAndKind: "codeValue_availability"
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitTypeAndKind: "null_null"
				version: 0
			,
				codeKind: "created user"
				codeOrigin: "ACAS DDICT"
				codeType: "created user"
				codeTypeAndKind: "created user_created user"
				codeValue: "jzer"
				deleted: false
				ignored: false
				lsKind: "created user"
				lsType: "codeValue"
				lsTypeAndKind: "codeValue_created user"
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitTypeAndKind: "null_null"
				version: 0
			,
				codeKind: "supplier"
				codeOrigin: "KPLATE"
				codeType: "supplier"
				codeTypeAndKind: "supplier_supplier"
				codeValue: "CMG"
				deleted: false
				ignored: false
				lsKind: "supplier"
				lsType: "codeValue"
				lsTypeAndKind: "codeValue_supplier"
				operatorTypeAndKind: "null_null"
				publicData: true
				recordedBy: "acas"
				recordedDate: 1462585654689
				unitTypeAndKind: "null_null"
				version: 0
			]
			recordedBy: "acas"
			recordedDate: 1462585654689
			version: 0
		]
		lsType: "container"
		lsTypeAndKind: "container_tube"
		recordedBy: "acas"
		recordedDate: 1462585654689
		version: 0

	exports.moveLocationToLocationInput =
		[{
			"containerCodeName": "CONT-00000005",
			"modifiedBy": "ewoo",
			"modifiedDate": 1464401607998,
			"locationCodeName": "CONT-00000001"
			"locationLabel": "New location"
		}]
		
	exports.moveLocationToLocationSuccessResp =
		[
			[
				{
					"containerCodeName": "CONT-00000012",
					"lsState": {
						"lsValues": [
							{
								"ignored": false,
								"recordedDate": 1464401607998,
								"recordedBy": "ewoo",
								"lsType": "stringValue",
								"lsKind": "location",
								"stringValue": "[\"COMPANY\",\"FREEZER1\",\"SHELF2\",\"RACK001\",\"A001\",\"EW000001\"]"
							},
							{
								"ignored": false,
								"recordedDate": 1464401607998,
								"recordedBy": "ewoo",
								"lsType": "codeValue",
								"lsKind": "moved by",
								"codeValue": "ewoo"
							},
							{
								"ignored": false,
								"recordedDate": 1464401607998,
								"recordedBy": "ewoo",
								"lsType": "dateValue",
								"lsKind": "moved date",
								"dateValue": 1464401607998
							}
						],
						"ignored": false,
						"recordedDate": 1464401607998,
						"recordedBy": "ewoo",
						"lsType": "metadata",
						"lsKind": "location history"
					}
				},
				{
					"containerCodeName": "CONT-00000014",
					"lsState": {
						"lsValues": [
							{
								"ignored": false,
								"recordedDate": 1464401607998,
								"recordedBy": "ewoo",
								"lsType": "stringValue",
								"lsKind": "location",
								"stringValue": "[\"COMPANY\",\"FREEZER1\",\"SHELF2\",\"RACK001\",\"B001\",\"EW000002\"]"
							},
							{
								"ignored": false,
								"recordedDate": 1464401607998,
								"recordedBy": "ewoo",
								"lsType": "codeValue",
								"lsKind": "moved by",
								"codeValue": "ewoo"
							},
							{
								"ignored": false,
								"recordedDate": 1464401607998,
								"recordedBy": "ewoo",
								"lsType": "dateValue",
								"lsKind": "moved date",
								"dateValue": 1464401607998
							}
						],
						"ignored": false,
						"recordedDate": 1464401607998,
						"recordedBy": "ewoo",
						"lsType": "metadata",
						"lsKind": "location history"
					}
				}
			]
		]
	
	exports.getLocationTreeByCodeNameResp2 =
		[
			{
				"codeName": "CONT-56514728",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004>CONT-00000005>CONT-00000011>CONT-56514728",
				"codeTree": "......CONT-56514728",
				"labelText": "112817EW1",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2>RACK002>A001>112817EW1",
				"labelTree": "......112817EW1",
				"level": 6,
				"parentCodeName": "CONT-00000011",
				"rootCodeName": "CONT-00000001",
				"lsType": "container",
				"lsKind": "tube"
			},
			{
				"codeName": "CONT-56514730",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004>CONT-00000005>CONT-00000011>CONT-56514730",
				"codeTree": "......CONT-56514730",
				"labelText": "112817EW2",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2>RACK002>A002>112817EW2",
				"labelTree": "......112817EW2",
				"level": 6,
				"parentCodeName": "CONT-00000014",
				"rootCodeName": "CONT-00000001",
				"lsType": "container",
				"lsKind": "tube"
			}
		]

	exports.getLocationTreeByCodeNameResp =
		[
			{
				"codeName": "CONT-00000001",
				"codeNameBreadcrumb": "CONT-00000001",
				"codeTree": "CONT-00000001",
				"labelText": "COMPANY",
				"labelTextBreadcrumb": "COMPANY",
				"labelTree": "COMPANY",
				"level": 1,
				"parentCodeName": null,
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000010",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000010",
				"codeTree": "..CONT-00000010",
				"labelText": "Benches",
				"labelTextBreadcrumb": "COMPANY>Benches",
				"labelTree": "..Benches",
				"level": 2,
				"parentCodeName": "CONT-00000001",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000006",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000006",
				"codeTree": "..CONT-00000006",
				"labelText": "FREEZER2",
				"labelTextBreadcrumb": "COMPANY>FREEZER2",
				"labelTree": "..FREEZER2",
				"level": 2,
				"parentCodeName": "CONT-00000001",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000002",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002",
				"codeTree": "..CONT-00000002",
				"labelText": "FREEZER1",
				"labelTextBreadcrumb": "COMPANY>FREEZER1",
				"labelTree": "..FREEZER1",
				"level": 2,
				"parentCodeName": "CONT-00000001",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000004",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004",
				"codeTree": "....CONT-00000004",
				"labelText": "SHELF2",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2",
				"labelTree": "....SHELF2",
				"level": 3,
				"parentCodeName": "CONT-00000002",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000003",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000003",
				"codeTree": "....CONT-00000003",
				"labelText": "SHELF1",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF1",
				"labelTree": "....SHELF1",
				"level": 3,
				"parentCodeName": "CONT-00000002",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000009",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000010>CONT-00000009",
				"codeTree": "....CONT-00000009",
				"labelText": "bob",
				"labelTextBreadcrumb": "COMPANY>Benches>bob",
				"labelTree": "....bob",
				"level": 3,
				"parentCodeName": "CONT-00000010",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000005",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004>CONT-00000005",
				"codeTree": "......CONT-00000005",
				"labelText": "RACK001",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2>RACK001",
				"labelTree": "......RACK001",
				"level": 4,
				"parentCodeName": "CONT-00000004",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000011",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004>CONT-00000005>CONT-00000011",
				"codeTree": "......CONT-00000011",
				"labelText": "A001",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2>RACK001>A001",
				"labelTree": "......A001",
				"level": 5,
				"parentCodeName": "CONT-00000005",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000012",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004>CONT-00000005>CONT-00000011>CONT-00000012",
				"codeTree": "......CONT-00000012",
				"labelText": "EW000001",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2>RACK001>A001>EW000001",
				"labelTree": "......EW000001",
				"level": 6,
				"parentCodeName": "CONT-00000011",
				"rootCodeName": "CONT-00000001",
				"lsType": "container",
				"lsKind": "tube"
			},
			{
				"codeName": "CONT-00000013",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004>CONT-00000005>CONT-00000013",
				"codeTree": "......CONT-00000013",
				"labelText": "B001",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2>RACK001>B001",
				"labelTree": "......B001",
				"level": 5,
				"parentCodeName": "CONT-00000005",
				"rootCodeName": "CONT-00000001",
				"lsType": "location",
				"lsKind": "default"
			},
			{
				"codeName": "CONT-00000014",
				"codeNameBreadcrumb": "CONT-00000001>CONT-00000002>CONT-00000004>CONT-00000005>CONT-00000011>CONT-00000014",
				"codeTree": "......CONT-00000014",
				"labelText": "EW000002",
				"labelTextBreadcrumb": "COMPANY>FREEZER1>SHELF2>RACK001>B001>EW000002",
				"labelTree": "......EW000002",
				"level": 6,
				"parentCodeName": "CONT-00000014",
				"rootCodeName": "CONT-00000001",
				"lsType": "container",
				"lsKind": "tube"
			}
		]

	exports.bulkUpdateContainerStatesResp =
		[
			containerCodeName: "CONT-00000012"
			lsState:
				deleted: false,
				id: 1,
				ignored: false,
				lsKind: "location history",
				lsType: "metadata",
				lsTypeAndKind: "metadata_location history",
				lsValues: [
					{
						codeTypeAndKind: "null_null",
						codeValue: "ewoo",
						deleted: false,
						id: 2,
						ignored: false,
						lsKind: "moved by",
						lsType: "codeValue",
						lsTypeAndKind: "codeValue_moved by",
						operatorTypeAndKind: "null_null",
						publicData: true,
						recordedBy: "ewoo",
						recordedDate: 1492116904216,
						unitTypeAndKind: "null_null",
						version: 0
					},
					{
						codeTypeAndKind: "null_null",
						dateValue: 1428538649000,
						deleted: false,
						id: 3,
						ignored: false,
						lsKind: "moved date",
						lsType: "dateValue",
						lsTypeAndKind: "dateValue_moved date",
						operatorTypeAndKind: "null_null",
						publicData: true,
						recordedBy: "ewoo",
						recordedDate: 1492116904216,
						unitTypeAndKind: "null_null",
						version: 0
					},
					{
						codeTypeAndKind: "null_null",
						deleted: false,
						id: 4,
						ignored: false,
						lsKind: "location",
						lsType: "stringValue",
						lsTypeAndKind: "stringValue_location",
						operatorTypeAndKind: "null_null",
						publicData: true,
						recordedBy: "ewoo",
						recordedDate: 1492116904216,
						stringValue: '["COMPANY","FREEZER1","SHELF2","RACK001","A001"]',
						unitTypeAndKind: "null_null",
						version: 0
					}
				],
				recordedBy: "ewoo",
				recordedDate: 1492116904216,
				version: 0
		,
			containerCodeName: "CONT-00000014"
			lsState:
				deleted: false,
				id: 5,
				ignored: false,
				lsKind: "location history",
				lsType: "metadata",
				lsTypeAndKind: "metadata_location history",
				lsValues: [
					{
						codeTypeAndKind: "null_null",
						codeValue: "ewoo",
						deleted: false,
						id: 6,
						ignored: false,
						lsKind: "moved by",
						lsType: "codeValue",
						lsTypeAndKind: "codeValue_moved by",
						operatorTypeAndKind: "null_null",
						publicData: true,
						recordedBy: "ewoo",
						recordedDate: 1492116904216,
						unitTypeAndKind: "null_null",
						version: 0
					},
					{
						codeTypeAndKind: "null_null",
						dateValue: 1428538649000,
						deleted: false,
						id: 7,
						ignored: false,
						lsKind: "moved date",
						lsType: "dateValue",
						lsTypeAndKind: "dateValue_moved date",
						operatorTypeAndKind: "null_null",
						publicData: true,
						recordedBy: "ewoo",
						recordedDate: 1492116904216,
						unitTypeAndKind: "null_null",
						version: 0
					},
					{
						codeTypeAndKind: "null_null",
						deleted: false,
						id: 8,
						ignored: false,
						lsKind: "location",
						lsType: "stringValue",
						lsTypeAndKind: "stringValue_location",
						operatorTypeAndKind: "null_null",
						publicData: true,
						recordedBy: "ewoo",
						recordedDate: 1492116904216,
						stringValue: '["COMPANY","FREEZER1","SHELF2","RACK001", "B001"]',
						unitTypeAndKind: "null_null",
						version: 0
					}
				],
				recordedBy: "ewoo",
				recordedDate: 1492116904216,
				version: 0
		]

) (if (typeof process is "undefined" or not process.versions) then window.inventoryServiceTestJSON = window.inventoryServiceTestJSON or {} else exports)
