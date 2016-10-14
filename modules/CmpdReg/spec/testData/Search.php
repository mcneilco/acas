<?php

if(strpos($HTTP_RAW_POST_DATA, 'none') !== false) {
    header("Content-type: application/json;charset=utf-8");
sleep(0);
    echo '[]';
} else if(strpos($HTTP_RAW_POST_DATA, 'many') !== false) {
    header('too many results', true, 506);
sleep(0);
    echo '[{"level":"warning","message": "Too many search results returned" }]';
} else {
    header("Content-type: application/json;charset=utf-8");
//    echo '[{"corpName":"CMPD-1234-Na","stereoCategoryName":"Racemic","stereoComment":"","lotIDs":{"CMPD-1234-Na-1":1,"CMPD-1234-Na-2":2,"CMPD-1234-Na-3":3,"CMPD-1234-Na-5":5},"molStructure":"CC[C@H](C)C(CCCCCCNC(C)(C)OC(=O)OC(=O)OC(C)(C)C)[C@@H](CC(=O)C1=C(C(C)C)C(CCC[C@@H](CC2=CC=CC=C2)C(=O)OC)=CC=C1)OC"},{"corpName":"CMPD-1234-Cl","stereoCategoryName":"Racemic","stereoComment":"st comm","lotIDs":{"CMPD-1234-Cl-1":1,"CMPD-1234-Cl-2":2,"CMPD-1234-Cl-3":3},"molStructure":"C1=CC2=CC3=CC4=CC5=CC6=C(C=CC=C6)C=C5C=C4C=C3C=C2C=C1 |c:0,12,14,17,20,23,26,29,t:2,4,6,8,10|"},{"corpName":"CMPD-1234-C14","stereoCategoryName":"Scalemic","stereoComment":"","lotIDs":{"CMPD-1234-C14-1":1,"CMPD-1234-C14-2":2},"molStructure":"N1C=CC2=C1NC1=C2C2=C(N1)NC1=C2C2=C(NC=C2)N1 |c:1,3,7,15,21,t:18|"},{"corpName":"CMPD-2222-K","stereoCategoryName":"See Comment","stereoComment":"lots of centers","lotIDs":{"CMPD-2222-K-1":1},"molStructure":"C1CC2CC3CC4CC5C(CC6CC7CC8CCCC8C7C56)C4C3C2C1"}]';
sleep(0);
    echo '[{"parentAliases":[{"aliasName":"XANTHOTOXIN","deleted":false,"id":53151,"ignored":false,"lsKind":"LiveDesign Corp Name","lsType":"external id","preferred":false,"version":0},{"aliasName":"Methoxa-Dome","deleted":false,"id":53150,"ignored":false,"lsKind":"Common Name","lsType":"other name","preferred":false,"version":0}], "corpName":"CMPD-0000001","corpNameType":"Parent","lotIDs":[{"buid":0,"corpName":"CMPD-0000001-01A","lotNumber":1,"registrationDate":"08/11/2015","synthesisDate":"08/11/2015"}],"molStructure":"\nMrv1533008111508072D\n\n990000999V2000\n0.0000-1.47930.0000C000000000000\n0.0000-0.65430.0000C000000000000\n0.7145-0.24180.0000C000000000000\n0.71450.58320.0000C000000000000\n1.42890.99570.0000O000000000000\n0.00000.99570.0000C000000000000\n-0.71450.58320.0000C000000000000\n-0.7145-0.24180.0000C000000000000\n-1.4289-0.65430.0000O000000000000\n1210000\n2320000\n3410000\n4520000\n4610000\n6720000\n7810000\n2810000\n8920000\nMEND\n","stereoCategoryName":"Achiral","stereoComment":null},{"corpName":"CMPD-0000002","corpNameType":"Salt","lotIDs":[{"buid":0,"corpName":"CMPD-0000002-01B","lotNumber":1,"registrationDate":"08/11/2015","synthesisDate":"08/11/2015"}],"molStructure":"\nMrv1533008111508072D\n\n990000999V2000\n0.0000-1.47930.0000C000000000000\n0.0000-0.65430.0000C000000000000\n0.7145-0.24180.0000C000000000000\n0.71450.58320.0000C000000000000\n1.42890.99570.0000O000000000000\n0.00000.99570.0000C000000000000\n-0.71450.58320.0000C000000000000\n-0.7145-0.24180.0000C000000000000\n-1.4289-0.65430.0000O000000000000\n1210000\n2320000\n3410000\n4520000\n4610000\n6720000\n7810000\n2810000\n8920000\nMEND\n","stereoCategoryName":"Achiral","stereoComment":null}]';
}
?>
