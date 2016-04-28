PlateTypeCollection = require('../src/client/PlateTypeCollection.coffee').PlateTypeCollection
PLATE_TYPE_COLLECTION_CONST = require('../src/client/PlateTypeCollection.coffee').PLATE_TYPE_COLLECTION_CONST
fixtures = require('./testFixtures/PlateTypeFixtures.coffee')

describe "PlateTypeCollection", ->
  it "should exist", ->
    plateTypes = new PlateTypeCollection()
    expect(plateTypes).toBeTruthy()

  it "should have a url field", ->
    plateTypes = new PlateTypeCollection()
    expect(plateTypes.url).toBeTruthy()
    expect(plateTypes.url()).toEqual PLATE_TYPE_COLLECTION_CONST.URL