Backbone = require('backbone')
_ = require('lodash')
#$ = require('jquery')
require('expose?$!expose?jQuery!jquery')

ADD_CONTENT_MODEL_FIELDS = require('./AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS

IDENTIFIER_VALIDATION_CONTROLLER_PROPERTIES =
  #URL: '/api/validateIdentifiers'
  BATCH_ID_URL: "/api/preferredBatchId"
  BARCODE_URL: "/api/getWellContentByContainerLabelsObject?containerType=container&containerKind=tube"

DATA_SERVICE_CONTROLLER_EVENTS =
  CLOSE_MODAL: "CloseModal"
  WARNING: "Warning"
  ERROR: "Error"

class IdentifierValidationController extends Backbone.View
  template: _.template(require('html!./IdentifierValidationView.tmpl'))

  initialize: (options)->
    @addContentModel = options.addContentModel
    #@url = IDENTIFIER_VALIDATION_CONTROLLER_PROPERTIES.BATCH_ID_URL

    if @addContentModel.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE) is "barcode"
      @url = IDENTIFIER_VALIDATION_CONTROLLER_PROPERTIES.BARCODE_URL
      @data = @addContentModel.formatIdentifiersForBarcodeValidationService()
    else if @addContentModel.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE) is "compoundBatchId"
      @url = IDENTIFIER_VALIDATION_CONTROLLER_PROPERTIES.BATCH_ID_URL
      @data = { requests: @addContentModel.formatIdentifiersForBatchIdValidationService() }

    @serviceCallProgressText = "Validating Identifiers"
    console.log "@data to check"
    console.log @data
    @successCallback = options.successCallback
    @ajaxMethod = 'POST'

  handleSuccessCallback: (data, textStatus, jqXHR) =>
    if @addContentModel.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE) is "barcode"
      @handleBarcodeValidationCallback(data, textStatus, jqXHR)
    else if @addContentModel.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE) is "compoundBatchId"
      @handleBatchIdValidationCallback(data, textStatus, jqXHR)

    window.FOODATA = data


  handleBarcodeValidationCallback: (data, textStatus, jqXHR) =>
    hasInvalidEntries = false
    @invalidRequestNames = []
    @validRequestNames = []
    @aliasedRequestNames = []
    _.each(data, (well) =>
      if _.size(well.wellContent) is 0
        @invalidRequestNames.push {requestName: well.label}
      else
        @validRequestNames.push {requestName: well.wellContent[0].batchCode}
    )
    @processIdentifiers()

#    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.INVALID_IDENTIFIERS, @invalidRequestNames
#    if _.size(@invalidRequestNames) > 0
#      @trigger DATA_SERVICE_CONTROLLER_EVENTS.ERROR
#      @handleError(@invalidRequestNames)

  handleBatchIdValidationCallback: (data, textStatus, jqXHR) =>
    validatedIdentifiers = data.results
    @aliasedRequestNames = @getAliasedRequestNames validatedIdentifiers
    @invalidRequestNames = @getInvalidRequestNames validatedIdentifiers
    @validRequestNames = @getValidRequestNames validatedIdentifiers

    aliasedIdentifiers = []
    _.each(@aliasedRequestNames, (aliasedName) ->
      aliasedIdentifiers.push aliasedName.requestName
    )
    validIdentifier = []
    _.each(@validRequestNames, (validName) ->
      validIdentifier.push validName.requestName
    )
    @validIdentifiers = _.union(aliasedIdentifiers, validIdentifier)

    @processIdentifiers()

  processIdentifiers: =>
    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.ALIASED_IDENTIFIERS, @aliasedRequestNames
    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.INVALID_IDENTIFIERS, @invalidRequestNames
    if _.size(@invalidRequestNames) is 0 and _.size(@aliasedRequestNames) is 0
      validNames = _.union(@aliasedRequestNames, @validRequestNames)
      valuesToAdd = []
      _.each(validNames, (v) ->
        valuesToAdd.push v.preferredName
      )
      @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS, valuesToAdd
      @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALID_IDENTIFIERS, @validIdentifiers
      @successCallback @addContentModel
      @trigger DATA_SERVICE_CONTROLLER_EVENTS.CLOSE_MODAL
    else if _.size(@aliasedRequestNames) > 0 and _.size(@invalidRequestNames) > 0
      console.log "errors and aliases"
      @handleWarning(@aliasedRequestNames)
      @handleError(@invalidRequestNames)
      @trigger DATA_SERVICE_CONTROLLER_EVENTS.ERROR
    else if _.size(@aliasedRequestNames) > 0
      @trigger DATA_SERVICE_CONTROLLER_EVENTS.WARNING
      @handleWarning(@aliasedRequestNames)
    else if _.size(@invalidRequestNames) > 0
      @trigger DATA_SERVICE_CONTROLLER_EVENTS.ERROR
      @handleError(@invalidRequestNames)

  getAliasedRequestNames: (requestNames) ->
    aliasedRequestNames = []
    _.each(requestNames, (requestName) ->
      unless requestName.preferredName is ""
        unless requestName.requestName is requestName.preferredName
          aliasedRequestNames.push requestName
    )

    aliasedRequestNames

  getInvalidRequestNames: (requestNames) ->
    invalidRequestNames = []
    _.each(requestNames, (requestName) ->
      console.log "requestName"
      console.log requestName
      if requestName.preferredName is ""
        invalidRequestNames.push requestName
    )

    invalidRequestNames

  getValidRequestNames: (requestNames) ->
    validRequestNames = []
    _.each(requestNames, (requestName) ->
      if requestName.requestName is requestName.preferredName
        console.log "request name is valid"
        validRequestNames.push requestName
    )

    validRequestNames

  handleError: (errors) =>
    listOfErrorIdentifiers = "<ul>"
    _.each(errors, (arn) ->
      listOfErrorIdentifiers += "<li>" + arn.requestName + "</li>"
    )
    listOfErrorIdentifiers += "</ul>"
    @$("div[name='errorIdentifiers']").html listOfErrorIdentifiers
    @$("div[name='errorMessages']").removeClass "hide"

  handleWarning: (warnings) =>
    listOfAliasedIdentifiers = "<table class='table'><tr><th>Aliased Identiier</th><th>Preferred Identifier</th></tr>"
    _.each(warnings, (arn) ->
      listOfAliasedIdentifiers += "<tr><td>" + arn.requestName + "</td><td>" + arn.preferredName + "</td></tr>"
    )
    listOfAliasedIdentifiers += "</table>"
    @$("div[name='aliasedIdentifiers']").html listOfAliasedIdentifiers
    @$("div[name='warningMessages']").removeClass "hide"

  handWarningContinueClick: =>
    validNames = _.union(@aliasedRequestNames, @validRequestNames)

    valuesToAdd = []
    _.each(validNames, (v) ->
      valuesToAdd.push v.preferredName
    )
    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS, valuesToAdd
    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALID_IDENTIFIERS, @validIdentifiers

    @successCallback @addContentModel
    @trigger DATA_SERVICE_CONTROLLER_EVENTS.CLOSE_MODAL


  render: =>
    $(@el).html @template()

    @

class AddContentIdentifierValidationController extends IdentifierValidationController


class PlateTableIdentifierValidationController extends IdentifierValidationController
  handleErrorGoBackClick: =>
    validNames = _.union(@aliasedRequestNames, @validRequestNames)

    valuesToAdd = []
    _.each(validNames, (v) ->
      valuesToAdd.push v.preferredName
    )
    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS, valuesToAdd
    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALID_IDENTIFIERS, @validIdentifiers
    @successCallback @addContentModel


module.exports =
  AddContentIdentifierValidationController: AddContentIdentifierValidationController
  PlateTableIdentifierValidationController: PlateTableIdentifierValidationController