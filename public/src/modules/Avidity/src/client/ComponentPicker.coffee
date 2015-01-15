class window.AddComponent extends Backbone.Model
	defaults: ->
		componentType: "unassigned"

class window.ComponentCodeName extends Backbone.Model
	defaults: ->
		componentType: ""
		componentCodeName: "unassigned"

	validate: (attrs) ->
		errors = []
		if attrs.componentCodeName is "unassigned" or attrs.componentCodeName is ""
			errors.push
				attribute: 'componentCodeName'
				message: "ID must be selected"

		if errors.length > 0
			return errors
		else
			return null

class window.ComponentCodeNamesList extends Backbone.Collection
	model: ComponentCodeName

class window.AddComponentController extends Backbone.View
	template: _.template($("#AddComponentView").html())

	events:
		"change .bv_addComponentSelect": "updateModel"
		"click .bv_addComponentButton": "handleAddComponentClicked"

	initialize: ->
		unless @model?
			@model=new AddComponent()
	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setUpAddComponentSelect()

		@

	updateModel: =>
		@model.set componentType: @componentTypeListController.getSelectedCode()
		@trigger 'amDirty'


	setUpAddComponentSelect: ->
		@componentTypeList = new PickListList()
		@componentTypeList.url = "/api/dataDict/subcomponents/internalization agent"
		@componentTypeListController = new PickListSelectController
			el: @$('.bv_addComponentSelect')
			collection: @componentTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Component"
			selectedCode: @model.get('componentType')

	handleAddComponentClicked: ->
		@trigger 'addComponent'

class window.ComponentCodeNameController extends AbstractFormController
	template: _.template($("#ComponentCodeNameView").html())

	events:
		"change .bv_componentCodeName": "attributeChanged"
		"click .bv_deleteComponent": "clear"

	initialize: ->
		unless @model?
			@model=new ComponentCodeName()
		@errorOwnerName = 'ComponentCodeNameController'
		@setBindings()
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_componentType').html(@model.get('componentType'))
		@setUpComponentCodeNameSelect()

		@

	updateModel: =>
		@model.set componentCodeName: @componentCodeNameListController.getSelectedCode()


	setUpComponentCodeNameSelect: ->
		@componentCodeNameList = new PickListList()
		@componentCodeNameList.url = "/api/dataDict/codeNames/"+@model.get('componentType').toLowerCase()
		@componentCodeNameListController = new PickListSelectController
			el: @$('.bv_componentCodeName')
			collection: @componentCodeNameList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Component ID"
			selectedCode: @model.get('componentCodeName')

	clear: =>
		@model.destroy()

class window.ComponentCodeNamesListController extends AbstractFormController
	template: _.template($("#ComponentCodeNamesListView").html())

	initialize: ->
		unless @collection?
			@collection = new ComponentCodeNamesList()
#			@addNewComponentSelect(true)


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (component) =>
			@addComponentSelect(component)
		@

	addNewComponentSelect: (componentType) =>
		newModel = new ComponentCodeName
			componentType: componentType
		@collection.add newModel
		@addComponentSelect(newModel)


	addComponentSelect: (component) ->
		ccnc = new ComponentCodeNameController
			model: component
		@$('.bv_componentInfo').append ccnc.render().el

class window.ComponentPickerController extends Backbone.View
	template: _.template($("#ComponentPickerView").html())

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@setupAddComponentController()
		@setupComponentCodeNamesListController()
		@

	setupAddComponentController: ->
		@addComponentController = new AddComponentController
			model: new AddComponent()
			el: @$('.bv_addComponentWrapper')
		@addComponentController.on 'amDirty', =>
			@trigger 'amDirty'
		@addComponentController.on 'amClean', =>
			@trigger 'amClean'
		@addComponentController.on 'addComponent', =>
			@addNewComponentCodeNameController()
		@addComponentController.render()

	setupComponentCodeNamesListController: ->
		@codeNamesListController = new ComponentCodeNamesListController
			collection: new ComponentCodeNamesList()
			el: @$('.bv_codeNamesListWrapper')
		@codeNamesListController.on 'amDirty', =>
			@trigger 'amDirty'
		@codeNamesListController.on 'amClean', =>
			@trigger 'amClean'
		@codeNamesListController.render()

	addNewComponentCodeNameController: ->
		console.log "addNewComponentCodeNameController"
		componentType = @addComponentController.componentTypeListController.getSelectedCode()
		unless componentType is "unassigned"
			@codeNamesListController.addNewComponentSelect (@addComponentController.componentTypeListController.getSelectedCode())