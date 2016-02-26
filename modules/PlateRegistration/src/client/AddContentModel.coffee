_ = require('lodash')
Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);

IDENTIFIER_LIST_DELIMETER = ","

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


class AddContentModel extends Backbone.Model
  defaults:
    identifierType: ""
    identifiers: ""
    identifiersDisplayString: ""
    amount: ""
    batchConcentration: ""
    fillStrategy: ""
    fillDirection: ""
    wells: ""
    numberOfIdentifiers: 0
    numberOfCellsSelected: 0

  validation:
    identifierType:
      required: true
      msg: "Please select an identifier type"
    identifiers:
      required: true
      msg: "Please enter at least one identifier"
    volume:
      required: true
      msg: "Please enter the volume"
    concentration:
      required: true
      msg: "Please enter the concentration"
    fillStrategy:
      required: true
      msg: "Please select a fill strategy"
    fillDirection:
      required: true
      msg: "Please select a fill direction"

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



module.exports =
  AddContentModel: AddContentModel
  ADD_CONTENT_MODEL_FIELDS: ADD_CONTENT_MODEL_FIELDS