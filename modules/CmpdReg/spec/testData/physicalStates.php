<?php
header('Cache-Control: no-cache, no-store, must-revalidate');
header("Content-type: application/json;charset=utf-8");
//  echo '[{"id":1, "code": "solid", "name": "solid"},{"id":2, "code": "liquid", "name": "liquid"},{"id":3, "code": "gel", "name": "gel"}]';
echo '[{"code":"solid","id":1,"name":"solid","version":0},{"code":"liquid","id":2,"name":"liquid","version":0},{"code":"gel","id":3,"name":"gel","version":0},{"code":"gas","id":4,"name":"gas","version":0,"ignore":true}]';
?>