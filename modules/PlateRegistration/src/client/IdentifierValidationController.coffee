Backbone = require('backbone')
_ = require('lodash')
#$ = require('jquery')
require('expose?$!expose?jQuery!jquery')

ADD_CONTENT_MODEL_FIELDS = require('./AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS

IDENTIFIER_VALIDATION_CONTROLLER_PROPERTIES =
  URL: '/api/validateIdentifiers'
DATA_SERVICE_CONTROLLER_EVENTS =
  CLOSE_MODAL: "CloseModal"
  WARNING: "Warning"
  ERROR: "Error"

class IdentifierValidationController extends Backbone.View
  template: _.template(require('html!./IdentifierValidationView.tmpl'))

  initialize: (options)->
    @serviceCallProgressText = "Validating Identifiers"
    @url = IDENTIFIER_VALIDATION_CONTROLLER_PROPERTIES.URL
    @addContentModel = options.addContentModel
    @data =
      identifiers: @addContentModel.formatIdentifiersForValidationService()
    @successCallback = options.successCallback
    @ajaxMethod = 'POST'

  handleSuccessCallback: (data, textStatus, jqXHR) =>
    @aliasedRequestNames = @getAliasedRequestNames data
    @invalidRequestNames = @getInvalidRequestNames data
    @validRequestNames = @getValidRequestNames data

    aliasedIdentifiers = []
    _.each(@aliasedRequestNames, (aliasedName) ->
      aliasedIdentifiers.push aliasedName.requestName
    )
    validIdentifier = []
    _.each(@validRequestNames, (validName) ->
      validIdentifier.push validName.requestName
    )
    @validIdentifiers = _.union(aliasedIdentifiers, validIdentifier)

    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.ALIASED_IDENTIFIERS, @aliasedRequestNames
    @addContentModel.set ADD_CONTENT_MODEL_FIELDS.INVALID_IDENTIFIERS, @invalidRequestNames

    console.log "@aliasedRequestNames"
    console.log @aliasedRequestNames
    console.log "@invalidRequestNames"
    console.log @invalidRequestNames

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
    listOfAliasedIdentifiers = "<ul>"
    _.each(warnings, (arn) ->
      listOfAliasedIdentifiers += "<li>" + arn.requestName + " ---> " + arn.preferredName + "</li>"
    )
    listOfAliasedIdentifiers += "</ul>"
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
#  handleSuccessCallback: (data, textStatus, jqXHR) =>
#    super(data, textStatus, jqXHR)
#
#    if _.size(@invalidRequestNames) is 0 and _.size(@aliasedRequestNames) is 0
#      validNames = _.union(@aliasedRequestNames, @validRequestNames)
#
#      valuesToAdd = []
#      _.each(validNames, (v) ->
#        valuesToAdd.push v.preferredName
#      )
#      @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS, valuesToAdd
#      @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALID_IDENTIFIERS, @validIdentifiers
#      @successCallback @addContentModel
#      @trigger DATA_SERVICE_CONTROLLER_EVENTS.CLOSE_MODAL
#    else if _.size(@aliasedRequestNames) > 0
#      @trigger DATA_SERVICE_CONTROLLER_EVENTS.WARNING
#      @handleWarning(@aliasedRequestNames)
#    else if _.size(@invalidRequestNames) > 0
#      @trigger DATA_SERVICE_CONTROLLER_EVENTS.ERROR
#      @handleError(@invalidRequestNames)


class PlateTableIdentifierValidationController extends IdentifierValidationController
  handleErrorGoBackClick: =>
    console.log "PlateTableIdentifierValidationController.handleErrorGoBackClick"
    @successCallback @addContentModel

#  handleSuccessCallback: (data, textStatus, jqXHR) =>
#    super(data, textStatus, jqXHR)
#
#    if _.size(@invalidRequestNames) is 0 and _.size(@aliasedRequestNames) is 0
#      validNames = _.union(@aliasedRequestNames, @validRequestNames)
#
#      valuesToAdd = []
#      _.each(validNames, (v) ->
#        valuesToAdd.push v.preferredName
#      )
#      @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS, valuesToAdd
#      @addContentModel.set ADD_CONTENT_MODEL_FIELDS.VALID_IDENTIFIERS, @validIdentifiers
#      @successCallback @addContentModel
#      @trigger DATA_SERVICE_CONTROLLER_EVENTS.CLOSE_MODAL
#    else if _.size(@aliasedRequestNames) > 0
#      @trigger DATA_SERVICE_CONTROLLER_EVENTS.WARNING
#      @handleWarning(@aliasedRequestNames)
#    else if _.size(@invalidRequestNames) > 0
#      @trigger DATA_SERVICE_CONTROLLER_EVENTS.ERROR
#      @handleError(@invalidRequestNames)


module.exports =
  #IdentifierValidationController: IdentifierValidationController
  AddContentIdentifierValidationController: AddContentIdentifierValidationController
  PlateTableIdentifierValidationController: PlateTableIdentifierValidationController