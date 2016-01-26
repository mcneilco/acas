PlateTypeCollection = require('../src/client/PlateTypeCollection.coffee').PlateTypeCollection
fixtures = require("./testFixtures/PlateTypeFixtures.coffee")

describe "PlateTypeCollection", ->
  it "should exist", ->
    plateTypes = new PlateTypeCollection()
    expect(plateTypes).toBeTruthy()