PlateFillerFactory = require('../src/client/PlateFillerFactory.coffee').PlateFillerFactory

describe "PlateFillerFactory", ->
  it "should exist", ->
    plateFillerFactory = new PlateFillerFactory()
    expect(plateFillerFactory).toBeTruthy()