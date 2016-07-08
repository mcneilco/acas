<?php
if($_SERVER['REQUEST_METHOD']=='GET'){
//    echo '[{"id": 500, "name":"Cl","abbrev":"Cl","molStructure":"mol string 1"},{"id": 501, "name":"Na","abbrev":"Na","molStructure":"mol string 2"}]'; 
    echo '[{"abbrev":"Na","formula":"Na","id":1,"ignore":null,"molStructure":"\n  Mrv0541 10271122032D          \n\n  1  0  0  0  0  0            999 V2000\n    0.5304    1.0018    0.0000 Na  0  0  0  0  0  0  0  0  0  0  0  0\nM  END\n","molWeight":22.98976928,"name":"Na","originalStructure":"\n  Mrv0541 10271122032D          \n\n  1  0  0  0  0  0            999 V2000\n    0.5304    1.0018    0.0000 Na  0  0  0  0  0  0  0  0  0  0  0  0\nM  END\n","saltCdId":21,"version":0},{"abbrev":"Cl","formula":"Cl","id":2,"ignore":null,"molStructure":"\n  Mrv0541 10271122032D          \n\n  1  0  0  0  0  0            999 V2000\n    0.5304    1.0018    0.0000 Na  0  0  0  0  0  0  0  0  0  0  0  0\nM  END\n","molWeight":22.98976928,"name":"Cl","originalStructure":"\n  Mrv0541 10271122032D          \n\n  1  0  0  0  0  0            999 V2000\n    0.5304    1.0018    0.0000 Na  0  0  0  0  0  0  0  0  0  0  0  0\nM  END\n","saltCdId":21,"version":0}]';
    
} else if(strpos($HTTP_RAW_POST_DATA, 'forceerror') !== false ) {
    header('salt save error', true, 506);
    echo '[{"level":"error","message": "Salt with this abbreviation exists" },{"level":"error","message": "Salt with this name exists" },{"level":"error","message": "Salt with this structure exists" }]';
} else {
    header("Content-type: application/json;charset=utf-8");
    echo '{"id": 4, "name":"savedSalt","abbrev":"SS","molStructure":"mol string 2"}';
}

?>
