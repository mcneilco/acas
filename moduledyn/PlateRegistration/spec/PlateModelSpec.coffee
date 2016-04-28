$ = require('jquery')
_ = require('lodash')

PlateModel = require('../src/client/PlateModel.coffee').PlateModel

describe "PlateModel", ->
  beforeEach ->
    @plateModel = new PlateModel()

  it "should exist", ->
    expect(@plateModel).toBeTruthy()