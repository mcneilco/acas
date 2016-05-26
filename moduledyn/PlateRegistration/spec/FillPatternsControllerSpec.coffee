$ = require('jquery')
_ = require('lodash')

FillPatternsController = require('../src/client/FillPatternsController.coffee').FillPatternController

describe "FillPatternsController", ->
  beforeEach ->
    @fillPatternsController = new FillPatternsController({model: {}})

  it "should exist", ->
    expect(@fillPatternsController).toBeTruthy()