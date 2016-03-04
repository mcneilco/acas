PlateInfoModel = require('../src/client/PlateInfoModel.coffee').PlateInfoModel
PLATE_INFO_MODEL_FIELDS = require('../src/client/PlateInfoModel.coffee').PLATE_INFO_MODEL_FIELDS
fixtures = require("./testFixtures/PlateModelFixtures.coffee")

describe "PlateInfoModel", ->
  it "should exist", ->
    plateInfo = new PlateInfoModel()
    expect(plateInfo).toBeTruthy()

  describe "PLATE_INFO_MODEL_FIELDS", ->
    it "should have a plateBarcode field", ->
      expect(PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE).toEqual('plateBarcode')

    it "should have a description field", ->
      expect(PLATE_INFO_MODEL_FIELDS.DESCRIPTION).toEqual('description')

    it "should have a plateSize field", ->
      expect(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE).toEqual('plateSize')

    it "should have a type field", ->
      expect(PLATE_INFO_MODEL_FIELDS.TYPE).toEqual('type')

    it "should have a status field", ->
      expect(PLATE_INFO_MODEL_FIELDS.STATUS).toEqual('status')

    it "should have a createdDate field", ->
      expect(PLATE_INFO_MODEL_FIELDS.CREATED_DATE).toEqual('createdDate')

    it "should have a supplier field", ->
      expect(PLATE_INFO_MODEL_FIELDS.SUPPLIER).toEqual('supplier')

  describe "defaults", ->
    beforeEach ->
      @plateInfo = new PlateInfoModel()
    it "should have an empty plateBarcode field", ->
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE)).toBeDefined()
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE)).toEqual('')

    it "should have an empty description field", ->
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.DESCRIPTION)).toBeDefined()
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.DESCRIPTION)).toEqual('')

    it "should have an empty plateSize field", ->
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE)).toBeDefined()
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE)).toEqual('')

    it "should have an empty type field", ->
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.TYPE)).toBeDefined()
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.TYPE)).toEqual('')

    it "should have an empty status field", ->
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.STATUS)).toBeDefined()
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.STATUS)).toEqual('')

    it "should have an empty createdDate field", ->
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.CREATED_DATE)).toBeDefined()
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.CREATED_DATE)).toEqual('')

    it "should have an empty supplier field", ->
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.SUPPLIER)).toBeDefined()
      expect(@plateInfo.get(PLATE_INFO_MODEL_FIELDS.SUPPLIER)).toEqual('')

  describe "validation", ->
    beforeEach ->
      @plateInfo = new PlateInfoModel(fixtures.validPlateInfoModel)

    it "should require plateBarcode to be set and non-empty", ->
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE, "")
      expect(@plateInfo.isValid(true)).toBeFalsy()
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE, "plate barcode")
      expect(@plateInfo.isValid(true)).toBeTruthy()

    it "should require plateSize to be set", ->
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE, null)
      expect(@plateInfo.isValid(true)).toBeFalsy()
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE, 1)
      expect(@plateInfo.isValid(true)).toBeTruthy()

    it "should require plateSize to be numeric", ->
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE, "my plate")
      expect(@plateInfo.isValid(true)).toBeFalsy()
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE, 1)
      expect(@plateInfo.isValid(true)).toBeTruthy()

    it "should require status to be set", ->
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.STATUS, null)
      expect(@plateInfo.isValid(true)).toBeFalsy()
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.STATUS, 'status')
      expect(@plateInfo.isValid(true)).toBeTruthy()

  describe "error messages", ->
    beforeEach ->
      @plateInfo = new PlateInfoModel(fixtures.validPlateInfoModel)

    it "should alert the user that plateBarcode is required", ->
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE, "")
      errorMessages = @plateInfo.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[PLATE_INFO_MODEL_FIELDS.PLATE_BARCODE]).toEqual "Please enter a valid Plate Barcode"

    it "should alert the user that plateSize is required and must be numeric", ->
      @plateInfo.set(PLATE_INFO_MODEL_FIELDS.PLATE_SIZE, "")
      errorMessages = @plateInfo.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[PLATE_INFO_MODEL_FIELDS.PLATE_SIZE]).toEqual "Plate Size must be numeric"
