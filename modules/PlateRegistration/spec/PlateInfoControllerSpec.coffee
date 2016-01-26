PlateInfoController = require('../src/client/PlateInfoController.coffee').PlateInfoController
PLATE_INFO_CONTROLLER_EVENTS = require('../src/client/PlateInfoController.coffee').PLATE_INFO_CONTROLLER_EVENTS
PlateTypeCollection = require('../src/client/PlateTypeCollection.coffee').PlateTypeCollection
PlateStatusCollection = require('../src/client/PlateStatusCollection.coffee').PlateStatusCollection
PlateInfoModel = require('../src/client/PlateInfoModel.coffee').PlateInfoModel
PLATE_INFO_MODEL_FIELDS = require('../src/client/PlateInfoModel.coffee').PLATE_INFO_MODEL_FIELDS

$ = require('jquery')
_ = require('lodash')

beforeEach ->
  fixture = '<div id="fixture"></div>';

  document.body.insertAdjacentHTML('afterbegin', fixture);

afterEach ->
  #$("#fixture").remove()

describe "PlateInfoController", ->
  it "should exist", ->
    plateInfo = new PlateInfoController({plateTypes: {}, plateStatuses: {}})
    expect(plateInfo).toBeTruthy()

  describe "template content", ->
    beforeEach ->
      @plateInfo = new PlateInfoController({plateTypes: {}, plateStatuses: {}})
      $("#fixture").html @plateInfo.render().el

    it "should have a template property", ->
      expect(@plateInfo.template).toBeTruthy()

    it "should have a plateBarcode text input field", ->
      expect(_.size($("#fixture").find("[name='plateBarcode']"))).toEqual 1

    it "should have a description text input field", ->
      expect(_.size($("#fixture").find("[name='description']"))).toEqual 1

    it "should have a plateSize text input field", ->
      expect(_.size($("#fixture").find("[name='plateSize']"))).toEqual 1

    it "should have a type text input field", ->
      expect(_.size($("#fixture").find("[name='type']"))).toEqual 1

    it "should have a status text input field", ->
      expect(_.size($("#fixture").find("[name='status']"))).toEqual 1

    it "should have a createdDate text input field", ->
      expect(_.size($("#fixture").find("[name='createdDate']"))).toEqual 1

    it "should have a supplier text input field", ->
      expect(_.size($("#fixture").find("[name='supplier']"))).toEqual 1

    it "should have a 'Create Quad-Pinned Plate' button", ->
      expect(_.size($("#fixture").find("[name='createQuadPinnedPlate']"))).toEqual 1

    it "should have a 'Delete' button", ->
      expect(_.size($("#fixture").find("[name='delete']"))).toEqual 1

  describe "fields", ->
    beforeEach ->
      @model = new PlateInfoModel()
      @plateInfo = new PlateInfoController({plateTypes: new PlateTypeCollection(), plateStatuses: new PlateStatusCollection(), model: @model})
      $("#fixture").html @plateInfo.render().el
    it "should have a PlateTypeCollection ", ->
      expect(@plateInfo.plateTypes).toBeTruthy()
      expect(@plateInfo.plateTypes instanceof PlateTypeCollection).toBeTruthy()

    it "should have a PlateStatusCollection ", ->
      expect(@plateInfo.plateStatuses).toBeTruthy()
      expect(@plateInfo.plateStatuses instanceof PlateStatusCollection).toBeTruthy()

    it "should have a PlateInfoModel model attribute ", ->
      expect(@plateInfo.model).toBeTruthy()
      expect(@plateInfo.model instanceof PlateInfoModel).toBeTruthy()

  describe "input events", ->
    beforeEach ->
      @model = new PlateInfoModel()
      @plateInfo = new PlateInfoController({plateTypes: new PlateTypeCollection(), plateStatuses: new PlateStatusCollection(), model: @model})
      $("#fixture").html @plateInfo.render().el

    it "should update the plateBarcode field of the model when text is entered in the Plate Barcode input field", ->
      updatedValue = "updated barcode value"
      $("#fixture").find("[name='plateBarcode']").val updatedValue
      $("#fixture").find("[name='plateBarcode']").trigger "change"
      expect(@model.get(PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE)).toEqual updatedValue

    it "should update the plateBarcode field of the model when text is entered in the Plate Barcode input field", ->
      updatedValue = "updated description value"
      $("#fixture").find("[name='description']").val updatedValue
      $("#fixture").find("[name='description']").trigger "change"
      expect(@model.get(PLATE_INFO_MODEL_FIELDS.DESCRIPTION)).toEqual updatedValue

    it "should update the plateBarcode field of the model when text is entered in the Plate Barcode input field", ->
      updatedValue = "updated plateSize value"
      $("#fixture").find("[name='plateSize']").val updatedValue
      $("#fixture").find("[name='plateSize']").trigger "change"
      expect(@model.get(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE)).toEqual updatedValue

    it "should update the plateBarcode field of the model when text is entered in the Plate Barcode input field", ->
      updatedValue = "updated createdDate value"
      $("#fixture").find("[name='createdDate']").val updatedValue
      $("#fixture").find("[name='createdDate']").trigger "change"
      expect(@model.get(PLATE_INFO_MODEL_FIELDS.CREATED_DATE)).toEqual updatedValue

    it "should update the plateBarcode field of the model when text is entered in the Plate Barcode input field", ->
      updatedValue = "updated supplier value"
      $("#fixture").find("[name='supplier']").val updatedValue
      $("#fixture").find("[name='supplier']").trigger "change"
      expect(@model.get(PLATE_INFO_MODEL_FIELDS.SUPPLIER)).toEqual updatedValue

  describe "UI event handlers", ->
    beforeEach ->
      @model = new PlateInfoModel()
      @plateInfo = new PlateInfoController({plateTypes: new PlateTypeCollection(), plateStatuses: new PlateStatusCollection(), model: @model})
      $("#fixture").html @plateInfo.render().el

    it "should call handleDeleteClick when the 'Delete' button is clicked", (done) ->
      spyOn(@plateInfo, 'handleDeleteClick')
      @plateInfo.delegateEvents()
      $("#fixture").find("[name='delete']").click()
      _.defer(=>
        expect(@plateInfo.handleDeleteClick).toHaveBeenCalled()
        done()
      )

    it "should call 'handleCreateQuadPinnedClick' when the 'Create Quad-Pinned Plate' button is clicked", (done) ->
      spyOn(@plateInfo, 'handleCreateQuadPinnedPlateClick')
      @plateInfo.delegateEvents()
      $("#fixture").find("[name='createQuadPinnedPlate']").click()
      _.defer(=>
        expect(@plateInfo.handleCreateQuadPinnedPlateClick).toHaveBeenCalled()
        done()
      )

  describe "emitted events", ->
    beforeEach ->
      @model = new PlateInfoModel()
      @plateInfo = new PlateInfoController({plateTypes: new PlateTypeCollection(), plateStatuses: new PlateStatusCollection(), model: @model})
      $("#fixture").html @plateInfo.render().el

    it "should emit a DELETE_PLATE event when the 'Delete' button is clicked", (done) ->
      @plateInfo.on PLATE_INFO_CONTROLLER_EVENTS.DELETE_PLATE, ->
        expect(true).toBeTruthy()
        done()

      @plateInfo.handleDeleteClick()


    it "should emit a PLATE_INFO_CONTROLLER_EVENTS.CREATE_QUAD_PINNED_PLATE event when 'handleCreateQuadPinnedClick' is called", (done)->
      @plateInfo.on PLATE_INFO_CONTROLLER_EVENTS.CREATE_QUAD_PINNED_PLATE, ->
        expect(true).toBeTruthy()
        done()

      @plateInfo.handleCreateQuadPinnedPlateClick()

    describe "model validation events", ->
      it "should trigger a model:invalid event when the form model is updated to an invalid state", ->
