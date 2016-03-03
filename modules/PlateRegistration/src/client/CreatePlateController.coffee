Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')

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
    #@listenTo @model, "change", @render

  events:
    "change input": "handleFormFieldUpdate"
    "change select": "handleFormFieldUpdate"
    "click button[name='submit']": "handleClickStart"

  render: =>
    $(@el).html @template() #@model.toJSON())

    @

  handleFormFieldUpdate: (evt) ->
    target = $(evt.currentTarget)
    data = {}
    data[target.attr('name')] = $.trim(target.val())
    @updateModel data

  updateModel: (data) =>
    @model.set data
    if @model.isValid(true)
      console.log "model is valid"
      @$("button[name='submit']").prop("disabled", false)
    else
      console.log "model is not valid"
      @$("button[name='submit']").prop("disabled", true)

    console.log "@model"
    console.log @model

  handleClickStart: =>
    @trigger CREATE_PLATE_CONTROLLER_EVENTS.CREATE_PLATE, @model

  handleSuccessfulSave: (updatedModel) =>
    console.log "saved and got"
    console.log updatedModel
    @model.reset()
    @render()



module.exports =
  CreatePlateController: CreatePlateController
  CREATE_PLATE_CONTROLLER_EVENTS: CREATE_PLATE_CONTROLLER_EVENTS