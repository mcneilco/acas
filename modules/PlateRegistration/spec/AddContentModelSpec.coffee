AddContentModel = require('../src/client/AddContentModel.coffee').AddContentModel
ADD_CONTENT_MODEL_FIELDS = require('../src/client/AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS
fixtures = require("./testFixtures/AddContentModelFixtures.coffee")

describe "AddContentModel", ->
  it "should exist", ->
    addContent = new AddContentModel()
    expect(addContent).toBeTruthy()

  describe "ADD_CONTENT_MODEL_FIELDS", ->
    it "should have a identifierType field", ->
      expect(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE).toEqual('identifierType')

    it "should have a identifiers field", ->
      expect(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS).toEqual('identifiers')

    it "should have an amount field", ->
      expect(ADD_CONTENT_MODEL_FIELDS.AMOUNT).toEqual('amount')

    it "should have a concentration field", ->
      expect(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION).toEqual('batchConcentration')

    it "should have a fillStrategy field", ->
      expect(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY).toEqual('fillStrategy')

    it "should have a fillDirection field", ->
      expect(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION).toEqual('fillDirection')

    it "should have a wells field", ->
      expect(ADD_CONTENT_MODEL_FIELDS.WELLS).toEqual('wells')




  describe "defaults", ->
    beforeEach ->
      @addContent = new AddContentModel()
    it "should have an empty 'identifierType' field", ->
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE)).toBeDefined()
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE)).toEqual('compoundBatchId')

    it "should have an empty 'identifiers' field", ->
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS)).toBeDefined()
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS)).toEqual('')

    it "should have an empty 'volume' field", ->
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.AMOUNT)).toBeDefined()
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.AMOUNT)).toEqual('')

    it "should have an empty 'concentration' field", ->
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION)).toBeDefined()
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION)).toEqual('')

    it "should have an empty 'fillStrategy' field", ->
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY)).toBeDefined()
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY)).toEqual('inOrder')

    it "should have an empty 'fillDirection' field", ->
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION)).toBeDefined()
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION)).toEqual('rowMajor')

    it "should have an empty 'wells' field", ->
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.WELLS)).toBeDefined()
      expect(@addContent.get(ADD_CONTENT_MODEL_FIELDS.WELLS)).toEqual('')

  describe "validation", ->
    beforeEach ->
      @addContent = new AddContentModel(fixtures.validAddContentModel)

    it "should require 'identifierType' to be set and non-empty", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE, "")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE, "identifierType")
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require at least one of the following fields to be set and non-empty: 'batchConcentration', 'identifiers', 'amount'", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION, "")
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.AMOUNT, "")
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS, [])
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION, 10)
      expect(@addContent.isValid(true)).toBeTruthy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION, "")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.AMOUNT, 100)
      expect(@addContent.isValid(true)).toBeTruthy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.AMOUNT, "")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS, ["DNS1"])
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require the 'amount' field to be a number", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION, 10)
      expect(@addContent.isValid(true)).toBeTruthy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.AMOUNT, "five hundred")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.AMOUNT, 500)
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require the 'batchConcentration' field to be a number", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.AMOUNT, 10)
      expect(@addContent.isValid(true)).toBeTruthy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION, "five hundred")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION, 500)
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require 'fillStrategy' to be set and non-empty", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, "")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, "fillStrategy")
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require 'fillDirection' to be set and non-empty", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION, "")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION, "fillDirection")
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require that at least one cell is selected in the plate layout table", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS, 0)
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, 0)
      expect(@addContent.isValid(true)).toBeFalsy()

      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, 1)
      expect(@addContent.isValid(true)).toBeTruthy()

    it "if the user enters any identifiers and selects either 'Fill region in order' or 'Fill region in random order', it should require the number of entered identifiers to equal the number of selected wells", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, 5)
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS, 3)
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, "inOrder")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS, 5)
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require that the user enter only 1 identifier if the 'Fill Region with Same Batch ID' option is selected", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS, 3)
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, "sameIdentifier")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS, 1)
      expect(@addContent.isValid(true)).toBeTruthy()

    it "should require that the user enter 1 identifier if the 'Fill Region with Same Batch ID' option is selected", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS, 0)
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, "sameIdentifier")
      expect(@addContent.isValid(true)).toBeFalsy()
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS, 1)
      expect(@addContent.isValid(true)).toBeTruthy()

  xdescribe "error messages", ->
    beforeEach ->
      @addContent = new AddContentModel(fixtures.validAddContentModel)

    it "should alert the user that 'identifierType' is required", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE, "")
      errorMessages = @addContent.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE]).toEqual "Please select an identifier type"

    it "should alert the user that 'identifiers' is required", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS, "")
      errorMessages = @addContent.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS]).toEqual "Please enter at least one identifier"

    it "should alert the user that 'volume' is required", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.VOLUME, "")
      errorMessages = @addContent.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[ADD_CONTENT_MODEL_FIELDS.VOLUME]).toEqual "Please enter the volume"

    it "should alert the user that 'concentration' is required", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.CONCENTRATION, "")
      errorMessages = @addContent.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[ADD_CONTENT_MODEL_FIELDS.CONCENTRATION]).toEqual "Please enter the concentration"

    it "should alert the user that 'fillStrategy' is required", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, "")
      errorMessages = @addContent.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY]).toEqual "Please select a fill strategy"

    it "should alert the user that 'fillDirection' is required", ->
      @addContent.set(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION, "")
      errorMessages = @addContent.validate()
      expect(_.size(errorMessages)).toEqual 1
      expect(errorMessages[ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION]).toEqual "Please select a fill direction"