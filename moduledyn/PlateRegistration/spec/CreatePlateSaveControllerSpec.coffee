$ = require('jquery')
_ = require('lodash')

CreatePlateSaveController = require('../src/client/CreatePlateSaveController.coffee').CreatePlateSaveController
PlateModel = require('../src/client/PlateModel.coffee').PlateModel

describe "CreatePlateSaveController", ->
  beforeEach ->
    @createPlateSaveController = new CreatePlateSaveController({plateModel: new PlateModel()})

  it "should exist", ->
    expect(@createPlateSaveController).toBeTruthy()