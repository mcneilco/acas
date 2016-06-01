Backbone = require('backbone')
_ = require('lodash')

require('expose?$!expose?jQuery!jquery')

LOAD_PLATE_CONTROLLER_PROPERTIES =
  PLATE_META_INFO_URL: '/api/getContainerAndDefinitionContainerByContainerLabel/'
  WELL_CONTENT_URL: '/api/getWellContentByPlateBarcode/'

DATA_SERVICE_CONTROLLER_EVENTS =
  CLOSE_MODAL: "CloseModal"
  WARNING: "Warning"
  ERROR: "Error"

class LoadPlateController extends Backbone.View
  template: _.template(require('html!./LoadPlate.tmpl'))

  initialize: (options)->
    @serviceCallProgressText = "Loading Plate"
    @plateBarcode = options.plateBarcode
    @url = [
      url: LOAD_PLATE_CONTROLLER_PROPERTIES.PLATE_META_INFO_URL + @plateBarcode
      callback: @handlePlateMetaDataInfoCallback
      ajaxMethod: 'GET'
      data: ''
    ,
      url: LOAD_PLATE_CONTROLLER_PROPERTIES.WELL_CONTENT_URL + @plateBarcode
      callback: @handleWellContentCallback
      ajaxMethod: 'GET'
      data: ''
    ]

    @successCallback = options.successCallback
    @ajaxMethod = 'GET'

  handlePlateMetaDataInfoCallback: (data) =>
    @plateMetadata = data

  handleWellContentCallback: (data) =>
    @wellContent = data

  handleSuccessCallback: () =>
    @successCallback {wellContent: @wellContent, plateMetadata: @plateMetadata}
    @trigger DATA_SERVICE_CONTROLLER_EVENTS.CLOSE_MODAL

  handleError: (errors) =>
    $("div[name='errorMessages']").removeClass "hide"
    $("span[name='plateBarcode']").html @plateBarcode
    console.log "handleError"

  handleWarning: (warnings) =>
    console.log "handleWarning"

  handWarningContinueClick: =>
    console.log "handWarningContinueClick"

  render: =>
    $(@el).html @template()

    @



module.exports =
  LoadPlateController: LoadPlateController