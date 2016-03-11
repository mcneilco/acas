$ = require('jquery')
_ = require('lodash')

DataServiceController = require('../src/client/DataServiceController.coffee').DataServiceController

describe "DataServiceController", ->
  beforeEach ->
    @dataServiceController = new DataServiceController()

  it "should exist", ->
    expect(@dataServiceController).toBeTruthy()

