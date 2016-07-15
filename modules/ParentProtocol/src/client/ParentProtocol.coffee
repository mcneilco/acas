class window.ParentProtocol extends BaseEntity
	urlRoot: "/api/protocols/parentProtocol"

	defaults: ->
		_(super()).extend(
			childProtocols: new ChildProtocolItemList()
		)

	initialize: ->
		@.set
			lsType: "Parent"
			lsKind: "Parent Bio Activity"
			subclass: "protocol"
		super()

	parse: (resp) =>
		if resp == "not unique protocol name" or resp == '"not unique protocol name"'
			@trigger 'notUniqueName'
			resp
		else if resp == "saveFailed" or resp == '"saveFailed"'
			@trigger 'saveFailed'
			resp
		else
			if resp.lsLabels?
				if resp.lsLabels not instanceof LabelList
					resp.lsLabels = new LabelList(resp.lsLabels)
				resp.lsLabels.on 'change', =>
					@trigger 'change'
			if resp.lsStates?
				if resp.lsStates not instanceof StateList
					resp.lsStates = new StateList(resp.lsStates)
				resp.lsStates.on 'change', =>
					@trigger 'change'
			if resp.lsTags not instanceof TagList
				resp.lsTags = new TagList(resp.lsTags)
				resp.lsTags.on 'change', =>
					@trigger 'change'
			if resp.childProtocols not instanceof ChildProtocolItemList
				resp.childProtocols = _.filter resp.childProtocols, (itx) ->
					!itx.ignored
				resp.childProtocols = new ChildProtocolItemList(resp.childProtocols)
			resp.childProtocols.on 'change', =>
				@trigger 'change'
			resp
	validate: (attrs) ->
		errors = []
#		errors.push super(attrs)...
		if errors.length > 0
			return errors
		else
			return null

class window.ChildProtocolItem extends Backbone.Model
	defaults: ->
		itxId: null
		secondProtId: "unassigned" #TODO: this is really saving secondProtCodeName right now
		secondProtCodeName: "unassigned"
		ignored: false
		recordedBy: window.AppLaunchParams.loginUser.username
		recordedDate: new Date().getTime()

	validate: (attrs) ->
		errors = []
		if attrs.secondProtCodeName is "unassigned" or attrs.secondProtCodeName is null or attrs.secondProtCodeName is undefined
			errors.push
				attribute: 'childProtocol'
				message: 'Child Protocol must be selected'

		if errors.length > 0
			return errors
		else
			return null


class window.ChildProtocolItemList extends Backbone.Collection
	model: ChildProtocolItem

	validateCollection: =>
		modelErrors = []
		usedProtocols = {}
		#filter out ignored children protocol
		nonIgnoredChildProtocols = @.where ignored: false
		index = 0
		_.each nonIgnoredChildProtocols, (model) ->
# note: can't call model.isValid() because if invalid, the function will trigger validationError,
# which adds the class "error" to the invalid attributes
			indivModelErrors = model.validate(model.attributes)
			if indivModelErrors?
				for error in indivModelErrors
					modelErrors.push
						attribute: error.attribute+':eq('+index+')'
						message: error.message
			currentProtocol = model.get('secondProtCodeName')
			if currentProtocol of usedProtocols
				modelErrors.push
					attribute: 'childProtocol:eq('+index+')'
					message: "This child protocol has already been selected"
			else
				usedProtocols[currentProtocol] = index
			index++
		return modelErrors


class window.ParentProtocolController extends BaseEntityController
	template: _.template($("#ParentProtocolView").html())
	moduleLaunchName: "parent_protocol"

	events: ->
		"click .bv_save": "handleSaveModule"
		"click .bv_cancel": "handleCancelClicked"
		"keyup .bv_protocolName": "handleNameChanged"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/protocols/parentProtocol/codename/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) =>
							alert 'Could not get protocol for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get protocol for code in this URL, creating new one'
							else
								lsKind = json.lsKind
								if lsKind is "Parent Bio Activity"
									prot = new ParentProtocol json
									prot.set prot.parse(prot.attributes)
									if window.AppLaunchParams.moduleLaunchParams.copy
										@model = prot.duplicateEntity()
									else
										@model = prot
								else
									alert 'Could not get protocol for code in this URL. Creating new protocol'
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		@errorOwnerName = 'ParentProtocolController'
		unless @model?
			@model = new ParentProtocol()
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		$(@el).empty()
		$(@el).html @template @model.attributes
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'error', @modelErrorCallback
		@listenTo @model, 'change', @modelChangeCallback
		@setupChildProtocols()
		@render()

	render: =>
		unless @model?
			@model = new ParentProtocol()
		super()
		@

	setupChildProtocols: =>
		if @childProtocolListController?
			@childProtocolListController.undelegateEvents()
		@childProtocolListController = new ChildProtocolListController
			el: @$('.bv_childProtocolList')
			collection: @model.get 'childProtocols'
		@childProtocolListController.render()
		@childProtocolListController.on 'updateState', =>
			@trigger 'updateState'
		@childProtocolListController.on 'amDirty', =>
			@trigger 'amDirty'
			@model.trigger 'change'
#			@isValid()

	handleSaveModule: =>
		@$('.bv_saving').show()
		@model.save null,
			success: (model, response, options) =>
				@$('.bv_updateComplete').show()
				@$('.bv_updateComplete').html "Save Complete"
				@$('.bv_save').html "Update"
#				@$(".bv_protocolCodeName").html @model.get('codeName')
			error: (model, response, options) =>
				@$('.bv_updateComplete').show()

	modelSyncCallback: =>
		@trigger 'amClean'
		unless @model.get('subclass')?
			@model.set subclass: 'protocol'
		@$('.bv_saving').hide()
		if @$('.bv_saveFailed').is(":visible") or @$('.bv_cancelComplete').is(":visible")
			@$('.bv_updateComplete').hide()
			@trigger 'amDirty'
		else
			@$('.bv_updateComplete').show()
		@render()
		@setupChildProtocols()

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_updateComplete').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.cancelComplete').hide()
		@$('.saveFailed').hide()

	modelErrorCallback: =>
		@$('.bv_saving').hide()
		# Other errors should be handled elsewhere

	handleCancelClicked: =>
		if @model.isNew()
			@model = null
			@completeInitialization()
			@trigger 'amClean'
			@render()
		else
			@$('.bv_cancelingModule').show()
			@model.fetch
				success: @handleCancelComplete
				error: @handleCancelFailure


	handleCancelComplete: =>
		@model.initialize()
		@$('.bv_cancelingModule').hide()
		@$('.bv_cancelModuleComplete').show()
		@trigger 'amClean'
		@render()

	handleCancelFailure: =>
		@$('.bv_cancelingModule').hide()
		@$('.bv_cancelModuleFailure').show()

	isValid: =>
		validCheck = super()
		if @childProtocolListController?
			unless @childProtocolListController.isValid() is true
				@$('.bv_save').attr 'disabled', 'disabled'
				validCheck = false
		if validCheck
			@$('.bv_save').removeAttr 'disabled'
		else
			@$('.bv_save').attr 'disabled', 'disabled'

		validCheck

class window.ChildProtocolItemController extends AbstractFormController
	template: _.template($("#ChildProtocolItemView").html())
	events:
		"change .bv_childProtocol": "attributeChanged"
		"click .bv_deleteChildProtocol": "clear"

	initialize: ->
		@errorOwnerName = 'ChildProtocolItemController'
		@setBindings()
		@model.on "destroy", @remove, @
		@model.bind 'amDirty', => @trigger 'amDirty', @


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setUpChildProtocolSelect()
		@

	updateModel: =>
		selectedModel = @childProtocolPickListController.getSelectedModel()
		if selectedModel.get('id')?
			secondProtId = selectedModel.get('id')
		else
			secondProtId = null
		@model.set secondProtId: secondProtId
		@model.set secondProtCodeName: @childProtocolPickListController.getSelectedCode()
		@trigger 'amDirty'

	setUpChildProtocolSelect: ->
		@childProtocolList = new PickListList()
		@childProtocolList.url = "/api/protocolCodes/?protocolKind=Bio Activity"
		@childProtocolPickListController = new PickListSelectController
			el: @$('.bv_childProtocol')
			collection: @childProtocolList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Child Protocol"
			selectedCode: @model.get('secondProtCodeName') #TODO: actually secondProtId is secondProCodeName right now


	clear: =>
		@$('.bv_group_childProtocol').tooltip 'destroy'
		if @model.get('itxId')?
			@model.set 'ignored', true
			@$('.bv_childProtocolWrapper').hide()
		else
			@model.destroy()
		@trigger 'removeChildProtocol'
		@attributeChanged()

class window.ChildProtocolListController extends AbstractFormController
	template: _.template($("#ChildProtocolItemListView").html())
	events: ->
		"click .bv_addChildProtocolButton": "addNewChildProtocol"

	initialize: =>
		@collection.on 'remove', @checkNumberOfChildProtocols
		@collection.on 'remove', => @collection.trigger 'amDirty'
		@collection.on 'remove', => @collection.trigger 'change'


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (childProtocol) =>
			@addOneChildProtocol(childProtocol)
		if @collection.length == 0
			@addNewChildProtocol(true)
		@

	addNewChildProtocol: (skipAmDirtyTrigger)=>
		newModel = new ChildProtocolItem()
		@collection.add newModel
		@addOneChildProtocol(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'


	addOneChildProtocol: (childProtocol) ->
		controller = new ChildProtocolItemController
			model: childProtocol
		@$('.bv_childProtocolInfo').append controller.render().el
		controller.on 'updateState', =>
			@trigger 'updateState'
		controller.on 'removeChildProtocol', =>
			@checkNumberOfChildProtocols()
			@trigger 'amDirty'
		controller.on 'amDirty', =>
			@trigger 'amDirty'


	checkNumberOfChildProtocols: => #ensures that there is always one childProtocol
		nonIgnoredModels = @collection.where ignored: false
		if nonIgnoredModels.length == 0
			@addNewChildProtocol()

	isValid: =>
		validCheck = true
		errors = @collection.validateCollection()
		if errors.length > 0
			validCheck = false
		@validationError(errors)
		validCheck

	validationError: (errors) =>
		@clearValidationErrorStyles()
		_.each errors, (err) =>
			unless @$('.bv_'+err.attribute).attr('disabled') is 'disabled'
				@$('.bv_group_'+err.attribute).attr('data-toggle', 'tooltip')
				@$('.bv_group_'+err.attribute).attr('data-placement', 'bottom')
				@$('.bv_group_'+err.attribute).attr('data-original-title', err.message)
				#				@$('.bv_group_'+err.attribute).tooltip();
				@$("[data-toggle=tooltip]").tooltip();
				@$("body").tooltip selector: '.bv_group_'+err.attribute
				@$('.bv_group_'+err.attribute).addClass 'input_error error'
				@trigger 'notifyError',  owner: this.errorOwnerName, errorLevel: 'error', message: err.message

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		_.each errorElms, (ee) =>
			$(ee).removeAttr('data-toggle')
			$(ee).removeAttr('data-placement')
			$(ee).removeAttr('title')
			$(ee).removeAttr('data-original-title')
			$(ee).removeClass 'input_error error'

