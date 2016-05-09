$ = require('jquery')
_ = require('lodash')

LoadPlateController = require('../src/client/LoadPlateController.coffee').LoadPlateController

describe "LoadPlateController", ->
  beforeEach ->
    options =
      plateBarcode: "plateBarcode"
    @loadPlateController = new LoadPlateController(options)

  it "should exist", ->
    expect(@loadPlateController).toBeTruthy()