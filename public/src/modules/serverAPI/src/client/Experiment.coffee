class window.Experiment extends Backbone.Model
	urlRoot: "/api/experiments"
	defaults:
		lsType: "default"
		lsKind: "default"
		recordedBy: ""
		recordedDate: new Date().getTime()
		shortDescription: ""
		lsLabels: new LabelList()
		lsStates: new StateList()
		protocol: null
		analysisGroups: new AnalysisGroupList()

	initialize: ->
		@fixCompositeClasses()
		@setupCompositeChangeTriggers()

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
		if resp.analysisGroups?
			if resp.analysisGroups not instanceof AnalysisGroupList
				resp.analysisGroups = new AnalysisGroupList(resp.analysisGroups)
		if resp.protocol?
			if resp.protocol not instanceof Protocol
				resp.protocol = new Protocol(resp.protocol)
		if resp.lsTags not instanceof TagList
			resp.lsTags = new TagList(resp.lsTags)
			resp.lsTags.on 'change', =>
				@trigger 'change'
		resp

	fixCompositeClasses: =>
		if @has('lsLabels')
			if @get('lsLabels') not instanceof LabelList
				@set lsLabels: new LabelList(@get('lsLabels'))
		if @has('lsStates')
			if @get('lsStates') not instanceof StateList
				@set lsStates: new StateList(@get('lsStates'))
		if @has('analysisGroups')
			if @get('analysisGroups') not instanceof AnalysisGroupList
				@set analysisGroups: new AnalysisGroupList(@get('analysisGroups'))
		if @get('protocol') != null
			if @get('protocol') not instanceof Backbone.Model
				@set protocol: new Protocol(@get('protocol'))
		if @get('lsTags') != null
			if @get('lsTags') not instanceof TagList
				@set lsTags: new TagList(@get('lsTags'))

	setupCompositeChangeTriggers: ->
		@get('lsLabels').on 'change', =>
			@trigger 'change'
		@get('lsStates').on 'change', =>
			@trigger 'change'
		@get('lsTags').on 'change', =>
			@trigger 'change'

	copyProtocolAttributes: (protocol) ->
		#cache values I don't want to overwrite
		notebook = @getNotebook().get('stringValue')
		completionDate = @getCompletionDate().get('dateValue')
		project = @getProjectCode().get('codeValue')

		estates = new StateList()
		pstates = protocol.get('lsStates')
		pstates.each (st) ->
			estate = new State(_.clone(st.attributes))
			estate.unset 'id'
			estate.unset 'lsTransaction'
			estate.unset 'lsValues'
			evals = new ValueList()
			svals = st.get('lsValues')
			svals.each (sv) ->
				unless sv.get('lsKind')=="notebook" || sv.get('lsKind')=="project" || sv.get('lsKind')=="completion date"
					evalue = new Value(sv.attributes)
					evalue.unset 'id'
					evalue.unset 'lsTransaction'
					evals.add(evalue)
			estate.set lsValues: evals
			estates.add(estate)
		@set
			kind: protocol.get('lsKind')
			protocol: protocol
			shortDescription: protocol.get('shortDescription')
			lsStates: estates
		@getNotebook().set stringValue: notebook
		@getCompletionDate().set dateValue: completionDate
		@getProjectCode().set codeValue: project
		@setupCompositeChangeTriggers()
		@trigger 'change'
		@trigger "protocol_attributes_copied"
		return

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
				attribute: 'experimentName'
				message: "Experiment name must be set"
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: "Experiment date must be set"
		if attrs.recordedBy is ""
			errors.push
				attribute: 'recordedBy'
				message: "Scientist must be set"
		if attrs.protocol == null
			errors.push
				attribute: 'protocolCode'
				message: "Protocol must be set"
		notebook = @getNotebook().get('stringValue')
		if notebook is "" or notebook is "unassigned" or notebook is undefined
			errors.push
				attribute: 'notebook'
				message: "Notebook must be set"
		projectCode = @getProjectCode().get('codeValue')
		if projectCode is "" or projectCode is "unassigned" or projectCode is undefined
			errors.push
				attribute: 'projectCode'
				message: "Project must be set"
		cDate = @getCompletionDate().get('dateValue')
		if cDate is undefined or cDate is "" then cDate = "fred"
		if isNaN(cDate)
			errors.push
				attribute: 'completionDate'
				message: "Assay completion date must be set"

		if errors.length > 0
			return errors

		if errors.length > 0
			return errors
		else
			return null

	getDescription: ->
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "description"

	getNotebook: ->
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "notebook"

	getProjectCode: ->
		projectCodeValue = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "project"
		if projectCodeValue.get('codeValue') is undefined or projectCodeValue.get('codeValue') is ""
			projectCodeValue.set codeValue: "unassigned"

		projectCodeValue

	getCompletionDate: ->
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "dateValue", "completion date"

	getStatus: ->
		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "status"
		if status.get('stringValue') is undefined or status.get('stringValue') is ""
			status.set stringValue: "New"

		status

	isEditable: ->
		status = @getStatus().get 'stringValue'
		switch status
			when "New" then return true
			when "Started" then return true
			when "Complete" then return true
			when "Finalized" then return false
			when "Rejected" then return false
		return true

class window.ExperimentList extends Backbone.Collection
	model: Experiment

class window.ExperimentBaseController extends AbstractFormController
	template: _.template($("#ExperimentBaseView").html())

	events:
		"change .bv_recordedBy": "handleRecordedByChanged"
		"change .bv_shortDescription": "handleShortDescriptionChanged"
		"change .bv_description": "handleDescriptionChanged"
		"change .bv_experimentName": "handleNameChanged"
		"change .bv_completionDate": "handleDateChanged"
		"click .bv_useProtocolParameters": "handleUseProtocolParametersClicked"
		"change .bv_protocolCode": "handleProtocolCodeChanged"
		"change .bv_projectCode": "handleProjectCodeChanged"
		"change .bv_notebook": "handleNotebookChanged"
		"change .bv_status": "handleStatusChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"click .bv_save": "handleSaveClicked"

	initialize: ->
		@model.on 'sync', =>
			@trigger 'amClean'
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
		@errorOwnerName = 'ExperimentBaseController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_save').attr('disabled', 'disabled')
		@setupProtocolSelect()
		@setupProjectSelect()
		@setupTagList()
		@model.getStatus().on 'change', @updateEditable

	render: =>
		if @model.get('protocol') != null
			@$('.bv_protocolCode').val(@model.get('protocol').get('codeName'))
		@$('.bv_projectCode').val(@model.getProjectCode().get('codeValue'))
		@$('.bv_shortDescription').html @model.get('shortDescription')
		@$('.bv_description').html @model.get('description')
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_experimentName').val bestName.get('labelText')
		@$('.bv_recordedBy').val(@model.get('recordedBy'))
		@$('.bv_experimentCode').html(@model.get('codeName'))
		@getAndShowProtocolName()
		@setUseProtocolParametersDisabledState()
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.getCompletionDate().get('dateValue')?
			date = new Date(@model.getCompletionDate().get('dateValue'))
			@$('.bv_completionDate').val(date.getFullYear()+'-'+date.getMonth()+'-'+date.getDate())
		@$('.bv_description').html(@model.getDescription().get('stringValue'))
		@$('.bv_notebook').val @model.getNotebook().get('stringValue')
		@$('.bv_status').val(@model.getStatus().get('stringValue'))
		if @model.isNew()
			@$('.bv_save').html("Save")
		else
			@$('.bv_save').html("Update")
		@updateEditable()

		@


	setupProtocolSelect: ->
		if @model.get('protocol') != null
			protocolCode = @model.get('protocol').get('codeName')
		else
			protocolCode = "unassigned"
		@protocolList = new PickListList()
		@protocolList.url = "/api/protocolCodes/filter/FLIPR"
		@protocolListController = new PickListSelectController
			el: @$('.bv_protocolCode')
			collection: @protocolList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Protocol"
			selectedCode: protocolCode

	setupProjectSelect: ->
		@projectList = new PickListList()
		@projectList.url = "/api/projects"
		@projectListController = new PickListSelectController
			el: @$('.bv_projectCode')
			collection: @projectList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Project"
			selectedCode: @model.getProjectCode().get('codeValue')

	setupTagList: ->
		@$('.bv_tags').val ""
		@tagListController = new TagListController
			el: @$('.bv_tags')
			collection: @model.get 'lsTags'
		@tagListController.render()

	setUseProtocolParametersDisabledState: ->
		if (not @model.isNew()) or (@model.get('protocol') == null) or (@$('.bv_protocolCode').val() == "")
			@$('.bv_useProtocolParameters').attr("disabled", "disabled")
		else
			@$('.bv_useProtocolParameters').removeAttr("disabled")

	getAndShowProtocolName: ->
		if @model.get('protocol') != null
			if @model.get('protocol').isStub()
				@model.get('protocol').fetch success: =>
					newProtName = @model.get('protocol').get('lsLabels').pickBestLabel().get('labelText')
					@updateProtocolNameField(newProtName)
					@setUseProtocolParametersDisabledState()
			else
				@updateProtocolNameField(@model.get('protocol').get('lsLabels').pickBestLabel().get('labelText'))
				@setUseProtocolParametersDisabledState()
		else
			@updateProtocolNameField "no protocol selected yet"

	updateProtocolNameField: (protocolName) ->
		@$('.bv_protocolName').html(protocolName)

	handleRecordedByChanged: =>
		@model.set recordedBy: @$('.bv_recordedBy').val()
		@handleNameChanged()

	handleShortDescriptionChanged: =>
		@model.set shortDescription: @getTrimmedInput('.bv_shortDescription')

	handleDescriptionChanged: =>
		@model.getDescription().set
			stringValue: @getTrimmedInput('.bv_description')
			recordedBy: @model.get('recordedBy')

	handleNameChanged: =>
		newName = @getTrimmedInput('.bv_experimentName')
		@model.get('lsLabels').setBestName new Label
			labelKind: "experiment name"
			labelText: newName
			recordedBy: @model.get 'recordedBy'
			recordedDate: new Date().getTime()
		#TODO label change propagation isn't really working, so this is the work-around
		@model.trigger 'change'

	handleDateChanged: =>
		@model.getCompletionDate().set dateValue: @convertYMDDateToMs(@getTrimmedInput('.bv_completionDate'))

	handleCompletionDateIconClicked: =>
		$( ".bv_completionDate" ).datepicker( "show" );

	handleProtocolCodeChanged: =>
		code = @$('.bv_protocolCode').val()
		if code == "" || code == "unassigned"
			@model.set 'protocol': null
			@getAndShowProtocolName()
			@setUseProtocolParametersDisabledState()
		else
			$.ajax
				type: 'GET'
				url: "/api/protocols/codename/"+code
				success: (json) =>
					if json.length == 0
						@updateProtocolNameField("could not find selected protocol in database")
					else
						@model.set protocol: new Protocol(json[0])
						@getAndShowProtocolName() # this will fetch full protocol
				error: (err) ->
					alert 'got ajax error from api/protocols/codename/ in Exeriment.coffee'
				dataType: 'json'

	handleProjectCodeChanged: =>
		@model.getProjectCode().set codeValue: @$('.bv_projectCode').val()

	handleNotebookChanged: =>
		@model.getNotebook().set stringValue: @getTrimmedInput('.bv_notebook')

	handleUseProtocolParametersClicked: =>
		@model.copyProtocolAttributes(@model.get('protocol'))
		@render()

	handleStatusChanged: =>
		@model.getStatus().set stringValue: @getTrimmedInput('.bv_status')
		# this is required in addtion to model change event watcher only for spec. real app works without it
		@updateEditable()

	updateEditable: =>
		if @model.isEditable()
			@enableAllInputs()
			@$('.bv_lock').hide()
		else
			@disableAllInputs()
			@$('.bv_status').removeAttr('disabled')
			@$('.bv_lock').show()

	handleSaveClicked: =>
		@model.save()

	validationError: =>
		super()
		@$('.bv_save').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_save').removeAttr('disabled')
