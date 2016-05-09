$ = require('jquery')
_ = require('lodash')

AppController = require('../src/client/AppController.coffee').AppController

describe "AppController", ->
  beforeEach ->
    window.AppLaunchParams = {}
    @appController = new AppController()

  it "should exist", ->
    expect(@appController).toBeTruthy()