
class window.ExperimentValue extends Backbone.Model

class window.ExperimentValueList extends Backbone.Collection
	model: ExperimentValue

class window.ExperimentState extends Backbone.Model
	defaults:
		experimentValues: new ExperimentValueList()

	initialize: ->
		if @has('experimentValues')
			if @get('experimentValues') not instanceof ExperimentValueList
				@set experimentValues: new ExperimentValueList(@get('experimentValues'))
		@get('experimentValues').on 'change', =>
			@trigger 'change'

	parse: (resp) ->
		if resp.experimentValues?
			if resp.experimentValues not instanceof ExperimentValueList
				resp.experimentValues = new ExperimentValueList(resp.experimentValues)
				resp.experimentValues.on 'change', =>
					@trigger 'change'
		resp

	getValuesByTypeAndKind: (type, kind) ->
		@get('experimentValues').filter (value) ->
			(not value.get('ignored')) and (value.get('valueType')==type) and (value.get('valueKind')==kind)

class window.ExperimentStateList extends Backbone.Collection
	model: ExperimentState

	getStatesByTypeAndKind: (type, kind) ->
		@filter (state) ->
			(not state.get('ignored')) and (state.get('stateType')==type) and (state.get('stateKind')==kind)

	getStateValueByTypeAndKind: (stype, skind, vtype, vkind) ->
		value = null
		states = @getStatesByTypeAndKind stype, skind
		if states.length > 0
			#TODO get most recent state and value if more than 1 or throw error
			values = states[0].getValuesByTypeAndKind(vtype, vkind)
			if values.length > 0
				value = values[0]
		value



class window.Experiment extends Backbone.Model
	urlRoot: "/api/experiments"
	defaults:
		kind: ""
		recordedBy: ""
		recordedDate: null
		shortDescription: ""
		experimentLabels: new LabelList()
		experimentStates: new ExperimentStateList()
		protocol: null
		analysisGroups: new AnalysisGroupList()

	initialize: ->
		@fixCompositeClasses()
		@setupCompositeChangeTriggers()

	parse: (resp) =>
		if resp.experimentLabels?
			if resp.experimentLabels not instanceof LabelList
				resp.experimentLabels = new LabelList(resp.experimentLabels)
				resp.experimentLabels.on 'change', =>
					@trigger 'change'
		if resp.experimentStates?
			if resp.experimentStates not instanceof ExperimentStateList
				resp.experimentStates = new ExperimentStateList(resp.experimentStates)
				resp.experimentStates.on 'change', =>
					@trigger 'change'
		if resp.analysisGroups?
			if resp.analysisGroups not instanceof AnalysisGroupList
				resp.analysisGroups = new AnalysisGroupList(resp.analysisGroups)
		if resp.protocol?
			if resp.protocol not instanceof Protocol
				resp.protocol = new Protocol(resp.protocol)
		resp

	fixCompositeClasses: =>
		if @has('experimentLabels')
			if @get('experimentLabels') not instanceof LabelList
				@set experimentLabels: new LabelList(@get('experimentLabels'))
		if @has('experimentStates')
			if @get('experimentStates') not instanceof ExperimentStateList
				@set experimentStates: new ExperimentStateList(@get('experimentStates'))
		if @has('analysisGroups')
			if @get('analysisGroups') not instanceof AnalysisGroupList
				@set analysisGroups: new AnalysisGroupList(@get('analysisGroups'))
		if @get('protocol') != null
			if @get('protocol') not instanceof Backbone.Model
				@set protocol: new Protocol(@get('protocol'))

	setupCompositeChangeTriggers: ->
		@get('experimentLabels').on 'change', =>
			@trigger 'change'
		@get('experimentStates').on 'change', =>
			@trigger 'change'

	copyProtocolAttributes: (protocol) ->
		estates = new ExperimentStateList()
		pstates = protocol.get('protocolStates')
		pstates.each (st) ->
			estate = new ExperimentState(_.clone(st.attributes))
			estate.unset 'id'
			estate.unset 'lsTransaction'
			estate.unset 'protocolValues'
			evals = new ExperimentValueList()
			svals = st.get('protocolValues')
			svals.each (sv) ->
				evalue = new ProtocolValue(sv.attributes)
				evalue.unset 'id'
				evalue.unset 'lsTransaction'
				evals.add(evalue)
			estate.set experimentValues: evals
			estates.add(estate)
		@set
			kind: protocol.get('kind')
			protocol: protocol
			shortDescription: protocol.get('shortDescription')
			experimentStates: estates
		@trigger "protocol_attributes_copied"
		return

	validate: (attrs) ->
		errors = []
		bestName = attrs.experimentLabels.pickBestName()
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

#		if attrs.protocol = null
#			errors.push
#				attribute: 'protocol'
#				message: "Protocol must be set"

		if errors.length > 0
			return errors
		else
			return null

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

	render: =>
		$(@el).empty()
		$(@el).html @template()
		if @model.get('protocol') != null
			@$('.bv_protocolCode').val(@model.get('protocol').get('codeName'))
		@$('.bv_shortDescription').html @model.get('shortDescription')
		@$('.bv_description').html @model.get('description')
		bestName = @model.get('experimentLabels').pickBestName()
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
		@$('.bv_description').html(@getDescriptionValue())

		@

	setUseProtocolParametersDisabledState: ->
		if (not @model.isNew()) or (@model.get('protocol') == null) or (@$('.bv_protocolCode').val() == "")
			@$('.bv_useProtocolParameters').attr("disabled", "disabled")
		else
			@$('.bv_useProtocolParameters').removeAttr("disabled")

	getAndShowProtocolName: ->
		if @model.get('protocol') != null
			if @model.get('protocol').isStub()
				@model.get('protocol').fetch success: =>
					newProtName = @model.get('protocol').get('protocolLabels').pickBestLabel().get('labelText')
					@updateProtocolNameField(newProtName)
					@setUseProtocolParametersDisabledState()
			else
				@updateProtocolNameField(@model.get('protocol').get('protocolLabels').pickBestLabel().get('labelText'))
		else
			@updateProtocolNameField "no protocol selected yet"

	updateProtocolNameField: (protocolName) ->
		@$('.bv_protocolName').html(protocolName)

	getDescriptionValue: ->
		value = @model.get('experimentStates').getStateValueByTypeAndKind "metadata", "experiment info", "stringValue", "description"
		desc = ""
		if value != null
			desc = value.get('stringValue')
		desc

	handleRecordedByChanged: =>
		@model.set recordedBy: @$('.bv_recordedBy').val()
		@handleNameChanged()

	handleShortDescriptionChanged: =>
		@model.set shortDescription: @getTrimmedInput('.bv_shortDescription')

	handleDescriptionChanged: =>
		@model.set description:@getTrimmedInput('.bv_description')

	handleNameChanged: =>
		newName = @getTrimmedInput('.bv_experimentName')
		@model.get('experimentLabels').setBestName new Label
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
		if code == ""
			@model.set 'protocol': null
			@getAndShowProtocolName()
			@setUseProtocolParametersDisabledState()
		else
			$.ajax
				type: 'GET'
				url: "api/protocols/codename/"+code
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
