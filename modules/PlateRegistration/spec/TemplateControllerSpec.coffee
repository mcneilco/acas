TemplateController = require('../src/client/TemplateController.coffee').TemplateController

$ = require('jquery')
_ = require('lodash')


describe "TemplateController", ->
  beforeEach ->
    fixture = '<div id="fixture"></div>';
    document.body.insertAdjacentHTML('afterbegin', fixture)
    @startUpParams = {}
  it "should exist", ->
    templateController = new TemplateController(@startUpParams)
    expect(templateController).toBeTruthy()

  describe "template content", ->
    beforeEach ->
      @templateController = new TemplateController(@startUpParams)
      $("#fixture").html @templateController.render().el

    it "should have a template property", ->
      expect(@templateController.template).toBeTruthy()

  describe "fields", ->
    beforeEach ->
      @templateController = new TemplateController(@startUpParams)
      $("#fixture").html @templateController.render().el



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
#
#  describe "events", ->
#    beforeEach ->
#      @plateView = new PlateViewController(@startUpParams)
#      $("#fixture").html @plateView.render().el
#      @plateView.completeInitialization()
#
#    describe "REGION_SELECTED", ->
#      it "should call 'handleRegionSelected' when plateTableController triggers 'REGION_SELECTED' event", (done) ->
#        spyOn(@plateView, 'handleRegionSelected')
#        @plateView.delegateEvents()
#        @plateView.plateTableController.trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED
#
#        _.defer( =>
#          expect(@plateView.handleRegionSelected).toHaveBeenCalled()
#          done()
#        )