class window.AssignedProperty extends Backbone.Model
	defaults:
		sdfProp: "sdfProp"
		dbProp: "unassigned"
		defaultVal: ""

class window.AssignedPropertiesList extends Backbone.Collection
	model: AssignedProperty

class window.AssignedPropController extends AbstractFormController
	template: _.template($("#AssignedPropView").html())
	className: "form-inline"

	events:
		"click .bv_deleteProp": "clear"

	initialize: ->
		unless @model?
			@model = new AssignedProperty()
		@errorOwnerName = 'AssignedPropController'
		@setBindings()
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@$('.bv_sdfProp').html(@model.get('sdfProp'))
		@setupDbPropSelect()
		@$('.bv_defaultVal').val @model.get('defaultVal')

		@

	setupDbPropSelect: ->
		@dbPropList = new PickListList()
		@dbPropList.url = "/api/codetables/properties/database"
		@dbPropListController = new PickListSelectController
			el: @$('.bv_dbProp')
			collection: @dbPropList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Database Property"
			selectedCode: @model.get('dbProp')

	clear: =>
#		@model.trigger 'amDirty'
		@model.destroy()
#		@attributeChanged()

class window.AssignedPropListController extends Backbone.View
	template: _.template($("#AssignedPropListView").html())

	events:
		"click .bv_addDbProp": "addNewProp"

	initialize: =>
#		@collection.on 'remove', => @collection.trigger 'change'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (prop) =>
			@addOneProp(prop)

		@

	addNewProp: =>
		newModel = new AssignedProperty()
		@collection.add newModel
		@addOneProp(newModel)
		newModel.trigger 'amDirty'

	addOneProp: (prop) ->
		apc = new AssignedPropController
			model: prop
		@$('.bv_propInfo').append apc.render().el
#		apc.on 'updateState', =>
#			@trigger 'updateState'

class window.CmpdRegBulkLoaderAppController extends Backbone.View
	template: _.template($("#CmpdRegBulkLoaderAppView").html())
#	events:
#		"click .bv_addDbProp": "handleAddDbPropClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		$(@el).addClass 'CmpdRegBulkLoaderAppController'
		@disableAllInputs()
		@setupBrowseFileController()
		@setupAssignedPropListController()
#		@startBasicQueryWizard()

	setupBrowseFileController: =>
		@browseFileController = new LSFileChooserController
			el: @$('.bv_browseFile')
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['sdf']
#			hideDelete: false
		@browseFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@browseFileController.on 'amClean', =>
			@trigger 'amClean'
		@browseFileController.render()
		@browseFileController.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@browseFileController.on('fileDeleted', @handleFileRemoved) #update model with filename

	handleFileUpload: (nameOnServer, data) =>
		console.log "file uploaded"
		#TODO: need to call service to read the first 100 records
		#TODO: disable browsing for another file while service to read records is still running - perhaps have spinner that says "Reading..." or use modal
		@enableAllEditableInputs()

	setupAssignedPropListController: ->
		@assignedPropListController= new AssignedPropListController
			el: @$('.bv_assignedPropList')
			collection: new AssignedPropertiesList()
#			collection: @model.get('assignedPropertiesList')
		@assignedPropListController.render()
#		@assignedPropListController.on 'updateState', =>
#			@trigger 'updateState'

#	handleAddDbPropClicked: =>
#		console.log "add db prop clicked"


	disableAllInputs: ->
		@$('input').attr 'disabled', 'disabled'
		@$('button').attr 'disabled', 'disabled'
		@$('select').attr 'disabled', 'disabled'
		@$("textarea").attr 'disabled', 'disabled'

	enableAllEditableInputs: ->
		@$('.bv_defaultVal').removeAttr 'disabled'
		@$('select').removeAttr 'disabled'
		@$('button').removeAttr 'disabled'
		@$('.bv_regCmpds').attr 'disabled', 'disabled'
