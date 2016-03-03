Backbone = require('backbone')
_ = require('lodash')

require('expose?$!expose?jQuery!jquery')

LOAD_PLATE_CONTROLLER_PROPERTIES =
  PLATE_META_INFO_URL: '/api/getPlateByBarcode/'
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
    #@url = [LOAD_PLATE_CONTROLLER_PROPERTIES.PLATE_META_INFO_URL + plateBarcode, LOAD_PLATE_CONTROLLER_PROPERTIES.WELL_CONTENT_URL + plateBarcode]
    @url = LOAD_PLATE_CONTROLLER_PROPERTIES.WELL_CONTENT_URL + plateBarcode

    @successCallback = options.successCallback
    @ajaxMethod = 'GET'

  handleSuccessCallback: (data, textStatus, jqXHR) =>
    @successCallback data

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