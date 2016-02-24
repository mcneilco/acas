createNewPlate =
  "barcode":"DV025320",
  "definition":"CONT-0000000150",
  "template":"CONT-0000000160",
  "recordedBy":"acas"
  "supplier": "DNS"
  "wells":[]

createNewPlateResponse =
  "barcode":"DV025320",
  "codeName":"CONT-000001456",
  "wells":
    [
      {
        "wellName":"A1",
        "codeName":"CONT-00000001",
        "rowIndex":0,
        "columnIndex":0
      }
    ,
      {
        "wellName":"A2",
        "codeName":"CONT-00000002",
        "rowIndex":0,
        "columnIndex":0
      }
    ]

module.exports =
  createNewPlate: createNewPlate
  createNewPlateResponse: createNewPlateResponse