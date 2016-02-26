Backbone = require('backbone')
_ = require('lodash')
#$ = require('jquery')
require('expose?$!expose?jQuery!jquery')

CREATE_PLATE_SAVE_CONTROLLER_PROPERTIES =
  URL: '/api/createPlate'

DATA_SERVICE_CONTROLLER_EVENTS =
  CLOSE_MODAL: "CloseModal"
  WARNING: "Warning"
  ERROR: "Error"

class CreatePlateSaveController extends Backbone.View
  template: _.template(require('html!./CreatePlate.tmpl'))

  initialize: (options)->
    @serviceCallProgressText = "Creating Plate"
    @url = CREATE_PLATE_SAVE_CONTROLLER_PROPERTIES.URL
    @plateModel = options.plateModel
    @data =
      @plateModel.toJSON()
    @successCallback = options.successCallback
    @ajaxMethod = 'POST'

  handleSuccessCallback: (data, textStatus, jqXHR) =>
    console.log "handleSuccessCallback"
    console.log data
    #@plateModel.set data
    @successCallback @plateModel
    @$("a[name='linkToPlate']").prop("href", "#plateDesign/#{data.codeName}")
    @$("div[name='plateCreatedSuccessfully']").removeClass "hide"

    #@trigger DATA_SERVICE_CONTROLLER_EVENTS.CLOSE_MODAL

  handleError: (errors) =>
    console.log "handleError"

  handleWarning: (warnings) =>
    console.log "handleWarning"

  handWarningContinueClick: =>
    console.log "handWarningContinueClick"


  render: =>
    $(@el).html @template()

    @



module.exports =
  CreatePlateSaveController: CreatePlateSaveController