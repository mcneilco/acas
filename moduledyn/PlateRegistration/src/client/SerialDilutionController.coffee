Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')

SERIAL_DILUTION_CONTROLLER_EVENTS =
  APPLY_DILUTION: "applyDilution"

SERIAL_DILUTION_MODEL_FIELDS = require('./SerialDilutionModel.coffee').SERIAL_DILUTION_MODEL_FIELDS

_.extend(Backbone.Validation.callbacks, {
  valid: (view, attr, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group');

    $group.removeClass('has-error');
    $group.find('.help-block').html('').addClass('hidden');

  invalid: (view, attr, error, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group');

    $group.addClass('has-error');
    $group.find('.help-block').html(error).removeClass('hidden');

})


class SerialDilutionController extends Backbone.View
  template: _.template(require('html!./SerialDilutionView.tmpl'))

  initialize: (options) ->
    @model = options.model
    @numericFields = ["numberOfDoses", "transferVolume", "destinationWellVolume", "dilutionFactor"]

  events:
    "change input[type='text']": "handleFormFieldUpdate"
    "click button[name='applyDilution']": "handleApplyDilutionClicked"
    "click button[name='diluteUp']": "handleDilutionDirectionChanged"
    "click button[name='diluteRight']": "handleDilutionDirectionChanged"
    "click button[name='diluteDown']": "handleDilutionDirectionChanged"
    "click button[name='diluteLeft']": "handleDilutionDirectionChanged"
    "change input[name='dilutionStrategy']": "handleDilutionStrategyChanged"

  handleFormFieldUpdate: (evt) ->
    target = $(evt.currentTarget)
    data = {}
    if target.attr('name') in @numericFields
      data[target.attr('name')] = parseFloat($.trim(target.val()))
    else
      data[target.attr('name')] = $.trim(target.val())

    @model.set data
    @setStateOfSubmitButton()

  completeInitialization: (plateMetadata) =>
    @model.set SERIAL_DILUTION_MODEL_FIELDS.MAX_NUMBER_OF_COLUMNS, plateMetadata.numberOfColumns
    @model.set SERIAL_DILUTION_MODEL_FIELDS.MAX_NUMBER_OF_ROWS, plateMetadata.numberOfRows

  handleDilutionDirectionChanged: (e) =>
    dilutionDirection = e.currentTarget.name
    @$(".serialDilutionDirection").removeClass "active"
    $("button[name='#{dilutionDirection}']").addClass("active")
    @model.set SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, dilutionDirection
    @setStateOfSubmitButton()

  handleApplyDilutionClicked: =>
    @trigger SERIAL_DILUTION_CONTROLLER_EVENTS.APPLY_DILUTION, @model

  handleDilutionStrategyChanged: (e) =>
    if e.currentTarget.value is "volume"
      @model.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, true
      @$("input[name='transferVolume']").prop("disabled", false)
      @$("input[name='destinationWellVolume']").prop("disabled", false)
      @$("input[name='dilutionFactor']").prop("disabled", true)
    else
      @model.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, false
      @$("input[name='transferVolume']").prop("disabled", true)
      @$("input[name='destinationWellVolume']").prop("disabled", true)
      @$("input[name='dilutionFactor']").prop("disabled", false)
    @setStateOfSubmitButton()

  updateSelectedRegion: (selectedRegion, lowestVolumeWell, allWellsHaveVolume, allWellsHaveConcentration) =>
#    console.log "lowestVolumeWell"
#    console.log lowestVolumeWell
    numberOfRowsSelected = Math.abs(selectedRegion.rowStart - selectedRegion.rowStop) + 1
    numberOfColumnsSelected = Math.abs(selectedRegion.colStart - selectedRegion.colStop) + 1
    @model.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, selectedRegion.colStart)
    @model.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, selectedRegion.rowStart)
    @model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, numberOfColumnsSelected)
    @model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, numberOfRowsSelected)
    @model.set(SERIAL_DILUTION_MODEL_FIELDS.LOWEST_VOLUME_WELL, lowestVolumeWell)
    @model.set(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_VOLUME, allWellsHaveVolume)
    @model.set(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_CONCENTRATION, allWellsHaveConcentration)



    @setStateOfSubmitButton()

  setStateOfSubmitButton: =>
    if @model.isItValid()
      @$(".bv_errorMessages").empty()
      @$("button[name='applyDilution']").prop("disabled", false)
      @$("button[name='applyDilution']").removeClass("disabled")
    else
      errorMessages = @buildErrorMessage()
      @$(".bv_errorMessages").html errorMessages
      @$("button[name='applyDilution']").prop("disabled", true)
      @$("button[name='applyDilution']").addClass("disabled")

  buildErrorMessage: =>
    errorMessages = ""
    _.each(@model.errorMessages, (errorMessage) ->
      errorMessages += errorMessage + "<br />"
    )

    errorMessages

  render: =>
    $(@el).html @template()
    @setStateOfSubmitButton()

    @


module.exports =
  SerialDilutionController: SerialDilutionController
  SERIAL_DILUTION_CONTROLLER_EVENTS: SERIAL_DILUTION_CONTROLLER_EVENTS