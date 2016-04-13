Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_ = require('lodash')
$ = require('jquery')

SelectList = require('./SelectList.coffee').SelectController

CREATE_PLATE_CONTROLLER_EVENTS =
  CREATE_PLATE: "CreatePlate"

_.extend(Backbone.Validation.callbacks, {
  valid: (view, attr, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group')

    $group.removeClass('has-error');
    $group.find('.help-block').html('').addClass('hidden')

  invalid: (view, attr, error, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group')

    $group.addClass('has-error')
    $group.find('.help-block').html(error).removeClass('hidden')

})

class CreatePlateController extends Backbone.View
  template: _.template(require('html!./CreatePlateView.tmpl'))

  initialize: (options) ->
    @model = options.model
    @plateTypes = options.plateTypes
    @plateTypesSelectList = new SelectList({collection: @plateTypes, selectedValue: @model.get('type')})
    @selectLists = [
      controller: @plateTypesSelectList
      containerSelector: "select[name='definition']"
    ]

  events:
    "change input": "handleFormFieldUpdate"
    "change select": "handleFormFieldUpdate"
    "click button[name='submit']": "handleClickStart"

  completeInitialization: =>
    console.log "completeInitialization"
    plateDefinition = document.getElementsByName("definition") #$("select[name='definition']")
    console.log "plateDefinition"
    console.log plateDefinition
    # make sure the default selected plate type is reflected in the form model
    @handleFormFieldUpdate({currentTarget: plateDefinition})

  render: =>
    $(@el).html @template() #@model.toJSON())
    @initializeSelectLists()

    @

  initializeSelectLists: =>
    _.each(@selectLists, (selectList) =>
      $(@el).find(selectList.containerSelector).html selectList.controller.render().el.childNodes
    )

  handleFormFieldUpdate: (evt) ->
    console.log "evt"
    console.log evt
    target = $(evt.currentTarget)
    data = {}
    data[target.attr('name')] = $.trim(target.val())
    @updateModel data

  updateModel: (data) =>
    @model.set data
    if @model.isValid(true)
      @$("button[name='submit']").prop("disabled", false)
    else
      @$("button[name='submit']").prop("disabled", true)

  handleClickStart: =>
    @trigger CREATE_PLATE_CONTROLLER_EVENTS.CREATE_PLATE, @model

  handleSuccessfulSave: (updatedModel) =>
    @model.reset()
    @render()


module.exports =
  CreatePlateController: CreatePlateController
  CREATE_PLATE_CONTROLLER_EVENTS: CREATE_PLATE_CONTROLLER_EVENTS