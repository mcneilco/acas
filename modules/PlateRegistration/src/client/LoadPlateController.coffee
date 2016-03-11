Backbone = require('backbone')
_ = require('lodash')

require('expose?$!expose?jQuery!jquery')

LOAD_PLATE_CONTROLLER_PROPERTIES =
  PLATE_META_INFO_URL: '/api/getPlateMetadataAndDefinitionMetadataByPlateBarcode/'
  WELL_CONTENT_URL: '/api/getWellContentByPlateBarcode/'

DATA_SERVICE_CONTROLLER_EVENTS =
  CLOSE_MODAL: "CloseModal"
  WARNING: "Warning"
  ERROR: "Error"

class LoadPlateController extends Backbone.View
  template: _.template(require('html!./LoadPlate.tmpl'))

  initialize: (options)->
    @serviceCallProgressText = "Loading Plate"
    plateBarcode = options.plateBarcode
    @url = [
      url: LOAD_PLATE_CONTROLLER_PROPERTIES.PLATE_META_INFO_URL + plateBarcode
      callback: @handlePlateMetaDataInfoCallback
      ajaxMethod: 'GET'
      data: ''
    ,
      url: LOAD_PLATE_CONTROLLER_PROPERTIES.WELL_CONTENT_URL + plateBarcode
      callback: @handleWellContentCallback
      ajaxMethod: 'GET'
      data: ''
    ]
    #@url = LOAD_PLATE_CONTROLLER_PROPERTIES.WELL_CONTENT_URL + plateBarcode

    @successCallback = options.successCallback
    @ajaxMethod = 'GET'

  handlePlateMetaDataInfoCallback: (data) =>
    console.log "handlePlateMetaDataInfoCallback - data"
    console.log data
    @plateMetadata = data

  handleWellContentCallback: (data) =>
    console.log "handleWellContentCallback - data"
    console.log data
    @wellContent = data

  handleSuccessCallback: () =>
    @successCallback {wellContent: @wellContent, plateMetadata: @plateMetadata}

    @trigger DATA_SERVICE_CONTROLLER_EVENTS.CLOSE_MODAL

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
  LoadPlateController: LoadPlateController