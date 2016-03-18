validAddContentModel =
  identifierType: "identifierType"
  identifiers: "identifiers"
  volume: 'volume'
  concentration: "concentration"
  fillStrategy: "fillStrategy"
  fillDirection: "fillDirection"
  wells: "wells"

listOfIdentifiers =
  inputCommaSeparated: "TEST1,TEST2,TEST3"
  expectedOutput: [
    "TEST1"
    "TEST2"
    "TEST3"
  ]
module.exports =
  validAddContentModel: validAddContentModel
  listOfIdentifiers: listOfIdentifiers