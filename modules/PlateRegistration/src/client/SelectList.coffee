Backbone = require('backbone')
_ = require('lodash')
$ = require('jquery')

class SelectListCollection extends Backbone.Collection
  getArrayOfOptions: ->
    options = []
    _.each(@models, (model) ->
      options.push
        value: model.get 'value'
        displayValue: model.get('lsLabels')[0].labelText
    )

    options


class OptionController extends Backbone.View
  tagName: 'option'
  initialize: (options) ->
    @selected = options.selected

  render: =>
    $(@el).attr('value', @model.get('codeName'))
    $(@el).attr('selected', @selected)
    #$(@el).html(@model.get('displayValue'))
    $(@el).html(@model.get('lsLabels')[0].labelText)
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

# Copied in from Components/PickList.coffee
class PickList extends Backbone.Model

class PickListList extends Backbone.Collection
  model: PickList

  setType: (type) ->
    @type = type

  getModelWithId: (id) ->
    @detect (enu) ->
      enu.get("id") is id

  getModelWithCode: (code) ->
    @detect (enu) ->
      enu.get("code") is code

  getCurrent: ->
    @filter (pl) ->
      !(pl.get 'ignored')

class PickListOptionController extends Backbone.View
  tagName: "option"
  initialize: ->

  render: =>
    $(@el).attr("value", @model.get("code")).text @model.get("name")
    @

class PickListOptionControllerForLsThing extends Backbone.View
  tagName: "option"
  initialize: (options) ->
    if options.insertFirstOption?
      @insertFirstOption = options.insertFirstOption
    else
      @insertFirstOption = null
    if options.displayName?
      @displayName = options.displayName
    else
      @displayName = null

  render: =>
    if @displayName != null
      if @displayName == 'corpName' or @displayName == 'corpName_notebook'
        unless @model.get('lsLabels') instanceof LabelList
          @model.set 'lsLabels', new LabelList @model.get('lsLabels')
        unless @model.get('lsStates') instanceof StateList
          @model.set 'lsStates', new StateList @model.get('lsStates')
        corpName = @model.get('lsLabels').getACASLsThingCorpName()
        if corpName?
          displayValue = corpName.get('labelText')
          if @displayName == 'corpName_notebook'
            notebookValue =  @model.get('lsStates').getOrCreateValueByTypeAndKind 'metadata', @model.get('lsKind')+' batch', 'stringValue', 'notebook'
            displayValue = displayValue + " " + notebookValue.get('stringValue')
        else
#Note: if some models in picklist don't have corpName, they will have their display value set to the name of the first option (ie "unassigned")
          displayValue = @insertFirstOption.get('name')
      else if @model.get(@displayName)?
        displayValue = @model.get(@displayName)
      else
        displayValue = @insertFirstOption.get('name')
      $(@el).attr("value", @model.get("id")).text displayValue

    else
      preferredNames = _.filter @model.get('lsLabels'), (lab) ->
        lab.preferred && (lab.lsType == "name") && !lab.ignored
      bestName = _.max preferredNames, (lab) ->
        rd = lab.recordedDate
        (if (rd is "") then Infinity else rd)
      if bestName?
        displayValue = bestName.labelText
      else if @model.get('codeName')?
        displayValue = @model.get('codeName')
      else
        displayValue = @insertFirstOption.get('name')
      $(@el).attr("value", @model.get("id")).text displayValue

    @


class PickListSelectController extends Backbone.View

  initialize: (options) ->
    @rendered = false
    @collection.bind "add", @addOne
    @collection.bind "reset", @handleListReset

    unless options.selectedCode is ""
      @selectedCode = options.selectedCode
    else
      @selectedCode = null

    if options.showIgnored?
      @showIgnored = options.showIgnored
    else
      @showIgnored = false

    if options.insertFirstOption?
      @insertFirstOption = options.insertFirstOption
    else
      @insertFirstOption = null


    if options.autoFetch?
      @autoFetch = options.autoFetch
    else
      @autoFetch = true

    if @autoFetch == true
      @collection.fetch
        success: @handleListReset
    else
      @handleListReset()


  handleListReset: =>
    if @insertFirstOption
      @collection.add @insertFirstOption,
        at: 0
        silent: true
      unless (@selectedCode is @insertFirstOption.get('code'))
        if (@collection.where({code: @selectedCode})).length is 0
          newOption = new PickList
            code: @selectedCode
            name: @selectedCode
          @collection.add newOption
    @render()

  render: =>
    $(@el).empty()
    self = this
    @collection.each (enm) =>
      @addOne enm

    $(@el).val @selectedCode  if @selectedCode

    # hack to fix IE bug where select doesn't work when dynamically inserted
    $(@el).hide()
    $(@el).show()
    @rendered = true

  addOne: (enm) =>
    shouldRender = @showIgnored
    if enm.get 'ignored'
      if @selectedCode?
        if @selectedCode is enm.get 'code'
          shouldRender = true
    else
      shouldRender = true

    if shouldRender
      $(@el).append new PickListOptionController(model: enm).render().el

  setSelectedCode: (code) ->
    @selectedCode = code
    #		$(@el).val @selectedCode  if @rendered
    if @rendered
      $(@el).val @selectedCode
    else
      "not done"

  getSelectedCode: ->
    $(@el).val()

  getSelectedModel: ->
    @collection.getModelWithCode @getSelectedCode()

  checkOptionInCollection: (code) => #checks to see if option already exists in the picklist list
    return @collection.findWhere({code: code})

class PickListForLsThingsSelectController extends PickListSelectController

  initialize: (options) ->
    super()
    if options.displayName? #examples are codeName, corpName
      @displayName = options.displayName
    else
      @displayName = null

  handleListReset: =>
    if @insertFirstOption
      @collection.add @insertFirstOption,
        at: 0
        silent: true
      unless (@selectedCode is @insertFirstOption.get('code'))
        if (@collection.where({id: @selectedCode})).length is 0
          newOption = new PickList
            id: @selectedCode
            name: @selectedCode
          @collection.add newOption
    @render()

  addOne: (enm) =>
    shouldRender = @showIgnored
    if enm.get 'ignored'
      if @selectedCode?
        if @selectedCode is enm.get 'code'
          shouldRender = true
    else
      shouldRender = true

    if shouldRender
      $(@el).append new PickListOptionControllerForLsThing(model: enm, insertFirstOption: @insertFirstOption, displayName: @displayName).render().el

  getSelectedModel: ->
    @collection.getModelWithId parseInt(@getSelectedCode())

module.exports =
  SelectListCollection: SelectListCollection
  SelectController: SelectController
  PickListForLsThingsSelectController: PickListForLsThingsSelectController
  PickListSelectController: PickListSelectController
  PickListOptionControllerForLsThing: PickListOptionControllerForLsThing
  PickListOptionController: PickListOptionController
  PickListList: PickListList
  PickList: PickList
