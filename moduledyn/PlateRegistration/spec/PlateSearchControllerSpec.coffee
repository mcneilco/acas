$ = require('jquery')
_ = require('lodash')

PlateSearchController = require('../src/client/PlateSearchController.coffee').PlateSearchController

describe "PlateSearchController", ->
  beforeEach ->
    @plateSearchController = new PlateSearchController({plateDefinitions: [], plateTypes: [], plateStatuses: [], users: []})

  it "should exist", ->
    expect(@plateSearchController).toBeTruthy()