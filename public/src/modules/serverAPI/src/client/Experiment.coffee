class window.Experiment extends Backbone.Model
	urlRoot: "/api/experiments"
	defaults:
		lsType: "default"
		lsKind: "default"
		recordedBy: ""
		recordedDate: null
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

	setupCompositeChangeTriggers: ->
		@get('lsLabels').on 'change', =>
			@trigger 'change'
		@get('lsStates').on 'change', =>
			@trigger 'change'

	copyProtocolAttributes: (protocol) ->
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
				unless sv.get('lsKind')=="notebook" || sv.get('lsKind')=="project"
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
		@trigger "protocol_attributes_copied"
		return

	validate: (attrs) ->
		errors = []
		bestName = attrs.lsLabels.pickBestName()
		nameError = false
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
				attribute: 'protocol'
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

	getControlStates: ->
		@.get('lsStates').getStatesByTypeAndKind "metadata", "experiment controls"

	getControlType: (type) ->
		controls = @getControlStates()
		matched = controls.filter (cont) ->
			vals = cont.getValuesByTypeAndKind "stringValue", "control type"
			vals[0].get('stringValue') == type

		matched


class window.ExperimentList extends Backbone.Collection
	model: Experiment

class window.ExperimentBaseController extends AbstractFormController
	template: _.template($("#ExperimentBaseView").html())

	events:
		"change .bv_recordedBy": "handleRecordedByChanged"
		"change .bv_shortDescription": "handleShortDescriptionChanged"
		"change .bv_description": "handleDescriptionChanged"
		"change .bv_experimentName": "handleNameChanged"
		"change .bv_recordedDate": "handleDateChanged"
		"click .bv_useProtocolParameters": "handleUseProtocolParametersClicked"
		"change .bv_protocolCode": "handleProtocolCodeChanged"
		"click .bv_recordDateIcon": "handleRecordDateIconClicked"

	initialize: ->
		@model.on 'sync', @render
		@errorOwnerName = 'ExperimentBaseController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template()
		@setupProtocolSelect()
		@setupProjectSelect()

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
		@$('.bv_recordedDate').datepicker( );
		@$('.bv_recordedDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.get('recordedDate') != null
			date = new Date(@model.get('recordedDate'))
			@$('.bv_recordedDate').val(date.getFullYear()+'-'+date.getMonth()+'-'+date.getDate())
		@$('.bv_description').html(@model.getDescription().get('stringValue'))
		@$('.bv_notebook').val @model.getNotebook().get('stringValue')

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
			stringValue: $.trim(@$('.bv_description').val())
			recordedBy: @model.get('recordedBy')

	handleNameChanged: =>
		newName = @getTrimmedInput('.bv_experimentName')
		@model.get('lsLabels').setBestName new Label
			labelKind: "experiment name"
			labelText: newName
			recordedBy: @model.get 'recordedBy'
			recordedDate: @model.get 'recordedDate'

	handleDateChanged: =>
		@model.set recordedDate: @convertYMDDateToMs(@getTrimmedInput('.bv_recordedDate'))
		@handleNameChanged()

	handleRecordDateIconClicked: =>
		$( ".bv_recordedDate" ).datepicker( "show" );

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

	handleUseProtocolParametersClicked: =>
		@model.copyProtocolAttributes(@model.get('protocol'))
		@render()
