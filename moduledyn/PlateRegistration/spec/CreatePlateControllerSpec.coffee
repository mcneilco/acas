CreatePlateController = require('../src/client/CreatePlateController.coffee').CreatePlateController
CREATE_PLATE_CONTROLLER_EVENTS = require('../src/client/CreatePlateController.coffee').CREATE_PLATE_CONTROLLER_EVENTS
PlateModel = require('../src/client/PlateModel.coffee').PlateModel
PlateTypeCollection = require('../src/client/PlateTypeCollection.coffee').PlateTypeCollection
fixtures = require('./testFixtures/CreatePlateFixtures.coffee')

fdescribe "CreatePlateController", ->
  beforeEach ->
    fixture = '<div id="fixture"></div>'
    document.body.insertAdjacentHTML('afterbegin', fixture)
    @startUpParams = {}
    @model = new PlateModel()
    @startUpParams =
      model: @model
      plateTypes: new PlateTypeCollection()
    @createPlateController = new CreatePlateController(@startUpParams)

  it "should exist", ->
    expect(@createPlateController).toBeTruthy()

  describe "template content", ->
    beforeEach ->
      $("#fixture").html @createPlateController.render().el

    it "should have a template property", ->
      expect(@createPlateController.template).toBeTruthy()

    it "should have a pair of 'template' / plate radio buttons ", ->
      expect(_.size($("#fixture").find("input[name='template'][type='radio']"))).toEqual 2

    it "should have a plate definition select list", ->
      expect(_.size($("#fixture").find("select[name='definition']"))).toEqual 1

    it "should have a plate barcode text input", ->
      expect(_.size($("#fixture").find("input[name='barcode']"))).toEqual 1

    it "should have a plate description text input", ->
      expect(_.size($("#fixture").find("input[name='description']"))).toEqual 1

    it "should have a submit button", ->
      expect(_.size($("#fixture").find("button[name='submit']"))).toEqual 1

  describe "fields", ->
    it "should have a PlateTypeCollection field", ->
      expect(@createPlateController.plateTypes instanceof PlateTypeCollection).toBeTruthy()