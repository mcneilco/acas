<?php
header('Cache-Control: no-cache, no-store, must-revalidate');
header("Content-type: application/json;charset=utf-8");
//  echo '[{"id":1, "code": "aadmin", "name": "Adam Admin","isChemist":false,"isAdmin":true},{"id":2, "code": "cchemist", "name": "Corey Chemist","isChemist":true,"isAdmin":false},{"id":3, "code": "bbiologist", "name": "Ben Biologist","isChemist":false,"isAdmin":false}]';
echo '[{"code":"aadmin","id":1,"ignore":null,"isAdmin":true,"isChemist":false,"name":"Adam Admin","version":0},{"code":"cchemist","id":2,"ignore":false,"isAdmin":false,"isChemist":true,"name":"Corey Chemist","version":0},{"code":"bbiologist","id":3,"ignore":false,"isAdmin":false,"isChemist":false,"name":"Ben Biologist","version":0},{"code":"dchemist","id":4,"ignore":null,"isAdmin":false,"isChemist":true,"name":"Dave Chemist","version":0},{"code":"ignoreme","id":5,"ignore":true,"isAdmin":false,"isChemist":true,"name":"Ignore Me","version":0}]';
?>