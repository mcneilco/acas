Backbone = require('backbone')
_ = require('lodash')
#$ = require('jquery')
require('expose?$!expose?jQuery!jquery')

CREATE_PLATE_SAVE_CONTROLLER_PROPERTIES =
  URL: '/api/createPlate'
  PLATE_BARCODE_ALREADY_EXISTS: '"Barcode already exists"'

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
    if data is "Barcode already exists" # CREATE_PLATE_SAVE_CONTROLLER_PROPERTIES.PLATE_BARCODE_ALREADY_EXISTS
      @trigger "SaveSuccess"
      @handleError()
    else
      @successCallback @plateModel
      @$("span[name='plateText']").html data.barcode
      @$("a[name='linkToPlate']").prop("href", "#plateDesign/#{data.barcode}")
      @$("div[name='plateCreatedSuccessfully']").removeClass "hide"
      @trigger "SaveSuccess"

  handleError: (errors) =>
    @$("div[name='errorMessages']").removeClass "hide"
    @$("a[name='barcode']").prop("href", "#plateDesign/#{@plateModel.get('barcode')}")
    @$("a[name='barcode']").html @plateModel.get("barcode")

  handleWarning: (warnings) =>
    console.log "handleWarning"

  handWarningContinueClick: =>
    console.log "handWarningContinueClick"

  render: =>
    $(@el).html @template()

    @



module.exports =
  CreatePlateSaveController: CreatePlateSaveController