class window.ParentExperiment extends Experiment
	urlRoot: "/api/experiments/parentExperiment"

	initialize: ->
		@set
			lsType: "Parent"
			lsKind: "Parent Bio Activity"
		super()

	validate: (attrs) ->
		errors = []
		errors.push super(attrs)...
		#return error if experiment name is undefined
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		unless bestName?
			errors.push
				attribute: attrs.subclass+'Name'
				message: attrs.subclass+" name must be set"
		if errors.length > 0
			return errors
		else
			return null

class window.ChildExperiment extends PrimaryScreenExperiment

	validate: (attrs) ->
		errors = []
		#only validate child experiment if it is new
		unless attrs.id?
			errors.push super(attrs)...
			bestName = attrs.lsLabels.pickBestName()
			nameError = true
			if bestName?
				nameError = true
				if bestName.get('labelText') != ""
					nameError = false
			if nameError
				errors.push
					attribute: 'childExperimentName'
					message: "Child experiment name must be set"
		if errors.length > 0
			return errors
		else
			return null

class window.ChildExperimentList extends Backbone.Collection
	model: ChildExperiment

	validateCollection: =>
		modelErrors = []
		@each (model, index) ->
		# note: can't call model.isValid() because if invalid, the function will trigger validationError,
		# which adds the class "error" to the invalid attributes
			indivModelErrors = model.validate(model.attributes)
			if indivModelErrors?
				for error in indivModelErrors
					modelErrors.push
						attribute: error.attribute+':eq('+index+')'
						message: error.message
		return modelErrors

class window.ChildExperimentController extends AbstractFormController
	template: _.template($("#ChildExperimentView").html())

	events: ->
		"keyup .bv_childExperimentName": "attributeChanged"

	initialize: ->
		@errorOwnerName = 'ChildExperimentController'
		@setBindings()

	render: =>
		$(@el).empty()
		$(@el).html @template()
		protName = @model.get('protocol').get('lsLabels').pickBestName()
		if protName?
			@$('.bv_childExperimentNameLabel').html @model.get('protocol').get('codeName')+": Experiment Name"
			@$('.bv_childExperimentCodeLabel').html @model.get('protocol').get('codeName')+": Experiment Code"
		if @model.isNew()
			@$('.bv_childExperimentCode').show()
			@$('.bv_childExperimentCodeLink').hide()
		else
			@$('.bv_childExperimentCode').hide()
			@$('.bv_childExperimentCodeLink').show()
			@$('.bv_childExperimentCodeLink').attr "href", "/entity/edit/codeName/#{@model.get('codeName')}"
			@$('.bv_childExperimentCodeLink').html @model.get('codeName')
			childExptName = @model.get('lsLabels').pickBestName()
			@$('.bv_childExperimentName').val childExptName.get('labelText')
			@$('.bv_childExperimentName').attr 'disabled', 'disabled'
		@

	updateModel: =>
		newName = UtilityFunctions::getTrimmedInput @$('.bv_childExperimentName')
		@model.get('lsLabels').setBestName new Label
			lsKind: "experiment name"
			labelText: newName
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		@model.trigger 'change'

class window.ChildExperimentsListController extends Backbone.View
	template: _.template($("#ChildExperimentListView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (childExpt) =>
			@addOneChildExperiment(childExpt)
		@

	addOneChildExperiment: (childExpt) ->
		controller = new ChildExperimentController
			model: childExpt
		@$('.bv_childExperimentInfo').append controller.render().el

	isValid: ->
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

class window.ParentExperimentMetadataController extends ExperimentBaseController
	template: _.template($("#ParentExperimentMetadataView").html())

	completeInitialization: ->
		unless @model?
			@model = new ParentExperiment()
		@errorOwnerName = 'ParentExperimentMetadataController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@model.on 'notUniqueName', =>
#			@$('.bv_exptLink').attr("href", "/api/experiments/experimentName/"+@model.get('lsLabels').pickBestName().get('labelText'))
#TODO: redirect user to experiment browser with a list of experiments with same name
			@$('.bv_experimentSaveFailed').modal('show')
			@$('.bv_closeSaveFailedModal').removeAttr('disabled')
			@$('.bv_saveFailed').show()
			@$('.bv_experimentSaveFailed').on 'hide.bs.modal', =>
				@$('.bv_saveFailed').hide()
		@model.on 'saveFailed', =>
			@$('.bv_saveFailed').show()
		@setupStatusSelect()
		@setupScientistSelect()
		@setupTagList()
		@setupProtocolSelect(@options.protocolFilter, @options.protocolKindFilter)
		@setupProjectSelect()
		@setupAttachFileListController()
		@setupCustomExperimentMetadataController()
		unless @model.isNew()
			@setupSavedChildExperiments()
		@render()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback
		@model.getStatus().on 'change', @updateEditable

	render: =>
		super()
		if @model.isNew()
			@$('.bv_experimentName').removeAttr 'disabled'
		@updateEditable()
		@

	modelSyncCallback: =>
		super()
		@setupSavedChildExperiments()

	setupSavedChildExperiments: =>
		$.ajax
			type: 'POST'
			url: "/api/getExptExptItxsToDisplay/"+@model.get('id')
			success: (json) =>
				childExperiments = _.pluck json, 'secondExperiment'
				@childExperiments = new ChildExperimentList childExperiments
				@setupChildExperimentsListController()
			error: (err) =>
				alert 'got ajax error from getting protocol '+ code
			dataType: 'json'


	getAndSetProtocol: (code, setAnalysisParams) ->
		if code == "" || code == "unassigned"
			@model.set 'protocol': null
			#@getFullProtocol()
			@setUseProtocolParametersDisabledState()
		else
			@$('.bv_protocolCode').attr('disabled','disabled')
			@$('.bv_spinner').spin('aligned')
			$.ajax
				type: 'GET'
				url: "/api/protocols/parentProtocol/codename/"+code+"?childProtocols=fullObject"
				success: (json) =>
					@$('.bv_spinner').spin(false)
					@$('.bv_protocolCode').removeAttr('disabled')
					if json.length == 0
						alert("Could not find selected protocol in database")
					else
						if json.childProtocols?
							@setupNewChildExperiments(json.childProtocols)
							delete json.childProtocols
						@model.set protocol: new Protocol(json)
						if setAnalysisParams
							@getFullProtocol() # this will fetch full protocol
				error: (err) ->
					alert 'got ajax error from getting protocol '+ code
				dataType: 'json'

	setupNewChildExperiments: (childProtocols) =>
		@childExperiments = new ChildExperimentList()
		project = @model.getProjectCode().get('codeValue')
		scientist = @model.getScientist().get('codeValue')
		date = @model.getCompletionDate().get('dateValue')
		notebook = @model.getNotebook().get('stringValue')

		_.each childProtocols, (protItx) =>
			prot = new PrimaryScreenProtocol protItx.secondProtocol
			newChildExpt = new ChildExperiment
				protocol: prot
			newChildExpt.getProjectCode().set 'codeValue', project
			newChildExpt.getScientist().set 'codeValue', scientist
			newChildExpt.getCompletionDate().set 'dateValue', date
			newChildExpt.getNotebook().set 'stringValue', notebook

			ap = newChildExpt.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
			ap.set 'clobValue', JSON.stringify prot.getAnalysisParameters()
			mfp = newChildExpt.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters"
			mfp.set 'clobValue', JSON.stringify prot.getModelFitParameters()
			@childExperiments.add newChildExpt
		@setupChildExperimentsListController()

	setupChildExperimentsListController: ->
		if @childExperimentsListController?
			@childExperimentsListController.undelegateEvents()
		@childExperimentsListController = new ChildExperimentsListController
			collection: @childExperiments
			el: @$('.bv_childExperimentsInfo')
		@childExperimentsListController.render()

	setupAttachFileListController: =>
		$.ajax
			type: 'GET'
			url: "/api/codetables/parent experiment metadata/file type"
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of file types'
			success: (json) =>
				if json.length == 0
					alert 'Got empty list of file types'
				else
					attachFileList = @model.getAttachedFiles(json)
					@finishSetupAttachFileListController(attachFileList,json)

	finishSetupAttachFileListController: (attachFileList, fileTypeList) ->
		if @attachFileListController?
			@attachFileListController.undelegateEvents()
		@attachFileListController= new ExperimentAttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
			firstOptionName: "Select Method"
			allowedFileTypes: ['zip']
			fileTypeList: fileTypeList
			required: true
		@attachFileListController.on 'amClean', =>
			@trigger 'amClean'
		@attachFileListController.on 'renderComplete', =>
			@checkDisplayMode()
		@attachFileListController.render()
		@attachFileListController.on 'amDirty', =>
			@trigger 'amDirty' #need to put this after the first time @attachFileListController is rendered or else the module will always start off dirty
			@model.trigger 'change'
		@attachFileListController.$('.bv_addFileInfo').hide()
		if @model.isNew()
			@attachFileListController.$('.bv_delete').show()
			@attachFileListController.$('.bv_fileType').removeAttr 'disabled'
		else
			@attachFileListController.$('.bv_delete').hide()
			@attachFileListController.$('.bv_fileType').attr 'disabled', 'disabled'


	handleProjectCodeChanged: =>
		super()
		project = @projectListController.getSelectedCode()
		@updateChildExptAttr('ProjectCode', project)

	handleScientistChanged: =>
		super()
		scientist = @scientistListController.getSelectedCode()
		@updateChildExptAttr('Scientist', scientist)

	handleDateChanged: =>
		super()
		date = UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate'))
		@updateChildExptAttr "CompletionDate", date

	handleNotebookChanged: =>
		super()
		notebook = UtilityFunctions::getTrimmedInput @$('.bv_notebook')
		@updateChildExptAttr('Notebook', notebook)

	updateChildExptAttr: (valKind, attrVal) ->
		if @childExperiments?
			@childExperiments.each (expt) =>
				currentVal = expt["get"+valKind]()
				unless currentVal.isNew()
					currentVal.set ignored: true
					currentVal = expt["get"+vKind]()
				currentVal.set currentVal.get('lsType'), attrVal

	updateEditable: =>
		if @model.isNew()
			@enableAllInputs()
		else
			@disableAllInputs()
			@$('.bv_projectCode').removeAttr 'disabled'
			@$('.bv_scientist').removeAttr 'disabled'
			@$('.bv_completionDate').removeAttr 'disabled'
			@$('.bv_notebook').removeAttr 'disabled'

	prepareToSaveAttachedFiles: =>
		@attachFileListController.collection.each (file) =>
			unless file.get('fileType') is "unassigned"
				@childExperiments.each (expt) =>
					@addFileToExpt expt, file
				@addFileToExpt @model, file
#				if file.get('id') is null
#					newFile = @model.get('lsStates').createValueByTypeAndKind "metadata", @model.get('subclass')+" metadata", "fileValue", file.get('fileType')
#					newFile.set fileValue: file.get('fileValue')
#				else
#					if file.get('ignored') is true
#						value = @model.get('lsStates').getValueById "metadata", @model.get('subclass')+" metadata", file.get('id')
#						value[0].set "ignored", true

	addFileToExpt: (expt, file) ->
		if file.get('id') is null
			newFile = expt.get('lsStates').createValueByTypeAndKind "metadata", "experiment metadata", "fileValue", file.get('fileType')
			newFile.set fileValue: file.get('fileValue')
		else
			if file.get('ignored') is true
				value = expt.get('lsStates').getValueById "metadata", @model.get('subclass')+" metadata", file.get('id')
				value[0].set "ignored", true

	saveEntity: =>
		@prepareToSaveAttachedFiles()
		@model.prepareToSave()
		@childExperiments.each (expt) =>
			expt.prepareToSave()
		if @model.isNew()
			@$('.bv_updateComplete').html "Save Complete"
		else
			@$('.bv_updateComplete').html "Update Complete"
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_saving').show()
		if @model.isNew()
			infoToSave =
				parentExperiment: JSON.stringify @model
				childExperiments: JSON.stringify @childExperiments
		else
			infoToSave = null
		@model.save(infoToSave)

	isValid: =>
		validCheck = super()
		if @childExperimentsListController?
			unless @childExperimentsListController.isValid() is true
				@$('.bv_save').attr 'disabled', 'disabled'
				validCheck = false
		if validCheck
			@$('.bv_save').removeAttr 'disabled'
		else
			@$('.bv_save').attr 'disabled', 'disabled'
		validCheck

class window.ParentExperimentModuleController extends Backbone.View
	template: _.template($("#ParentExperimentModuleView").html())
	moduleLaunchName: "parent_experiment"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					if window.AppLaunchParams.moduleLaunchParams.createFromOtherEntity
						@createExperimentFromProtocol(window.AppLaunchParams.moduleLaunchParams.code)
					else
						$.ajax
							type: 'GET'
							url: "/api/experiments/codename/"+window.AppLaunchParams.moduleLaunchParams.code
							dataType: 'json'
							error: (err) ->
								alert 'Could not get experiment for code in this URL, creating new one'
								@completeInitialization()
							success: (json) =>
								if json.length == 0
									alert 'Could not get experiment for code in this URL, creating new one'
								else
									lsKind = json.lsKind
									if lsKind is "Parent Bio Activity"
										expt = new ParentExperiment json
										expt.set expt.parse(expt.attributes)
										if window.AppLaunchParams.moduleLaunchParams.copy
											@model = expt.duplicateEntity()
										else
											@model = expt
									else
										alert 'Could not get experiment for code in this URL. Creating new experiment'
								@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	createExperimentFromProtocol: (code) ->
		@model = new ParentExperiment()
		@model.set protocol: new ParentProtocol
			codeName: code
		@completeInitialization()
		@experimentMetadataController.getAndSetProtocol(code, true)

	completeInitialization: =>
		@errorOwnerName = 'ParentExperimentModuleController'
		unless @model?
			@model = new ParentExperiment()
		$(@el).empty()
		$(@el).html @template()
		@setupExperimentMetadataController()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'error', @modelErrorCallback
		@listenTo @model, 'change', @modelChangeCallback
		@render()

	render: =>
		unless @model?
			@model = new ParentExperiment()
#		@setupChildProtocols()
		super()
		@

	setupExperimentMetadataController: ->
		if @experimentMetadataController?
			@experimentMetadataController.remove()
		@experimentMetadataController = new ParentExperimentMetadataController
			model: @model
			el: @$('.bv_experimentMetadata')
			protocolKindFilter: "?protocolKind=Parent Bio Activity"
		@experimentMetadataController.on 'amDirty', =>
			@trigger 'amDirty'
		@experimentMetadataController.on 'amClean', =>
			@trigger 'amClean'
		@experimentMetadataController.render()

