$ = require('jquery')
_ = require('lodash')

AddContentIdentifierValidationController = require('../src/client/IdentifierValidationController.coffee').AddContentIdentifierValidationController
PlateTableIdentifierValidationController = require('../src/client/IdentifierValidationController.coffee').PlateTableIdentifierValidationController
AddContentModel = require('../src/client/AddContentModel.coffee').AddContentModel

describe "AddContentIdentifierValidationController", ->
  beforeEach ->
    @addContentIdentifierValidationController = new AddContentIdentifierValidationController({addContentModel: new AddContentModel(), successCallback: () ->})

  it "should exist", ->
    expect(@addContentIdentifierValidationController).toBeTruthy()

describe "PlateTableIdentifierValidationController", ->
  beforeEach ->
    @plateTableIdentifierValidationController = new PlateTableIdentifierValidationController({addContentModel: new AddContentModel(), successCallback: () ->})

  it "should exist", ->
    expect(@plateTableIdentifierValidationController).toBeTruthy()