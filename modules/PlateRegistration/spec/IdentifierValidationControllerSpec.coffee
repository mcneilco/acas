$ = require('jquery')
_ = require('lodash')

IdentifierValidationController = require('../src/client/IdentifierValidationController.coffee').IdentifierValidationController
AddContentModel = require('../src/client/AddContentModel.coffee').AddContentModel

describe "IdentifierValidationController", ->
  beforeEach ->
    @identifierValidationController = new IdentifierValidationController({addContentModel: new AddContentModel(), successCallback: () ->})

  it "should exist", ->
    expect(@identifierValidationController).toBeTruthy()