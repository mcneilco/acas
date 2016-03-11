$ = require('jquery')
_ = require('lodash')

WellModel = require('../src/client/WellModel.coffee').WellModel

describe "WellModel", ->
  beforeEach ->
    @wellModel = new WellModel()

  it "should exist", ->
    expect(@wellModel).toBeTruthy()