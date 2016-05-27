$ = require('jquery')
_ = require('lodash')

SplitPlatesController = require('../src/client/SplitPlateController.coffee').SplitPlatesController


describe "SplitPlatesController", ->
  beforeEach ->
    @splitPlatesController = new SplitPlatesController()

  it "should exist", ->
    expect(@splitPlatesController).toBeTruthy()