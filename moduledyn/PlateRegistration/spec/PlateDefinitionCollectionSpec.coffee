PlateDefinitionCollection = require('../src/client/PlateDefinitionCollection.coffee').PlateDefinitionCollection

describe "PlateDefinitionCollection", ->
  it "should exist", ->
    plateDefinition = new PlateDefinitionCollection()
    expect(plateDefinition).toBeTruthy()