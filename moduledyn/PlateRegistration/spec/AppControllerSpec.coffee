$ = require('jquery')
_ = require('lodash')

AppController = require('../src/client/AppController.coffee').AppController

describe "AppController", ->
  beforeEach ->
    @appController = new AppController()

  it "should exist", ->
    expect(@appController).toBeTruthy()