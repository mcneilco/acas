$ = require('jquery')
_ = require('lodash')

MergePlatesController = require('../src/client/MergePlateController.coffee').MergePlatesController


describe "MergePlatesController", ->
  beforeEach ->
    @mergePlatesController = new MergePlatesController()

  it "should exist", ->
    expect(@mergePlatesController).toBeTruthy()