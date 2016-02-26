Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')

PlateFillerFactory = require('./PlateFillerFactory.coffee').PlateFillerFactory

ADD_CONTENT_MODEL_FIELDS = require('./AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS

ADD_CONTENT_CONTROLLER_EVENTS =
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


class AddContentController extends Backbone.View
  template: _.template(require('html!./AddContentView.tmpl'))

  initialize: (options) ->
    @model = options.model
    @listenTo @model, "change", @render
    @selectedRegionBoundries = {}
    @plateFillerFactory = new PlateFillerFactory()

  events:
    "change textarea[name='identifiers']": "handleIdentifiersChanged"
    "paste textarea[name='identifiers']": "handleIdentifiersPaste"
    "change input[name='fillStrategy']": "handleFillStrategyChanged"
    "change input[type='text']": "handleFormFieldUpdate"
    "click button[name='add']": "handleAddClick"

  render: =>
    $(@el).html @template(@model.toJSON())

    @

  handleAddClick: =>

    @trigger ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT, @model

  handleIdentifiersAdded: (validatedIdentifiers) =>
    @removeInsertedIdentifiers validatedIdentifiers

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
    #@updateModel data
    @model.set data

  handleIdentifiersPaste: =>
    console.log "handleIdentifiersPaste"

  handleIdentifiersChanged: =>
    listOfIdentifiers = @parseIdentifiers @$("textarea[name='identifiers']").val()
    updatedValues = {}
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS] =  listOfIdentifiers
    updatedValues[ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS_DISPLAY_STRING] =  @formatListOfIdentifiersForDisplay(listOfIdentifiers)
    updatedValues[ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_IDENTIFIERS] =  _.size(listOfIdentifiers)
    @model.set updatedValues

    #@render()

  handleFillStrategyChanged: (e) =>
    @model.set ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY, e.currentTarget.value

  formatListOfIdentifiersForDisplay: (identifiers) =>
    #_.difference(@model.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS), identifiersToRemove)
    #identifiers = @model.get(ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS)
    identifiersDisplayString = _.reduce(identifiers, (memo, identifier) ->
      memo += identifier + "\n"
    , "")

    identifiersDisplayString

  updateSelectedRegion: (selectedRegionBoundries) =>

    @selectedRegionBoundries = selectedRegionBoundries

    numberOfSelectedCells = @calculateNumberOfSelectedCells @selectedRegionBoundries
    @model.set ADD_CONTENT_MODEL_FIELDS.NUMBER_OF_CELLS_SELECTED, numberOfSelectedCells
    @render()

  calculateNumberOfSelectedCells: (selectedRegionBoundries) =>
    width = Math.abs(selectedRegionBoundries.rowStop - selectedRegionBoundries.rowStart) + 1
    height = Math.abs(selectedRegionBoundries.colStop - selectedRegionBoundries.colStart) + 1
    numberOfCells = width * height

    numberOfCells

  parseIdentifiers: (identifiers) ->
    listOfIdentifiers = _.map(identifiers.split(','), (identifier) ->
      $.trim(identifier)
    )

    listOfIdentifiers


module.exports =
  AddContentController: AddContentController
  ADD_CONTENT_CONTROLLER_EVENTS: ADD_CONTENT_CONTROLLER_EVENTS