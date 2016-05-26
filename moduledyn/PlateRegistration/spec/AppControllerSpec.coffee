$ = require('jquery')
_ = require('lodash')

plateAndWellData =
  wellContent: []
  plateMetadata: {}

AppController = require('../src/client/AppController.coffee').AppController

describe "AppController", ->
  beforeEach ->
    @mockFetch = (cb) ->
      cb.success()
    window.AppLaunchParams = {
      loginUser: 'bob'
    }
    fixture = '<div id="fixture"></div>'
    document.body.insertAdjacentHTML('afterbegin', fixture)
    @appController = new AppController()

  it "should exist", ->
    expect(@appController).toBeTruthy()

  describe "rendering sub-app views", ->
    beforeEach ->
      $("#fixture").html @appController.render().el
    describe "displayPlateSearch", ->
      beforeEach ->
        @appController.plateSearchController.plateStatuses.fetch = @mockFetch
        @appController.plateSearchController.plateTypes.fetch = @mockFetch
        @appController.plateSearchController.plateDefinitions.fetch = @mockFetch
        @appController.plateSearchController.users.fetch = @mockFetch
        @appController.displayPlateSearch()
      it "should display the plate search form", ->
        expect($(".moduleTitle")).toContainText "Search for Plates"

    xdescribe "displayPlateDesignForm", ->
      beforeEach ->
        @appController.newPlateDesignController.plateStatuses.fetch = @mockFetch
        @appController.newPlateDesignController.plateTypes.fetch = @mockFetch
        @appController.handleAllDataLoadedForPlateDesignForm(plateAndWellData)
      it "should display the plate search form", ->
        expect($(".moduleTitle")).toContainText "Plate Registration"

    describe "displayMergeOrSplitPlatesForm", ->
      beforeEach ->

        @appController.displayMergeOrSplitPlatesForm()
      it "should display the plate search form", ->
        expect($(".moduleTitle")).toContainText "Merge or Split Plates"

    describe "displayCreatePlateForm", ->
      beforeEach ->
        @appController.createPlateController.plateDefinitions.fetch = @mockFetch
        @appController.displayCreatePlateForm()

      it "should display the plate creation form ", ->
        expect($(".moduleTitle")).toContainText "New Plate"
