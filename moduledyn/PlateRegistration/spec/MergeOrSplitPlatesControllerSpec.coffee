$ = require('jquery')
_ = require('lodash')

MergeOrSplitPlatesController = require('../src/client/MergeOrSplitPlatesController.coffee').MergeOrSplitPlatesController


describe "MergeOrSplitPlatesController", ->
  beforeEach ->
    @mergeOrSplitPlatesController = new MergeOrSplitPlatesController()

  it "should exist", ->
    expect(@mergeOrSplitPlatesController).toBeTruthy()