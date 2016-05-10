_ = require('lodash')
$ = require('jquery')

Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);

IDENTIFIER_LIST_DELIMETER = ";"

ADD_CONTENT_MODEL_FIELDS =
  IDENTIFIER_TYPE: 'identifierType'
  IDENTIFIERS: 'identifiers'
  IDENTIFIERS_DISPLAY_STRING: 'identifiersDisplayString'
  AMOUNT: 'amount'
  BATCH_CONCENTRATION: 'batchConcentration'
  FILL_STRATEGY: 'fillStrategy'
  FILL_DIRECTION: 'fillDirection'
  WELLS: 'wells'
  NUMBER_OF_IDENTIFIERS: 'numberOfIdentifiers'
  NUMBER_OF_CELLS_SELECTED: 'numberOfCellsSelected'
  VALIDATED_IDENTIFIERS: 'validatedIdentifiers'
  VALID_IDENTIFIERS: 'validIdentifiers'
  ALIASED_IDENTIFIERS: 'aliasedIdentifiers'
  INVALID_IDENTIFIERS: 'invalidIdentifiers'
  WELLS_TO_UPDATE: 'wellsToUpdate'


class AddContentModel extends Backbone.Model
  defaults:
    identifierType: "compoundBatchId"
    identifiers: ""
    identifiersDisplayString: ""
    amount: ""
    batchConcentration: ""
    fillStrategy: "inOrder"
    fillDirection: "rowMajor"
    wells: ""
    numberOfIdentifiers: 0
    numberOfCellsSelected: 0

  validation:
    identifierType:
      required: true
      msg: "Please select an identifier type"
    amount: (value) ->
      value = @formatNumericValue(value)
      if isNaN value
        return "Please enter numeric value for amount"
    batchConcentration: (value) ->
      value = @formatNumericValue(value)
      if isNaN value
        return "Please enter numeric value for concentration"
    fillStrategy:
      required: true
      msg: "Please select a fill strategy"
    numberOfCellsSelected:
      min: 1
    fillDirection:
      required: true
      msg: "Please select a fill direction"
    wellValues: 'validateWellValues'
    identifiers: 'validateIdentifiers'

  validateWellValues: (value, attr, computedState) ->
    if computedState[ADD_CONTENT_MODEL_FIELDS.BATCH_CONCENTRATION] is "" and computedState[ADD_CONTENT_MODEL_FIELDS.AMOUNT] is "" and computedState[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS].length is 0
      return "An identifier, concentration value, or amount must be specified"

  validateIdentifiers: (value, attr, computedState) ->
    if computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] > 0
      if computedState[ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY] is "sameIdentifier"
        if computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] > 1
          return "Only one identifier may be entered when filling the region with the same identifier"
      else
        if computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED] > computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS]
          return "The number of selected wells must be the same or less than the number of identifiers entered"

  formatIdentifiersForBatchIdValidationService: ->
    identifiers = _.map(@get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS), (identifier) ->
      return {requestName: identifier}
    )

    identifiers

  formatNumericValue: (value) ->
    value = $.trim(value)
    if value is ""
      return null
    else
      if value.substring(0,1)  is "."
        value = "0" + value

    value

  formatIdentifiersForBarcodeValidationService: ->
    identifiers = {barcodes: @get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS)}

    identifiers

  removeInsertedIdentifiers: (insertedIdentifiers) =>
    remainingIdentifiers = _.difference(@model.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS), insertedIdentifiers)
    updatedValues = {}
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS] = remainingIdentifiers
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS_DISPLAY_STRING] =  @formatListOfIdentifiersForDisplay(remainingIdentifiers)
    updatedValues[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] =  _.size(remainingIdentifiers)
    @model.set updatedValues

  reset: ->
    @set "amount", ""
    @set "fillStrategy", "inOrder"
    @set "fillDirection", "rowMajor"
    @set "batchConcentration", ""




module.exports =
  AddContentModel: AddContentModel
  ADD_CONTENT_MODEL_FIELDS: ADD_CONTENT_MODEL_FIELDS