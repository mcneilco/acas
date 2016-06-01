Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')

ADD_CONTENT_MODEL_FIELDS = require('./AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS
ADD_CONTENT_CONTROLLER_EVENTS =
  ADD_CONTENT: "AddContent"
  ADD_CONTENT_NO_VALIDATION: "addContentNoValidation"

FILL_PATTERNS_CONTROLLER_EVENTS =
  ADD_CONTENT: "AddContent"

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


class FillPatternController extends Backbone.View
  template: _.template(require('html!./FillPatternsView.tmpl'))

  initialize: (options) ->
    @model = options.model
#    #@listenTo @model, "change", @render
    @selectedRegionBoundries = null

  events:

    "change input[name='fillPattern']": "handleFillPatternChanged"
    "change input[type='text']": "handleFormFieldUpdate"
    "change input[name='identifiers']": "handleIdentifiersChanged"
    "click button[name='add']": "handleAddClick"

  render: =>
    $(@el).html @template() #@model.toJSON())
    @model.set ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, "checkerBoard1"

    @setStatusOfSubmitButton()

    @

  completeInitialization: (plateMetadata) =>
    @maxNumberOfColumns = plateMetadata.numberOfColumns
    @maxNumberOfRows =  plateMetadata.numberOfRows

  setStatusOfSubmitButton: =>
    if @model.isValid(true)
      @enableAddButton()
    else
      @disableAddButton()

  enableAddButton: =>
    @$("button[name='add']").prop('disabled', false)
    @$("button[name='add']").removeClass('disabled')

  disableAddButton: =>
    @$("button[name='add']").prop('disabled', true)
    @$("button[name='add']").addClass('disabled')

  handleAddClick: =>
    hasIdentifiersToValidate = false

    console.log '@model.get("identifiers")'
    console.log @model.get("identifiers")


    if _.size(@model.get("identifiers")) > 0
      hasIdentifiersToValidate = true
    else
      @model.set("identifiers", [])

    console.log "@model"
    console.log @model

    if hasIdentifiersToValidate
      @trigger ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT, @model
    else
      @model.set("aliasedIdentifiers", [])
      @model.set("invalidIdentifiers", [])
      @model.set("validIdentifiers", [])
      @model.set("validatedIdentifiers", [])

      @trigger ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT_NO_VALIDATION, @model

    #@model.set("identifiers", "")

  handleFormFieldUpdate: (evt) ->
    target = $(evt.currentTarget)
    data = {}
    data[target.attr('name')] = $.trim(target.val())
    @model.set data
    @setStatusOfSubmitButton()

  handleFillPatternChanged: (e) =>
    @model.set ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, e.currentTarget.value
    if e.currentTarget.value is "fillAllEmptyWells"
      # fillAllEmptyWells doesn't require any region to be selected,
      # so overide the number of cells selected to 1 so the model is valid
      @model.set ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, 1
    else
      # reset the NUMBER_OF_CELLS_SELECTED field back to what it was before
      if @selectedRegionBoundries
        console.log "setting selected region"
        @updateSelectedRegion @selectedRegionBoundries
      else
        @model.set ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, 0
    @setStatusOfSubmitButton()

  updateSelectedRegion: (selectedRegionBoundries) =>
    @selectedRegionBoundries = selectedRegionBoundries
    numberOfSelectedCells = @calculateNumberOfSelectedCells @selectedRegionBoundries
    @model.set ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, numberOfSelectedCells
    #@render()
    @$(".cellsSelected").html numberOfSelectedCells
    @setStatusOfSubmitButton()

  calculateNumberOfSelectedCells: (selectedRegionBoundries) =>
    width = Math.abs(selectedRegionBoundries.rowStop - selectedRegionBoundries.rowStart) + 1
    height = Math.abs(selectedRegionBoundries.colStop - selectedRegionBoundries.colStart) + 1
    numberOfCells = width * height

    numberOfCells

  handleIdentifiersChanged: =>
    if AppLaunchParams.enforceUppercaseBarcodes
      identifier = $.trim(_.toUpper(@$("input[name='identifiers']").val()))
      if identifier is ""
        listOfIdentifiers = []
      else
        listOfIdentifiers = [identifier]
        @$("input[name='identifiers']").val(identifier)
    else
      identifier = $.trim(@$("input[name='identifiers']").val())
      if identifier is ""
        listOfIdentifiers = []
      else
        listOfIdentifiers = [identifier]
    updatedValues = {}
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS] =  listOfIdentifiers
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS_DISPLAY_STRING] =  listOfIdentifiers
    updatedValues[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] =  _.size(listOfIdentifiers)
    @$(".addContentTotal").html updatedValues[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS]
    @model.set updatedValues

    @setStatusOfSubmitButton()

module.exports =
  FillPatternController: FillPatternController
  FILL_PATTERNS_CONTROLLER_EVENTS: FILL_PATTERNS_CONTROLLER_EVENTS