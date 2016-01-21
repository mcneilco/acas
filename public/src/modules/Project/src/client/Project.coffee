class window.Project extends Thing
	urlRoot: "/api/things/project/project"
	className: "Project"

	initialize: ->
		@.set
			lsType: "project"
			lsKind: "project"
		super()


	lsProperties:

		#TODO: save keywords
		defaultLabels: [
			key: 'project name'
			type: 'name'
			kind: 'project name'
			preferred: true
		,
			key: 'project alias'
			type: 'name'
			kind: 'project alias'
			preferred: false
		,
			key: 'live design id'
			type: 'id'
			kind: 'live design id'
			preferred: false
		]

		defaultValues: [
			key: 'start date'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'dateValue'
			kind: 'start date'
		,
			key: 'project status'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'codeValue'
			kind: 'project status'
			codeType: 'project'
			codeKind: 'status'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'short description'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'stringValue'
			kind: 'short description'
		,
			key: 'project details'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'clobValue'
			kind: 'project details'
		,
			key: 'live design id'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'numericValue'
			kind: 'live design id'
		]

		defaultFirstLsThingItx: [
		]

		defaultSecondLsThingItx: [
		]


	validate: (attrs) ->
		errors = []
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		if bestName?
			nameError = true
			if bestName.get('labelText') != "" and bestName.get('labelText') != "unassigned"
				nameError = false
		if nameError
			errors.push
				attribute: 'projectName'
				message: "Name must be set"
		if errors.length > 0
			return errors
		else
			return null

	prepareToSave: ->
		rBy = @get('recordedBy')
		rDate = new Date().getTime()
		@set recordedDate: rDate
		@get('lsLabels').each (lab) =>
			@setRByAndRDate lab
		@get('lsStates').each (state) =>
			@setRByAndRDate state
			state.get('lsValues').each (val) =>
				@setRByAndRDate val
		if @get('secondLsThings')?
			@get('secondLsThings').each (itx) =>
				@setRByAndRDate itx
				itx.get('lsStates').each (state) =>
					@setRByAndRDate state
					state.get('lsValues').each (val) =>
						@setRByAndRDate val

	setRByAndRDate: (data) ->
		rBy = @get('recordedBy')
		rDate = new Date().getTime()
		unless data.get('recordedBy') != ""
			data.set recordedBy: rBy
		unless data.get('recordedDate') != null
			data.set recordedDate: rDate

class window.ProjectController extends AbstractFormController
	template: _.template($("#ProjectView").html())
	moduleLaunchName: "project"

	events: ->
		"keyup .bv_projectCode": "handleProjectCodeNameChanged" #TODO: check to see if this has to be separate function
		"keyup .bv_projectName": "attributeChanged"
		"keyup .bv_projectAlias": "attributeChanged"
		"keyup .bv_startDate": "attributeChanged"
		"click .bv_startDateIcon": "handleStartDateIconClicked"
		"keyup .bv_shortDescription": "attributeChanged"
		"keyup .bv_projectDetails": "attributeChanged"
		#TODO: add project leader

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/things/project/project/codename/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) ->
							alert 'Could not get project for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get project for code in this URL, creating new one'
							else
								proj = new Project json
								proj.set proj.parse(proj.attributes)
								@model = proj
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model=new Project()
		@errorOwnerName = 'ProjectController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupProjectStatusSelect()
		#TODO: setup project leader and attach file section
		@render()

	render: =>
		unless @model?
			@model = new Project()
		#TODO: setup project leader and attach file section
		codeName = @model.get('codeName')
		@$('.bv_projectCode').val(codeName)
		@$('.bv_projectCode').html(codeName)
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_projectName').val bestName.get('labelText')
		@$('.bv_scientist').val @model.get('scientist').get('value')
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		compDate = @model.get('completion date').get('value')
		if compDate?
			unless isNaN(compDate)
				@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.get('completion date').get('value'))
		@$('.bv_notebook').val @model.get('notebook').get('value')
		if @readOnly is true
			@displayInReadOnlyMode()
		@$('.bv_saveThing').attr('disabled','disabled')
		if @model.isNew()
			@$('.bv_saveThing').html("Save")
		else
			@$('.bv_saveThing').html("Update")
		@

	setupStructuralFileController: =>
		structuralFileValue = @model.get('structural file').get('value')
		if structuralFileValue is null or structuralFileValue is "" or structuralFileValue is undefined
			@createNewFileChooser()
			@$('.bv_deleteSavedFile').hide()
		else
			@$('.bv_structuralFile').html '<div style="margin-top:5px;"><a href="'+window.conf.datafiles.downloadurl.prefix+structuralFileValue+'">'+@model.get('structural file').get('comments')+'</a></div>'
			@$('.bv_deleteSavedFile').show()

	createNewFileChooser: =>
		@structuralFileController = new LSFileChooserController
			el: @$('.bv_structuralFile')
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['sdf', 'mol']
			hideDelete: false
		@structuralFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@structuralFileController.on 'amClean', =>
			@trigger 'amClean'
		@structuralFileController.render()
		@structuralFileController.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@structuralFileController.on('fileDeleted', @handleFileRemoved) #update model with filename

	handleFileUpload: (nameOnServer) =>
		newFileValue = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "cationic block parent", "fileValue", "structural file"
		@model.set "structural file", newFileValue
		@model.get("structural file").set("value", nameOnServer)

	handleFileRemoved: =>
		@model.get("structural file").set("ignored", true)
		@model.unset "structural file"

	handleDeleteSavedStructuralFile: =>
		@handleFileRemoved()
		@$('.bv_deleteSavedFile').hide()
		@createNewFileChooser()

	handleNameChanged: =>
		super()
		@updateModel() #need to call update model at least once before saving parent or else date and notebook do not get set and the parent save does not trigger a sync event
#not sure why updateModel has to be called at least once

class window.CationicBlockController extends AbstractBaseComponentController
	moduleLaunchName: "cationic_block"

	completeInitialization: =>
		unless @model?
			@model = new Project()
		super()
		@$('.bv_registrationTitle').html("Cationic Block Parent/Batch Registration")

	setupParentController: =>
		@parentController = new ProjectController
			model: @model
			el: @$('.bv_parent')
			readOnly: @readOnly
		super()

	setupBatchSelectController: =>
		@batchSelectController = new CationicBlockBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
			batchCodeName: @batchCodeName
			batchModel: @batchModel
			readOnly: @readOnly
			lsKind: "cationic block"
		super()

