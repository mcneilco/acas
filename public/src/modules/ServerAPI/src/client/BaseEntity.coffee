class window.BaseEntity extends Backbone.Model
	urlRoot: "/api/experiments" # should be set the proper value in subclasses

	defaults: ->
		subclass: "entity"
		lsType: "default"
		lsKind: "default"
		recordedBy: ""
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


	getDescription: ->
		metadataKind = @.get('subclass') + " metadata"
		description = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "clobValue", "description"
		if description.get('clobValue') is undefined or description.get('clobValue') is ""
			description.set clobValue: ""

		description

	getComments: ->
		metadataKind = @.get('subclass') + " metadata"
		comments = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "clobValue", "comments"
		if comments.get('clobValue') is undefined or comments.get('clobValue') is ""
			comments.set clobValue: ""

		comments

	getCompletionDate: ->
		metadataKind = @.get('subclass') + " metadata"
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "dateValue", "completion date"


	getNotebook: ->
		metadataKind = @.get('subclass') + " metadata"
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "stringValue", "notebook"

	getStatus: ->
		metadataKind = @.get('subclass') + " metadata"
		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "stringValue", "status"
		if status.get('stringValue') is undefined or status.get('stringValue') is ""
			status.set stringValue: "created"

		status

	getAnalysisParameters: =>
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "analysis parameters", "clobValue", "data analysis parameters"
		if ap.get('clobValue')?
			return new PrimaryScreenAnalysisParameters $.parseJSON(ap.get('clobValue'))
		else
			return new PrimaryScreenAnalysisParameters()

	getModelFitParameters: =>
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "analysis parameters", "clobValue", "model fit parameters"
		if ap.get('clobValue')?
			return $.parseJSON(ap.get('clobValue'))
		else
			return {}


	isEditable: ->
		status = @getStatus().get 'stringValue'
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
		if attrs.recordedBy is ""
			errors.push
				attribute: 'recordedBy'
				message: "Scientist must be set"
		cDate = @getCompletionDate().get('dateValue')
		if cDate is undefined or cDate is "" then cDate = "fred"
		if isNaN(cDate)
			errors.push
				attribute: 'completionDate'
				message: "Assay completion date must be set"
		notebook = @getNotebook().get('stringValue')
		if notebook is "" or notebook is "unassigned" or notebook is undefined
			errors.push
				attribute: 'notebook'
				message: "Notebook must be set"

		if errors.length > 0
			return errors
		else
			return null

	prepareToSave: ->
		rBy = @get('recordedBy')
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
		@trigger "readyToSave", @


class window.BaseEntityList extends Backbone.Collection
	model: BaseEntity

class window.BaseEntityController extends AbstractFormController
	template: _.template($("#BaseEntityView").html())

	events: ->
		"change .bv_recordedBy": "handleRecordedByChanged"
		"change .bv_shortDescription": "handleShortDescriptionChanged"
		"change .bv_description": "handleDescriptionChanged"
		"change .bv_comments": "handleCommentsChanged"
		"change .bv_entityName": "handleNameChanged"
		"change .bv_completionDate": "handleDateChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"change .bv_notebook": "handleNotebookChanged"
		"change .bv_status": "handleStatusChanged"
		"click .bv_save": "handleSaveClicked"


	initialize: ->
		unless @model?
			@model=new BaseEntity()
		@model.on 'sync', =>
			@trigger 'amClean'
			@$('.bv_saving').hide()
			@$('.bv_updateComplete').show()
			@$('.bv_save').attr('disabled', 'disabled')
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
			@$('.bv_updateComplete').hide()
		@errorOwnerName = 'BaseEntityController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_save').attr('disabled', 'disabled')
		@setupStatusSelect()
		@setupTagList()
		@model.getStatus().on 'change', @updateEditable

	render: =>
		unless @model?
			@model = new BaseEntity()
		subclass = @model.get('subclass')
		@$('.bv_shortDescription').html @model.get('shortDescription')
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_'+subclass+'Name').val bestName.get('labelText')
		@$('.bv_recordedBy').val(@model.get('recordedBy'))
		@$('.bv_'+subclass+'Code').html(@model.get('codeName'))
		@$('.bv_'+subclass+'Kind').html(@model.get('lsKind')) #should get value from protocol create form
		@$('.bv_description').html(@model.getDescription().get('clobValue'))
		@$('.bv_comments').html(@model.getComments().get('clobValue'))
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.getCompletionDate().get('dateValue')?
			@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.getCompletionDate().get('dateValue'))
		@$('.bv_notebook').val @model.getNotebook().get('stringValue')
		@$('.bv_status').val(@model.getStatus().get('stringValue'))
		if @model.isNew()
			@$('.bv_save').html("Save")
		else
			@$('.bv_save').html("Update")
		@updateEditable()

		@

	setupStatusSelect: ->
		@statusList = new PickListList()
		@statusList.url = "/api/dataDict/"+@model.get('subclass')+" metadata/"+@model.get('subclass')+" status"
		@statusListController = new PickListSelectController
			el: @$('.bv_status')
			collection: @statusList
			selectedCode: @model.getStatus().get 'stringValue'

	setupTagList: ->
		@$('.bv_tags').val ""
		@tagListController = new TagListController
			el: @$('.bv_tags')
			collection: @model.get 'lsTags'
		@tagListController.render()


	handleRecordedByChanged: =>
		console.log "recordedBy changed"
		console.log @$('.bv_recordedBy').val()
		@model.set recordedBy: @$('.bv_recordedBy').val()
		console.log @model.get('recordedBy')
		@handleNameChanged()

	handleShortDescriptionChanged: =>
		trimmedDesc = UtilityFunctions::getTrimmedInput @$('.bv_shortDescription')
		if trimmedDesc != ""
			@model.set shortDescription: trimmedDesc
		else
			@model.set shortDescription: " " #fix for oracle persistance bug

	handleDescriptionChanged: =>
		@model.getDescription().set
			clobValue: UtilityFunctions::getTrimmedInput @$('.bv_description')
			recordedBy: @model.get('recordedBy')

	handleCommentsChanged: =>
		@model.getComments().set
			clobValue: UtilityFunctions::getTrimmedInput @$('.bv_comments')
			recordedBy: @model.get('recordedBy')

	handleNameChanged: =>
		subclass = @model.get('subclass')
		newName = UtilityFunctions::getTrimmedInput @$('.bv_'+subclass+'Name')
		@model.get('lsLabels').setBestName new Label
			lsKind: subclass+" name"
			labelText: newName
			recordedBy: @model.get('recordedBy')
		#TODO label change propagation isn't really working, so this is the work-around
		console.log @model.get('recordedBy')
		@model.trigger 'change'

	handleDateChanged: =>
		@model.getCompletionDate().set dateValue: UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate'))
		@model.trigger 'change'


	handleCompletionDateIconClicked: =>
		@$( ".bv_completionDate" ).datepicker( "show" )

	handleNotebookChanged: =>
		@model.getNotebook().set stringValue: UtilityFunctions::getTrimmedInput @$('.bv_notebook')
		@model.trigger 'change'

	handleStatusChanged: =>
		@model.getStatus().set stringValue: @statusListController.getSelectedCode()
		# this is required in addition to model change event watcher only for spec. real app works without it
		@updateEditable()



	updateEditable: =>
		if @model.isEditable()
			@enableAllInputs()
			@$('.bv_lock').hide()
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
		@$('.bv_saving').show()
		@model.save()

	validationError: =>
		super()
		@$('.bv_save').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_save').removeAttr('disabled')
