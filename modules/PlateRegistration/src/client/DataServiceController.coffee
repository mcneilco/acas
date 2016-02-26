Backbone = require('backbone')
_ = require('lodash')

require('expose?$!expose?jQuery!jquery');
require("bootstrap-webpack!./bootstrap.config.js");


DATA_SERVICE_CONTROLLER_EVENTS = {}

class DataServiceController extends Backbone.View
  template: _.template(require('html!./DataServiceView.tmpl'))

  initialize: ->
    @serviceController = null

  events:
    "click button[name='warningContinue']": "handWarningContinueClick"

  setupService: (serviceController) =>
    @serviceController = serviceController
    @listenTo @serviceController, "Warning", @handleWarning
    @listenTo @serviceController, "Error", @handleError
    @listenTo @serviceController, "CloseModal", @closeModal
    @$("div[name='serviceControllerContainer']").html @serviceController.render().el
    @$(".bv_serviceCallProgressText").html @serviceController.serviceCallProgressText

  doServiceCall: =>
    @hideSuccessFields()
    @openModal()

    $.ajax(
      data: @serviceController.data
      dataType: "json"
      method: @serviceController.ajaxMethod
      url: @serviceController.url
    )
    .done((data, textStatus, jqXHR) =>
      @displaySuccessFields()
      @serviceController.handleSuccessCallback(data, textStatus, jqXHR)
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      @displayServerErrorMessage()
    )

  doServiceCalls: =>
    @hideSuccessFields()
    @openModal()
    numberOfServiceCalls = _.size(@serviceController.url)
    numberOfCompletedServiceCalls = 0
    _.each(@serviceController.url, (url) =>
      $.ajax(
        data: @serviceController.data
        dataType: "json"
        method: @serviceController.ajaxMethod
        url: url
      )
      .done((data, textStatus, jqXHR) =>
        numberOfCompletedServiceCalls++
        if numberOfCompletedServiceCalls is numberOfServiceCalls
          @displaySuccessFields()
          @serviceController.handleSuccessCallback(data, textStatus, jqXHR)
      )
      .fail((jqXHR, textStatus, errorThrown) =>
        @displayServerErrorMessage()
      )
    )


  displayServerErrorMessage: =>
    @$("div[name='serviceCallProgressFeedback']").addClass "hide"
    @$("div[name='serverErrorMessage']").removeClass "hide"
    @$("div[name='serverErrorButtons']").removeClass "hide"

  displaySuccessFields: =>
    @$("div[name='serviceCallProgressFeedback']").addClass "hide"
    @$("div[name='serviceControllerContainer']").removeClass "hide"
    @$("div[name='closeButtons']").removeClass "hide"

  hideSuccessFields: =>
    @$("div[name='serviceCallProgressFeedback']").removeClass "hide"
    @$("div[name='serviceControllerContainer']").addClass "hide"
    @$("div[name='closeButtons']").addClass "hide"

  handleWarning: =>
    @$("div[name='warningButtons']").removeClass "hide"
    @$("div[name='serviceCallProgressFeedback']").addClass "hide"
    @$("div[name='serviceControllerContainer']").removeClass "hide"

  handleError: =>
    @$("div[name='serviceCallProgressFeedback']").addClass "hide"
    @$("div[name='serviceControllerContainer']").removeClass "hide"
    @$("div[name='errorButtons']").removeClass "hide"

  handWarningContinueClick: =>
    #@closeModal()
    @serviceController.handWarningContinueClick()

  openModal: =>
    @$("div[name='serviceCallModal']").modal(
      keyboard: false
      backdrop: 'static'
    )

  closeModal: =>
    @$("div[name='serviceCallModal']").modal('hide')

  render: =>
    $(@el).html @template()

    @



module.exports =
  DataServiceController: DataServiceController