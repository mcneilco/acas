<?php
if($_SERVER['REQUEST_METHOD']=='GET'){
//    echo '[{"id": 400, "name":"C14","abbrev":"C14","massChange":2},{"id": 401, "name":"U235","abbrev":"U235","massChange":-3}]'; 
    echo '[{"abbrev":"U235","id":2,"ignore":null,"massChange":-3.0,"name":"U235","version":0},{"abbrev":"C14","id":2,"ignore":null,"massChange":2.0,"name":"C14","version":0}]';
    
} else if(strpos($HTTP_RAW_POST_DATA, 'forceerror') !== false ) {
    header('isotope save error', true, 506);
    echo '{"errors":[{"level":"error","message": "Isotope with this abbreviation exists" },{"level":"error","message": "Isotope with this name exists" }]}';
} else {
    header("Content-type: application/json;charset=utf-8");
    echo '{"id": 4, "name":"savedIsotope","abbrev":"SI","massChange":1.5}';
}

?>
