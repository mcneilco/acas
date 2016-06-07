#
# Created by mshaw on 10/1/15.
#
class window.AliasesController extends Backbone.View
  events:
    "click .bv_editAliases": "handleEditAliasesClick"

  initialize: ->
    if @options.collection?
      @collection = @options.collection
    else
      @collection = new AliasCollection()
      #@collection.add(new AliasModel())

    @readMode = false
    if @options.readMode?
      @readMode = @options.readMode

    @step = null
    if @options.step
      @step = @options.step

    @addAliasController = new AddAliasController({collection: @collection})
    @addAliasController.bind "initializationComplete", @completeInitialization
    @viewAliasesController = new AliasListReadView({collection: @collection})
    @addAliasController.bind "addAliasesPanelClosed", @viewAliasesController.render

  handleEditAliasesClick: =>
    @addAliasController.show()

  setToEditMode: =>
    @$(".bv_editAliases").css("display", "")
    $(@el).parent().removeClass "aliasesContainerSearch"

  setToReadOnly: () =>
    @$(".bv_editAliases").css("display", "none")
    if @step is "regSearchResults"
      $(@el).parent().removeClass "aliasesContainerSearch"
    else
      $(@el).parent().addClass "aliasesContainerSearch"

  completeInitialization: =>
    @$(".bv_addAliasContainer").html @addAliasController.render().el
    @addAliasController.hide()
    if @readMode
      @setToReadOnly()

  render: =>
    $(@el).html($('#Aliases_template').html())

    @$(".bv_aliasReadViewContainer").html @viewAliasesController.render().el


    @


class window.AddAliasController extends Backbone.View
  template: $('#AddAliasPanel_template').html()
  events:
    "click .bv_cancelAddNewAlias": "handleCancelAddNewAliasClick"
  initialize: ->
    @collection = @options.collection
    @listOfAliases = new AliasListList()
    @listOfAliases.type = "parentaliaskinds"
    @listOfAliases.bind('reset', =>
      @trigger "initializationComplete"
    )
    @listOfAliases.fetch()

  render: =>
    $(@el).html($('#AddAliasPanel_template').html())
    @aliasTableController = new AddAliasTableController({collection: @collection, listOfAliases: @listOfAliases})
    @$(".bv_aliasTableContainer").html(@aliasTableController.render().el)

    @

  finishRender: =>

  hide: =>
    $(@el).hide()
    $(@el).dialog('close')
    @trigger "addAliasesPanelClosed"

  handleCancelAddNewAliasClick: =>
    if @aliasTableController.collection.modelsAreAllValid()
      @hide()

  show: =>
    $(@el).show()


class window.AddAliasTableController extends Backbone.View
  template: $('#AddAliasTable_template').html()
  events:
    'click .bv_addNewAlias':'handleAddAliasRowClick'

  initialize: ->
    @collection = @options.collection
    @listOfAliases = @options.listOfAliases
    @lastId = 0
    @collection.each((model) =>
      if model.get('id')?
        if @lastId < model.get('sortId')
          @lastId = model.get('id')
    )

    @collection.bind('add', @render)
    @collection.bind('remove', @render)
    @collection.bind('change', @setStateOfButtons)
    @collection.bind('error', @setStateOfButtonsToDisabled)

  setStateOfButtonsToDisabled: =>
    @$(".bv_addNewAlias").addClass("addNewAliasOff")
    @$(".bv_addNewAlias").removeClass("addNewAliasOn")
    $(".bv_cancelAddNewAlias").addClass("cancelAddNewAliasOff")
    $(".bv_cancelAddNewAlias").removeClass("cancelAddNewAliasOn")

  setStateOfButtons: =>
    if @collection.modelsAreAllValid()
      @$(".bv_addNewAlias").removeClass("addNewAliasOff")
      @$(".bv_addNewAlias").addClass("addNewAliasOn")
      $(".bv_cancelAddNewAlias").removeClass("cancelAddNewAliasOff")
      $(".bv_cancelAddNewAlias").addClass("cancelAddNewAliasOn")
    else
      @$(".bv_addNewAlias").addClass("addNewAliasOff")
      @$(".bv_addNewAlias").removeClass("addNewAliasOn")
      $(".bv_cancelAddNewAlias").addClass("cancelAddNewAliasOff")
      $(".bv_cancelAddNewAlias").removeClass("cancelAddNewAliasOn")

  handleAddAliasRowClick: =>
    if @collection.modelsAreAllValid()
      @lastId++
      @collection.add(new AliasModel({sortId: @lastId}))

  addRow: (model) =>
    rowControllers = new AliasRowController({model: model, listOfAliases: @listOfAliases})
    rowControllers.bind "isDirty", (newAlias) =>
      @collection.add newAlias

    rowControllers.bind "removedRow", @render
    @$(".bv_aliasTableBody").append(rowControllers.render().el)

  render: =>
    $(@el).html($('#AddAliasTable_template').html())
    numRows = 0
    @collection.sort()
    @collection.each((model) =>
      unless model.get('ignored')
        @addRow(model)
        numRows++
    )
    @setStateOfButtons()
#    @$(".bv_aliasRemove").removeClass("hide")
    @

class window.AliasRowController extends Backbone.View
  template: $('#AddAliasRow_template').html()
  tagName: 'tr'
  events:
    "click .bv_aliasRemove": "handleAliasRemoveClick"
    "change .bv_aliasTypeContainer": "handleInputChange"
    "change .bv_aliasKind": "handleInputChange"

  initialize: ->
    @model = @options.model
    @listOfAliases = @options.listOfAliases

  handleAliasRemoveClick: =>
    if @model.get("id")? # if the alias already exists, set it to ignored
      @model.set({"ignored": true})
    else # if the alias hasn't been saved yet, just destroy the model / remove it from the collection
      @model.destroy()

    @trigger "removedRow"

  scrapeForm: =>
    formValues =
      aliasName: @$(".bv_aliasKind").val()
      lsType: @$(".bv_aliasTypeContainer").val()

    if formValues.aliasName is ""
      formValues.aliasName = " "
    formValues

  handleInputChange: =>
    formValues = @scrapeForm()
    if @model.get("id")?
      @model.set({"ignored": true})
      formValues.sortId = @model.get("sortId")
      newAlias = new AliasModel formValues
      @trigger "isDirty", newAlias
    else
      @model.set formValues

  render: =>
    $(@.el).html(_.template($('#AddAliasRow_template').html(), @model.toJSON()))
		if @model.get('id')? and window.configuration.metaLot.disableAliasEdit? and window.configuration.metaLot.disableAliasEdit is true
			@$('.bv_aliasTypeContainer').attr 'disabled', 'disabled'
			@$('.bv_aliasKind').attr 'disabled', 'disabled'
			@$('.bv_aliasRemove').addClass("hide")
		else
			@$('.bv_aliasTypeContainer').removeAttr 'disabled'
			@$('.bv_aliasKind').removeAttr 'disabled'
			@$('.bv_aliasRemove').removeClass("hide")
			cloneOfAliasTypes = $.extend(true, {}, @listOfAliases)
			optionToInsert = new AliasList({"kindName":"Select Type","lsType":{"id":0,"typeName":"not_set","version":0},"version":0});
			@aliasType = new AliasListSelectController({
				el: this.$('.bv_aliasTypeContainer'),
				type: "parentaliaskinds",
				collection: cloneOfAliasTypes,
				selectedCode: @model.get("lsType"),
				insertFirstOption: optionToInsert
			})
			@aliasType.handleListReset()

		@



class window.AliasModel extends Backbone.Model
  defaults:
    aliasName: ""
    lsType: ""
    deleted:false
    ignored:false
    lsKind:"Parent Common Name"
    preferred:false
    version:0
    sortId: null


  validate: (attrs, options) ->

    errors = []
    if attrs.lsType?
      if attrs.lsType is "not_set:Select Type"
        errors.push("Alias Type not set")
    if attrs.lsKind?
      if $.trim(attrs.aliasName) is ""
        errors.push("Alias Name not set")


    if errors.length > 0
      return errors
    else
      return null

class window.AliasCollection extends Backbone.Collection
  model: AliasModel
  comparator: (item) ->
    return item.get("sortId")
  modelsAreAllValid: ->
    modelsAreValid = true
    @each((model) ->
      isValid = model.validate(model.toJSON())
      unless isValid is null
        modelsAreValid = false
    )
    modelsAreValid

class window.AliasListReadView extends Backbone.View
  template: $("#AliasListReadView").html()
  tagName: 'span'
  initialize: ->
    @collection = @options.collection

  addItem: (model) =>
    item = new AliasItem({model: model})
    @$(".bv_aliasListContainer").append item.render().el

  render: =>
    $(@el).html $("#AliasListReadView").html()
    @collection.each((model) =>
      unless model.get("ignored")
        @addItem model
    )

    @

class window.AliasItem extends Backbone.View
  template: $("#AliasItemView").html()
  tagName: 'span'
  render: =>
    $(@el).html _.template($('#AliasItemView').html(), @model.toJSON())

    @