PlateViewController = require('../src/client/PlateViewController.coffee').PlateViewController
#PLATE_INFO_CONTROLLER_EVENTS = require('../src/client/PlateInfoController.coffee').PLATE_INFO_CONTROLLER_EVENTS

PlateTableController = require('../src/client/PlateTableController.coffee').PlateTableController
PLATE_TABLE_CONTROLLER_EVENTS = require('../src/client/PlateTableController.coffee').PLATE_TABLE_CONTROLLER_EVENTS

$ = require('jquery')
_ = require('lodash')


describe "PlateViewController", ->
  beforeEach ->
    fixture = '<div id="fixture"></div>';
    document.body.insertAdjacentHTML('afterbegin', fixture)
    @startUpParams = {}
  it "should exist", ->
    plateView = new PlateViewController(@startUpParams)
    expect(plateView).toBeTruthy()

  describe "template content", ->
    beforeEach ->
      @plateView = new PlateViewController(@startUpParams)
      $("#fixture").html @plateView.render().el

    it "should have a template property", ->
      expect(@plateView.template).toBeTruthy()

    it "should have a 'plateTableContainer' div", ->
      expect(_.size($("#fixture").find("[name='plateTableContainer']"))).toEqual 1

    it "should have a 'Cell Zoom' control", ->
      expect(_.size($("#fixture").find("[name='cellZoom']"))).toEqual 1

  describe "fields", ->
    beforeEach ->
      @plateView = new PlateViewController(@startUpParams)
      $("#fixture").html @plateView.render().el

    it "should have a PlateTableController instance variable", ->
      expect(@plateView.plateTableController).toBeTruthy()
      expect(@plateView.plateTableController instanceof PlateTableController).toBeTruthy()



#  describe "UI event handlers", ->
#    beforeEach ->
#      @plateView = new PlateViewController(@startUpParams)
#      $("#fixture").html @plateView.render().el
#
#    xit "should call handleDeleteClick when the 'Delete' button is clicked", (done) ->
#      spyOn(@plateView, 'handleDeleteClick')
#      @plateInfo.delegateEvents()
#      $("#fixture").find("[name='delete']").click()
#      _.defer(=>
#        expect(@plateInfo.handleDeleteClick).toHaveBeenCalled()
#        done()
#      )
#
#  describe "emitted events", ->
#    beforeEach ->
#      @plateView = new PlateViewController(@startUpParams)
#      $("#fixture").html @plateView.render().el
#
#
#    xit "should emit a DELETE_PLATE event when the 'Delete' button is clicked", (done) ->
#      @plateView.on PLATE_INFO_CONTROLLER_EVENTS.DELETE_PLATE, ->
#        expect(true).toBeTruthy()
#        done()
#
#      @plateInfo.handleDeleteClick()

  describe "events", ->
    beforeEach ->
      @plateView = new PlateViewController(@startUpParams)
      $("#fixture").html @plateView.render().el
      @plateView.completeInitialization()

    describe "REGION_SELECTED", ->
      it "should call bubble up / trigger REGION_SELECTED event when plateTableController triggers 'REGION_SELECTED' event", (done) ->
        #spyOn(@plateView, 'handleRegionSelected')
        #@plateView.delegateEvents()
        @plateView.on PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, ->
          expect(true).toBeTruthy()
          done()

        @plateView.plateTableController.trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED
#        _.defer( =>
#          expect(@plateView.handleRegionSelected).toHaveBeenCalled()
#          done()
#        )