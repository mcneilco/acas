createNewPlate =
  "barcode": "DV025320",
  "definition": "CONT-0000000150",
  "template": "CONT-0000000160",
  "recordedBy": "acas"
  "supplier": "DNS"
  "wells": []

createNewPlateResponse =
  "barcode": "DV025320",
  "codeName": "CONT-000001456",
  "wells":
    [
      {
        "wellName": "A1",
        "codeName": "CONT-00000001",
        "rowIndex": 0,
        "columnIndex": 0
      }
    ,
      {
        "wellName": "A2",
        "codeName": "CONT-00000002",
        "rowIndex": 0,
        "columnIndex": 0
      }
    ]

[{
  "deleted": false,
  "ignored": false,
  "lsKind": "plate",
  "lsLabels": [{
    "deleted": false,
    "ignored": false,
    "labelText": "1536",
    "lsKind": "common",
    "lsType": "name",
    "lsTypeAndKind": "name_common",
    "physicallyLabled": true,
    "preferred": true,
    "recordedBy": "acas",
    "recordedDate": 1456179684968
  }],
  "lsStates": [{
    "deleted": false,
    "ignored": false,
    "lsKind": "format",
    "lsType": "constants",
    "lsTypeAndKind": "constants_format",
    "lsValues": [{
      "codeTypeAndKind": "null_null",
      "deleted": false,
      "ignored": false,
      "lsKind": "columns",
      "lsType": "numericValue",
      "lsTypeAndKind": "numericValue_columns",
      "numericValue": 48,
      "operatorTypeAndKind": "null_null",
      "publicData": true,
      "recordedBy": "acas",
      "recordedDate": 1456179684968,
      "unitTypeAndKind": "null_null"
    }, {
      "codeTypeAndKind": "null_null",
      "deleted": false,
      "ignored": false,
      "lsKind": "wells",
      "lsType": "numericValue",
      "lsTypeAndKind": "numericValue_wells",
      "numericValue": 1536,
      "operatorTypeAndKind": "null_null",
      "publicData": true,
      "recordedBy": "acas",
      "recordedDate": 1456179684968,
      "unitTypeAndKind": "null_null"
    }, {
      "codeTypeAndKind": "null_null",
      "deleted": false,
      "ignored": false,
      "lsKind": "rows",
      "lsType": "numericValue",
      "lsTypeAndKind": "numericValue_rows",
      "numericValue": 32,
      "operatorTypeAndKind": "null_null",
      "publicData": true,
      "recordedBy": "acas",
      "recordedDate": 1456179684968,
      "unitTypeAndKind": "null_null"
    }, {
      "codeTypeAndKind": "null_null",
      "codeValue": "A001",
      "deleted": false,
      "ignored": false,
      "lsKind": "subcontainer naming convention",
      "lsType": "codeValue",
      "lsTypeAndKind": "codeValue_subcontainer naming convention",
      "operatorTypeAndKind": "null_null",
      "publicData": true,
      "recordedBy": "acas",
      "recordedDate": 1456179684968,
      "unitTypeAndKind": "null_null"
    }],
    "recordedBy": "acas",
    "recordedDate": 1456179684968
  }],
  "lsType": "definition container",
  "lsTypeAndKind": "definition container_plate",
  "recordedBy": "acas",
  "recordedDate": 1456179684968
}]


module.exports =
  createNewPlate: createNewPlate
  createNewPlateResponse: createNewPlateResponse