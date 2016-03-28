NewPlateDesignController = require('../src/client/NewPlateDesignController.coffee').NewPlateDesignController
NEW_PLATE_DESIGN_CONTROLLER_EVENTS = require('../src/client/NewPlateDesignController.coffee').NEW_PLATE_DESIGN_CONTROLLER_EVENTS

PlateViewController = require('../src/client/PlateViewController.coffee').PlateViewController
PlateInfoController = require('../src/client/PlateInfoController.coffee').PlateInfoController
PlateInfoModel = require('../src/client/PlateInfoModel.coffee').PlateInfoModel
EditorFormTabViewController = require('../src/client/EditorFormTabViewController.coffee').EditorFormTabViewController

ADD_CONTENT_CONTROLLER_EVENTS = require('../src/client/AddContentController.coffee').ADD_CONTENT_CONTROLLER_EVENTS
AddContentController = require('../src/client/AddContentController.coffee').AddContentController
TemplateController = require('../src/client/TemplateController.coffee').TemplateController
SerialDilutionController = require('../src/client/SerialDilutionController.coffee').SerialDilutionController

#PLATE_INFO_CONTROLLER_EVENTS = require('../src/client/PlateInfoController.coffee').PLATE_INFO_CONTROLLER_EVENTS


$ = require('jquery')
_ = require('lodash')


describe "NewPlateDesignController", ->
  beforeEach ->
    fixture = '<div id="fixture"></div>';
    document.body.insertAdjacentHTML('afterbegin', fixture)
    @startUpParams = {}
  it "should exist", ->
    newPlateDesign = new NewPlateDesignController(@startUpParams)
    expect(newPlateDesign).toBeTruthy()

  describe "template content", ->
    beforeEach ->
      @newPlateDesign = new NewPlateDesignController(@startUpParams)
      $("#fixture").html @newPlateDesign.render().el

    it "should have a template property", ->
      expect(@newPlateDesign.template).toBeTruthy()

    it "should have an editorNav container div", ->
      expect(_.size($("#fixture").find(".editorNav"))).toEqual 1

    it "should have an plateViewContainer container div", ->
      expect(_.size($("#fixture").find("[name='plateViewContainer']"))).toEqual 1


  describe "fields", ->
    beforeEach ->
      @newPlateDesign = new NewPlateDesignController(@startUpParams)
      $("#fixture").html @newPlateDesign.render().el

    it "should have a PlateViewController instance variable", ->
      expect(@newPlateDesign.plateViewController).toBeTruthy()
      expect(@newPlateDesign.plateViewController instanceof PlateViewController).toBeTruthy()

    it "should have a PlateInfoController instance variable", ->
      expect(@newPlateDesign.plateInfoController).toBeTruthy()
      expect(@newPlateDesign.plateInfoController instanceof PlateInfoController).toBeTruthy()

    it "should have an AddContentController instance variable", ->
      expect(@newPlateDesign.addContentController).toBeTruthy()
      expect(@newPlateDesign.addContentController instanceof AddContentController).toBeTruthy()

    it "should have a TemplateController instance variable", ->
      expect(@newPlateDesign.templateController).toBeTruthy()
      expect(@newPlateDesign.templateController instanceof TemplateController).toBeTruthy()

    it "should have a SerialDilutionController instance variable", ->
      expect(@newPlateDesign.serialDilutionController).toBeTruthy()
      expect(@newPlateDesign.serialDilutionController instanceof SerialDilutionController).toBeTruthy()

    it "should have an EditorFormTabViewController instance variable", ->
      expect(@newPlateDesign.editorFormsTabView).toBeTruthy()
      expect(@newPlateDesign.editorFormsTabView instanceof EditorFormTabViewController).toBeTruthy()


  describe "event handlers", ->
    beforeEach ->
      @newPlateDesign = new NewPlateDesignController(@startUpParams)
      $("#fixture").html @newPlateDesign.render().el
      @newPlateDesign.plateViewController.completeInitialization = (plate) ->
        console.log "plateViewController::completeInitialization"
      @newPlateDesign.completeInitialization(new PlateInfoModel())

    it "should emit NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT when 'handleAddContent' is called", (done) ->

      @newPlateDesign.on NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT, ->
        expect(true).toBeTruthy()
        done()

      @newPlateDesign.handleAddContent([[1,2,3]])
#      _.defer(=>
#        expect(@newPlateDesign.handleAddContent).toHaveBeenCalled()
#        done()
#      )
#
#  describe "UI event handlers", ->
#    beforeEach ->
#      @newPlateDesign = new NewPlateDesignController(@startUpParams)
#      $("#fixture").html @newPlateDesign.render().el
#
#    xit "should call handleDeleteClick when the 'Delete' button is clicked", (done) ->
#      spyOn(@newPlateDesign, 'handleDeleteClick')
#      @newPlateDesign.delegateEvents()
#      $("#fixture").find("[name='delete']").click()
#      _.defer(=>
#        expect(@newPlateDesign.handleDeleteClick).toHaveBeenCalled()
#        done()
#      )
#
#  describe "emitted events", ->
#    beforeEach ->
#      @newPlateDesign = new NewPlateDesignController(@startUpParams)
#      $("#fixture").html @newPlateDesign.render().el
#
#    xit "should emit a DELETE_PLATE event when the 'Delete' button is clicked", (done) ->
#      @newPlateDesign.on PLATE_INFO_CONTROLLER_EVENTS.DELETE_PLATE, ->
#        expect(true).toBeTruthy()
#        done()
#
#      @newPlateDesign.handleDeleteClick()