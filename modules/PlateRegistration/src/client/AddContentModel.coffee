_ = require('lodash')
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
    amount:
      required: false
      pattern: "number"
      msg: "Please enter numeric value for amount"
    batchConcentration:
      required: false
      pattern: "number"
      msg: "Please enter numeric value for concentration"
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
    #console.log "computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS]"
    #console.log computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS]
    if computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] > 0
      unless computedState[ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY] is "sameIdentifier"
        if computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED] isnt computedState[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS]
          console.log "num selected wells and num identifiers mismatch"
          return "The number of selected wells must be the same as the number of identifiers entered"

  formatIdentifiersForValidationService: ->
    identifiers = _.reduce(@get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS), (memo, identifier) ->
      return memo + identifier + IDENTIFIER_LIST_DELIMETER
    , "")

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