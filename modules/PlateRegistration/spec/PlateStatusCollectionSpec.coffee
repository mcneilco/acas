PlateStatusCollection = require('../src/client/PlateStatusCollection.coffee').PlateStatusCollection

describe "PlateStatusCollection", ->
  it "should exist", ->
    plateStatus = new PlateStatusCollection()
    expect(plateStatus).toBeTruthy()