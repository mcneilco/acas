Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')
PlateFillerFactory = require('./PlateFillerFactory.coffee').PlateFillerFactory
ADD_CONTENT_MODEL_FIELDS = require('./AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS

ADD_CONTENT_CONTROLLER_EVENTS =
  ADD_CONTENT: "AddContent"
  ADD_CONTENT_NO_VALIDATION: "addContentNoValidation"

LIST_OF_IDENTIFIER_DELIMITERS = [';', '\t', '\n']

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


class AddContentController extends Backbone.View
  template: _.template(require('html!./AddContentView.tmpl'))

  initialize: (options) ->
    @model = options.model
    #@listenTo @model, "change", @render
    @selectedRegionBoundries = {}

  events:
    "change textarea[name='identifiers']": "handleIdentifiersChanged"
    "paste textarea[name='identifiers']": "handleIdentifiersPaste"
    "change input[name='fillStrategy']": "handleFillStrategyChanged"
    "change input[name='fillDirection']": "handleFillDirectionChanged"
    "change input[name='identifierType']": "handleIdentifierTypeChanged"
    "change input[type='text']": "handleFormFieldUpdate"
    "click button[name='add']": "handleAddClick"

  render: =>
    $(@el).html @template(@model.toJSON())
    if @model.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY) is ""
      $("input[name='fillStrategy']").prop('checked', false)
    else
      fillStrategy = _.find(@$("input[name='fillStrategy']"), (opt) =>
        opt.value == @model.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY)
      )
      $(fillStrategy).prop("checked", true)

    if @model.get(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION) is ""
      $("input[name='fillDirection']").prop('checked', false)
    else
      fillDirection = _.find(@$("input[name='fillDirection']"), (opt) =>
        opt.value == @model.get(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION)
      )
      $(fillDirection).prop("checked", true)

    if @model.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE) is ""
      $("input[name='identifierType']").prop('checked', false)
    else
      identifierType = _.find(@$("input[name='identifierType']"), (opt) =>
        opt.value == @model.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE)
      )
      $(identifierType).prop("checked", true)

    @setStatusOfSubmitButton()

    @

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
    if _.isArray(@model.get("identifiers"))
      _.each(@model.get("identifiers"), (identifier, key) =>

        if _.size(identifier) > 0
          hasIdentifiersToValidate = true
        else
          @model.get("identifiers").splice(key, 1)
      )
    else
      if _.size(@model.get("identifiers")) > 0
        hasIdentifiersToValidate = true
        @model.set("identifiers", [@model.get("identifiers")])
      else
        @model.set("identifiers", [])

    if hasIdentifiersToValidate
      @trigger ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT, @model
    else
      @model.set("aliasedIdentifiers", [])
      @model.set("invalidIdentifiers", [])
      @model.set("validIdentifiers", [])
      @model.set("validatedIdentifiers", [])

      @trigger ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT_NO_VALIDATION, @model

  handleIdentifiersAdded: (validatedIdentifiers) =>
    @model.reset()
    @model.set ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, 0
    @removeInsertedIdentifiers validatedIdentifiers
    @render()
    #@setStatusOfSubmitButton()


  removeInsertedIdentifiers: (insertedIdentifiers) =>
    remainingIdentifiers = _.difference(@model.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS), insertedIdentifiers)
    updatedValues = {}
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS] = remainingIdentifiers
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS_DISPLAY_STRING] =  @formatListOfIdentifiersForDisplay(remainingIdentifiers)
    updatedValues[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] =  _.size(remainingIdentifiers)
    @model.set updatedValues

  handleFormFieldUpdate: (evt) ->
    target = $(evt.currentTarget)
    data = {}
    data[target.attr('name')] = $.trim(target.val())
    @model.set data
    #@render()
    @setStatusOfSubmitButton()

  handleIdentifiersPaste: =>
    console.log "handleIdentifiersPaste"

  handleIdentifiersChanged: =>
    if AppLaunchParams.enforceUppercaseBarcodes
      listOfIdentifiers = @parseIdentifiers $.trim(_.toUpper(@$("textarea[name='identifiers']").val()))
    else
      listOfIdentifiers = @parseIdentifiers $.trim(@$("textarea[name='identifiers']").val())
    updatedValues = {}
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS] =  listOfIdentifiers
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS_DISPLAY_STRING] =  @formatListOfIdentifiersForDisplay(listOfIdentifiers)
    updatedValues[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] =  _.size(listOfIdentifiers)
    @$(".addContentTotal").html updatedValues[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS]
    @model.set updatedValues

    @setStatusOfSubmitButton()
    #@render()

  handleIdentifierTypeChanged: (e) =>
    @model.set ADD_CONTENT_MODEL_FIELDS.IDENTIFIER_TYPE, e.currentTarget.value
    @setStatusOfSubmitButton()

  handleFillStrategyChanged: (e) =>
    @model.set ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, e.currentTarget.value
    @render()

  handleFillDirectionChanged: (e) =>
    @model.set ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION, e.currentTarget.value
    @render()

  formatListOfIdentifiersForDisplay: (identifiers) =>
    identifiersDisplayString = _.reduce(identifiers, (memo, identifier) ->
      memo += identifier + "\n"
    , "")

    identifiersDisplayString

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

  parseIdentifiers: (identifiers) ->
    listOfIdentifiers = []
    _.each(LIST_OF_IDENTIFIER_DELIMITERS, (delimiter) ->
      ids = _.map(identifiers.split(delimiter), (identifier) ->
        $.trim(identifier)
      )
      unless _.size(ids) is 1
        listOfIdentifiers = listOfIdentifiers.concat ids
    )
    if _.size(listOfIdentifiers) is 0 and identifiers isnt ""
      listOfIdentifiers = [identifiers]

    listOfIdentifiers


module.exports =
  AddContentController: AddContentController
  ADD_CONTENT_CONTROLLER_EVENTS: ADD_CONTENT_CONTROLLER_EVENTS