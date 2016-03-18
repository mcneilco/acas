Backbone = require('backbone')
_ = require('lodash')
$ = require('jquery')

class SelectListCollection extends Backbone.Collection
  getArrayOfOptions: ->
    options = []
    _.each(@models, (model) ->
      options.push
        value: model.get 'value'
        displayValue: model.get 'displayValue'
    )

    options


class OptionController extends Backbone.View
  tagName: 'option'
  initialize: (options) ->
    @selected = options.selected

  render: =>
    $(@el).attr('value', @model.get('value'))
    $(@el).attr('selected', @selected)
    $(@el).html(@model.get('displayValue'))

    @


class SelectController extends Backbone.View
  initialize: (options) ->
    @selectedValue = ""
    if options.selectedValue?
      @selectedValue = options.selectedValue

  render: =>
    @collection.each((model) =>
      selected = false
      if model.get('value') is @selectedValue
        selected = true
      option = new OptionController({model: model, selected: selected})
      $(@el).append option.render().el
    )

    @

module.exports =
  SelectListCollection: SelectListCollection
  SelectController: SelectController