$ = require('jquery')
_ = require('lodash')

ClonePlateController = require('../src/client/ClonePlateController.coffee').ClonePlateController

describe "ClonePlateController", ->
  beforeEach ->
    options =
      clonePlateBarcode: 'barcode 1'
      sourcePlateBarcode: 'source barcode 1'
    @clonePlateController = new ClonePlateController(options)

  it "should exist", ->
    expect(@clonePlateController).toBeTruthy()