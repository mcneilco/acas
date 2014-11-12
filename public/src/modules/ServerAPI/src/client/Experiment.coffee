class window.Experiment extends BaseEntity
	urlRoot: "/api/experiments"
	defaults: ->
		_(super()).extend(
			protocol: null
			analysisGroups: new AnalysisGroupList()
		)

	initialize: ->
		@.set subclass: "experiment"
		super()

	parse: (resp) =>
		if resp is "not unique experiment name"
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
			if resp.analysisGroups?
				if resp.analysisGroups not instanceof AnalysisGroupList
					resp.analysisGroups = new AnalysisGroupList(resp.analysisGroups)
				resp.analysisGroups.on 'change', =>
					@trigger 'change'
			if resp.protocol?
				if resp.protocol not instanceof Protocol
					resp.protocol = new Protocol(resp.protocol)
			if resp.lsTags not instanceof TagList
				resp.lsTags = new TagList(resp.lsTags)
			resp.lsTags.on 'change', =>
				@trigger 'change'
			resp

	copyProtocolAttributes: (protocol) ->
		#cache values I don't want to overwrite
		notebook = @getNotebook().get('stringValue')
		completionDate = @getCompletionDate().get('dateValue')
		project = @getProjectCode().get('codeValue')
		estates = new StateList()
		pstates = protocol.get('lsStates')
		pstates.each (st) ->
			if st.get('lsKind') is "analysis parameters"
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
			lsKind: protocol.get('lsKind')
			protocol: protocol
			shortDescription: protocol.get('shortDescription')
			lsStates: estates
		@getNotebook().set stringValue: notebook
		@getCompletionDate().set dateValue: completionDate
		@getProjectCode().set codeValue: project
		@getComments().set clobValue: protocol.getComments().get('clobValue')
		@getDescription().set clobValue: protocol.getDescription().get('clobValue')
		#TODO: after merging DNETRPLC-63 branch (with attach files to protocols/experiments feature and with getDetails instead of getDescription), need to uncomment code below and delete the code above:
		#@getDetails().set clobValue: protocol.getDetails().get('clobValue')
#		@setupCompositeChangeTriggers()
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
		if cDate is undefined or cDate is "" or cDate is null then cDate = "fred"
		if isNaN(cDate)
			errors.push
				attribute: 'completionDate'
				message: "Assay completion date must be set"

		if errors.length > 0
			return errors
		else
			return null

	getProjectCode: ->
		projectCodeValue = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "project"
		if projectCodeValue.get('codeValue') is undefined or projectCodeValue.get('codeValue') is ""
			projectCodeValue.set codeValue: "unassigned"
			projectCodeValue.set codeType: "project"
			projectCodeValue.set codeKind: "project"
			projectCodeValue.set codeOrigin: "acas ddict"

		projectCodeValue

	getAnalysisStatus: ->
		metadataKind = @.get('subclass') + " metadata"
		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "stringValue", "analysis status"
		#		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "analysis status"
		if status.get('stringValue') is undefined or status.get('stringValue') is ""
			status.set stringValue: "created"

		status


class window.ExperimentList extends Backbone.Collection
	model: Experiment

class window.ExperimentBaseController extends BaseEntityController
	template: _.template($("#ExperimentBaseView").html())
	moduleLaunchName: "experiment_base"

	events: ->
		_(super()).extend(
			"change .bv_experimentName": "handleNameChanged"
			"click .bv_useProtocolParameters": "handleUseProtocolParametersClicked"
			"change .bv_protocolCode": "handleProtocolCodeChanged"
			"change .bv_projectCode": "handleProjectCodeChanged"
		)

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
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
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
#								expt = new Experiment json
								lsKind = json[0].lsKind #doesn't work for specRunner mode. In stubs mode, doesn't return array but for non-stubsMode,this works for now - see todo above
								if lsKind is "default"
									expt = new Experiment json[0]
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

	completeInitialization: ->
		unless @model?
			@model = new Experiment()
		@errorOwnerName = 'ExperimentBaseController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@model.on 'saveFailed', =>
#			@$('.bv_exptLink').attr("href", "/api/experiments/experimentName/"+@model.get('lsLabels').pickBestName().get('labelText'))
			#TODO: redirect user to experiment browser with a list of experiments with same name
			@$('.bv_experimentSaveFailed').modal('show')
			@$('.bv_saveFailed').show()
			@$('.bv_experimentSaveFailed').on 'hide.bs.modal', =>
				@$('.bv_saveFailed').hide()
		@model.on 'sync', =>
			@$('.bv_saving').hide()
			@$('.bv_save').attr('disabled', 'disabled')
			if @$('.bv_saveFailed').is(":visible")
				@$('.bv_updateComplete').hide()
				@trigger 'amDirty'
			else
				@$('.bv_updateComplete').show()
				@trigger 'amClean'
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
			@$('.bv_updateComplete').hide()
		@$('.bv_save').attr('disabled', 'disabled')
		@setupStatusSelect()
		@setupTagList()
		@model.getStatus().on 'change', @updateEditable
		@setupProtocolSelect(@options.protocolFilter, @options.protocolKindFilter)
		@setupProjectSelect()
		@render()


	render: =>
		unless @model?
			@model = new Experiment()
		if @model.get('protocol') != null
			@$('.bv_protocolCode').val(@model.get('protocol').get('codeName'))
		@$('.bv_projectCode').val(@model.getProjectCode().get('codeValue'))
		@setUseProtocolParametersDisabledState()
		super()
		@

	setupProtocolSelect: (protocolFilter, protocolKindFilter) ->
		if @model.get('protocol') != null
			protocolCode = @model.get('protocol').get('codeName')
		else
			protocolCode = "unassigned"
		@protocolList = new PickListList()
		if protocolFilter?
			@protocolList.url = "/api/protocolCodes/"+protocolFilter
		else if protocolKindFilter?
			@protocolList.url = "/api/protocolCodes/"+protocolKindFilter
		else
			@protocolList.url = "/api/protocolCodes/?protocolKind=default"

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

	setupStatusSelect: ->
		@statusList = new PickListList()
		@statusList.url = "/api/dataDict/experiment metadata/experiment status"
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

	setUseProtocolParametersDisabledState: ->
		if (not @model.isNew()) or (@model.get('protocol') == null) or (@protocolListController.getSelectedCode() == "")
			@$('.bv_useProtocolParameters').attr("disabled", "disabled")
		else
			@$('.bv_useProtocolParameters').removeAttr("disabled")

	getFullProtocol: ->
		if @model.get('protocol') != null
			if @model.get('protocol').isStub()
				@model.get('protocol').fetch success: =>
					newProtName = @model.get('protocol').get('lsLabels').pickBestLabel().get('labelText')
					@setUseProtocolParametersDisabledState()
					unless !@model.isNew()
						@handleUseProtocolParametersClicked()
			else
				@setUseProtocolParametersDisabledState()
				unless !@model.isNew()
					@handleUseProtocolParametersClicked()

	handleProtocolCodeChanged: =>
		code = @protocolListController.getSelectedCode()
		if code == "" || code == "unassigned"
			@model.set 'protocol': null
			#@getFullProtocol()
			@setUseProtocolParametersDisabledState()
		else
			$.ajax
				type: 'GET'
				url: "/api/protocols/codename/"+code
				success: (json) =>
					if json.length == 0
						alert("Could not find selected protocol in database, please get help")
					else
						@model.set protocol: new Protocol(json[0])
						@getFullProtocol() # this will fetch full protocol
				error: (err) ->
					alert 'got ajax error from api/protocols/codename/ in Exeriment.coffee'
				dataType: 'json'

	handleProjectCodeChanged: =>
		@model.getProjectCode().set codeValue: @projectListController.getSelectedCode()
		@model.trigger 'change'

	handleUseProtocolParametersClicked: =>
		@model.copyProtocolAttributes(@model.get('protocol'))
		@render()

	updateEditable: =>
		super()
		if @model.isNew()
			@$('.bv_protocolCode').removeAttr("disabled")
		else
			@$('.bv_protocolCode').attr("disabled", "disabled")

#	displayInReadOnlyMode: =>
#		@$(".bv_save").addClass "hide"
#		@disableAllInputs()
