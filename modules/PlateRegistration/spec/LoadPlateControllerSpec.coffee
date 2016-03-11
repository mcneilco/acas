$ = require('jquery')
_ = require('lodash')

LoadPlateController = require('../src/client/LoadPlateController.coffee').LoadPlateController

describe "LoadPlateController", ->
  beforeEach ->
    @loadPlateController = new LoadPlateController()

  it "should exist", ->
    expect(@loadPlateController).toBeTruthy()