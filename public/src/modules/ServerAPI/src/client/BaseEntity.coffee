class window.BaseEntity extends Backbone.Model
	urlRoot: "/api/experiments" # should be set the proper value in subclasses

	defaults: ->
		subclass: "entity"
		lsType: "default"
		lsKind: "default"
		recordedBy: window.AppLaunchParams.loginUser.username
		recordedDate: new Date().getTime()
		shortDescription: " "
		lsLabels: new LabelList()
		lsStates: new StateList()

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
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
		resp

	getScientist: ->
		metadataKind = @.get('subclass') + " metadata"
		scientist = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "codeValue", "scientist"
		if scientist.get('codeValue') is undefined
			scientist.set codeValue: "unassigned"
			scientist.set codeType: "assay"
			scientist.set codeKind: "scientist"
			scientist.set codeOrigin: window.conf.scientistCodeOrigin

		scientist

	getDetails: ->
		metadataKind = @.get('subclass') + " metadata"
		entityDetails = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "clobValue", @.get('subclass') + " details"
		if entityDetails.get('clobValue') is undefined or entityDetails.get('clobValue') is ""
			entityDetails.set clobValue: ""

		entityDetails

	getComments: ->
		metadataKind = @.get('subclass') + " metadata"
		comments = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "clobValue", "comments"
		if comments.get('clobValue') is undefined or comments.get('clobValue') is ""
			comments.set clobValue: ""

		comments

	getNotebook: ->
		metadataKind = @.get('subclass') + " metadata"
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "stringValue", "notebook"

	getStatus: ->
		subclass = @.get('subclass')
		metadataKind = subclass + " metadata"
		valueKind = subclass + " status"
		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "codeValue", valueKind
		if status.get('codeValue') is undefined or status.get('codeValue') is ""
			status.set codeValue: "created"
			status.set codeType: subclass
			status.set codeKind: "status"
			status.set codeOrigin: "ACAS DDICT"

		status

	getAnalysisParameters: =>
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
		if ap.get('clobValue')?
			return new PrimaryScreenAnalysisParameters $.parseJSON(ap.get('clobValue'))
		else
			return new PrimaryScreenAnalysisParameters()

	getModelFitParameters: =>
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters"
		if ap.get('clobValue')?
			return $.parseJSON(ap.get('clobValue'))
		else
			return {}


	isEditable: ->
		status = @getStatus().get 'codeValue'
		switch status
			when "created" then return true
			when "started" then return true
			when "complete" then return true
			when "finalized" then return false
			when "rejected" then return false
		return true

	validate: (attrs) ->
		errors = []
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		if bestName?
			nameError = true
			if bestName.get('labelText') != ""
				nameError = false
		if nameError
			errors.push
				attribute: attrs.subclass+'Name'
				message: attrs.subclass+" name must be set"
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: attrs.subclass+" date must be set"
		if attrs.subclass?
			notebook = @getNotebook().get('stringValue')
			if notebook is "" or notebook is undefined or notebook is null
				errors.push
					attribute: 'notebook'
					message: "Notebook must be set"
			scientist = @getScientist().get('codeValue')
			if scientist is "unassigned" or scientist is undefined or scientist is "" or scientist is null
				errors.push
					attribute: 'scientist'
					message: "Scientist must be set"

		if errors.length > 0
			return errors
		else
			return null

	prepareToSave: ->
		rBy = window.AppLaunchParams.loginUser.username
		rDate = new Date().getTime()
		@set recordedDate: rDate
		@get('lsLabels').each (lab) ->
			unless lab.get('recordedBy') != ""
				lab.set recordedBy: rBy
			unless lab.get('recordedDate') != null
				lab.set recordedDate: rDate
		@get('lsStates').each (state) ->
			unless state.get('recordedBy') != ""
				state.set recordedBy: rBy
			unless state.get('recordedDate') != null
				state.set recordedDate: rDate
			state.get('lsValues').each (val) ->
				unless val.get('recordedBy') != ""
					val.set recordedBy: rBy
				unless val.get('recordedDate') != null
					val.set recordedDate: rDate
		if @attributes.subclass?
			delete @attributes.subclass
		if @attributes.protocol?
			if @attributes.protocol.attributes.subclass?
				delete @attributes.protocol.attributes.subclass
		@trigger "readyToSave", @

	duplicateEntity: =>
		copiedEntity = @.clone()
		copiedEntity.unset 'lsLabels'
		copiedEntity.unset 'lsStates'
		copiedEntity.unset 'id'
		copiedEntity.unset 'codeName'
		copiedStates = new StateList()
		origStates = @get('lsStates')
		origStates.each (st) ->
			copiedState = new State(_.clone(st.attributes))
			copiedState.unset 'id'
			copiedState.unset 'lsTransactions'
			copiedState.unset 'lsValues'
			copiedValues = new ValueList()
			origValues = st.get('lsValues')
			origValues.each (sv) ->
				copiedVal = new Value(sv.attributes)
				copiedVal.unset 'id'
				copiedVal.unset 'lsTransaction'
				copiedValues.add(copiedVal)
			copiedState.set lsValues: copiedValues
			copiedStates.add(copiedState)
		copiedEntity.set
			lsLabels: new LabelList()
			lsStates: copiedStates
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
			version: 0
		copiedEntity.getStatus().set codeValue: "created"
		copiedEntity.getNotebook().set stringValue: ""
		copiedEntity.getScientist().set codeValue: "unassigned"

		copiedEntity

class window.BaseEntityList extends Backbone.Collection
	model: BaseEntity

class window.BaseEntityController extends AbstractFormController
	template: _.template($("#BaseEntityView").html())

	events: ->
		"change .bv_scientist": "handleScientistChanged"
		"change .bv_shortDescription": "handleShortDescriptionChanged"
		"change .bv_details": "handleDetailsChanged"
		"change .bv_comments": "handleCommentsChanged"
		"change .bv_entityName": "handleNameChanged"
#		"change .bv_completionDate": "handleDateChanged"
#		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"change .bv_notebook": "handleNotebookChanged"
		"change .bv_status": "handleStatusChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"


	initialize: ->
		unless @model?
			@model=new BaseEntity()
		@model.on 'sync', @modelSyncCallback
		@model.on 'change', @modelChangeCallback
		@errorOwnerName = 'BaseEntityController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_save').attr('disabled', 'disabled')
		@setupStatusSelect()
		@setupScientistSelect()
		@setupTagList()
		@model.getStatus().on 'change', @updateEditable

	render: =>
		unless @model?
			@model = new BaseEntity()
		subclass = @model.get('subclass')
		unless @model.get('shortDescription') is " "
			@$('.bv_shortDescription').html @model.get('shortDescription')
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_'+subclass+'Name').val bestName.get('labelText')
		@$('.bv_scientist').val(@model.getScientist().get('codeValue'))
		@$('.bv_'+subclass+'Code').html(@model.get('codeName'))
		@$('.bv_'+subclass+'Kind').html(@model.get('lsKind')) #should get value from protocol create form
		@$('.bv_details').val(@model.getDetails().get('clobValue'))
		@$('.bv_comments').val(@model.getComments().get('clobValue'))
		@$('.bv_notebook').val @model.getNotebook().get('stringValue')
		@$('.bv_status').val(@model.getStatus().get('codeValue'))
		if @model.isNew()
			@$('.bv_save').html("Save")
			@$('.bv_newEntity').hide()
		else
			@$('.bv_save').html("Update")
			@$('.bv_newEntity').show()
		@updateEditable()

		@

	modelSyncCallback: =>
		@trigger 'amClean'
		unless @model.get('subclass')?
			@model.set subclass: 'entity'
		@$('.bv_saving').hide()
		@$('.bv_updateComplete').show()
		@render()

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_updateComplete').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_cancelComplete').hide()

	setupStatusSelect: ->
		statusState = @model.getStatus()
		@statusList = new PickListList()
		@statusList.url = "/api/codetables/"+statusState.get('codeType')+"/"+statusState.get('codeKind')
		@statusListController = new PickListSelectController
			el: @$('.bv_status')
			collection: @statusList
			selectedCode: statusState.get 'codeValue'

	setupScientistSelect: ->
		@scientistList = new PickListList()
		@scientistList.url = "/api/authors"
		@scientistListController = new PickListSelectController
			el: @$('.bv_scientist')
			collection: @scientistList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Scientist"
			selectedCode: @model.getScientist().get('codeValue')

	setupTagList: ->
		@$('.bv_tags').val ""
		@tagListController = new TagListController
			el: @$('.bv_tags')
			collection: @model.get 'lsTags'
		@tagListController.render()


	handleScientistChanged: =>
		@model.getScientist().set
			codeValue: @scientistListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleShortDescriptionChanged: =>
		trimmedDesc = UtilityFunctions::getTrimmedInput @$('.bv_shortDescription')
		if trimmedDesc != ""
			@model.set
				shortDescription: trimmedDesc
				recordedBy: window.AppLaunchParams.loginUser.username
				recordedDate: new Date().getTime()
		else
			@model.set
				shortDescription: " " #fix for oracle persistance bug
				recordedBy: window.AppLaunchParams.loginUser.username
				recordedDate: new Date().getTime()

	handleDetailsChanged: =>
		@model.getDetails().set
			clobValue: UtilityFunctions::getTrimmedInput @$('.bv_details')
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleCommentsChanged: =>
		@model.getComments().set
			clobValue: UtilityFunctions::getTrimmedInput @$('.bv_comments')
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleNameChanged: =>
		subclass = @model.get('subclass')
		newName = UtilityFunctions::getTrimmedInput @$('.bv_'+subclass+'Name')
		@model.get('lsLabels').setBestName new Label
			lsKind: subclass+" name"
			labelText: newName
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		#TODO label change propagation isn't really working, so this is the work-around
		@model.trigger 'change'

	handleNotebookChanged: =>
		@model.getNotebook().set
			stringValue: UtilityFunctions::getTrimmedInput @$('.bv_notebook')
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		@model.trigger 'change'

	handleStatusChanged: =>
		@model.getStatus().set
			codeValue: @statusListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		# this is required in addition to model change event watcher only for spec. real app works without it
		@updateEditable()
		@model.trigger 'change'



	updateEditable: =>
		if @model.isEditable()
			@enableAllInputs()
			@$('.bv_lock').hide()
			@$('.bv_save').attr('disabled', 'disabled')
			@$('.bv_cancel').attr('disabled','disabled')
		else
			@disableAllInputs()
			@$('.bv_status').removeAttr('disabled')
			@$('.bv_lock').show()
		if @model.isNew()
			@$('.bv_status').attr("disabled", "disabled")
		else
			@$('.bv_status').removeAttr("disabled")

	beginSave: =>
		@tagListController.handleTagsChanged()
		if @model.checkForNewPickListOptions?
			@model.checkForNewPickListOptions()
		else
			@trigger "noEditablePickLists"

	handleSaveClicked: =>
		@tagListController.handleTagsChanged()
		@model.prepareToSave()
		if @model.isNew()
			@$('.bv_updateComplete').html "Save Complete"
		else
			@$('.bv_updateComplete').html "Update Complete"
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_saving').show()
		@model.save()

	handleNewEntityClicked: =>
		if @model.get('lsKind') is "default" #base protocol/experiment
			@model = null
			@completeInitialization()
		else
			@trigger 'reinitialize'
		@trigger 'amClean'

	handleCancelClicked: =>
		if @model.isNew()
			if @model.get('lsKind') is "default" #base protocol/experiment
				@model = null
				@completeInitialization()
			else
				@trigger 'reinitialize'
		else
			@$('.bv_canceling').show()
			@model.fetch
				success: @handleCancelComplete
		@trigger 'amClean'

	handleCancelComplete: =>
		@$('.bv_canceling').hide()
		@$('.bv_cancelComplete').show()

	validationError: =>
		super()
		@$('.bv_save').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_save').removeAttr('disabled')

	displayInReadOnlyMode: =>
		@$(".bv_save").addClass "hide"
		@disableAllInputs()

