class DocForBatches extends Backbone.Model
	protocol: null
	experiment: null

	initialize: (options) ->
		@options = options
		if @has('json')
			js = @get('json')
			@set
				id: js.id
				docUpload: new DocUpload(js.docUpload)
				batchNameList: new BatchNameList(js.batchNameList)
		else if  @has('experiment')
			@updateDocForBatches()
		else
			@_fetchStubProtocol()
			if not @has('docUpload')
				@set
					docUpload: new DocUpload()
			if not @has('batchNameList')
				@set
					batchNameList: new BatchNameList()

	validate: (attrs) ->
		errors = []
		if  not attrs.docUpload.isValid()
			errors.push
				attribute: 'docUpload'
				message: "Document portion of form is not valid"

		if not attrs.batchNameList.isValid()
			errors.push
				attribute: 'batchNameList'
				message: "Batch list portion of form is not valid"

		if errors.length > 0
			return errors
		else
			return null

	_fetchStubProtocol: ->
		docForBatchesProtocolCode = "ACASdocForBatches"
		$.ajax
			type: 'GET'
			url: "api/protocols/codename/"+docForBatchesProtocolCode
			success: (json) =>
				if json.length == 0
					alert "Could not find required #{window.conf.protocol.label} with code: "+docForBatchesProtocolCode+". Please seek help from an administrator"
				else
					@.protocol = new Protocol(json)
			error: (err) ->
				alert 'got ajax error from api/protocols/codename/ in DocForBatches.coffee'
			dataType: 'json'

	asExperiment: ->
		if not @isValid()
			return null
		recBy = window.AppLaunchParams.loginUserName
		recDate = new Date().getTime()
		analysisGroup = new AnalysisGroup()
		analysisGroups = new AnalysisGroupList(analysisGroup)
		if @get('docUpload').get('docType') == "file"
			eName = @get('docUpload').get('currentFileName')
			stateValue_1 = new Value
				lsType: 'fileValue'
				lsKind: 'annotation'
				value: eName
				ignored: false
		else
			eName = @get('docUpload').get('url')
			stateValue_1 = new Value
				lsType: 'urlValue'
				lsKind: 'annotation'
				value: eName
				ignored: false
		stateValue_2 = new Value
			lsType: 'stringValue'
			lsKind: 'document kind'
			value: @get('docUpload').get('documentKind')
			ignored: false
		lsValues = new ValueList()
		lsValues.add(stateValue_1)
		lsValues.add(stateValue_2)
		#  _.each myArray, (elem) ->
		@get('batchNameList').each (batchName) ->
			stateValue = new Value
				lsType: 'codeValue'
				lsKind: 'batch code'
				comments: batchName.get('comment')
				value: batchName.get('preferredName')
				ignored: false
			lsValues.add(stateValue)

		analysisGroupState = new State
			lsValues:lsValues
			lsKind: 'Document for Batch'
			lsType: 'results'
			recordedBy: @.protocol.get('recordedBy')
		lsStates = new StateList()
		lsStates.add(analysisGroupState)
		analysisGroup = new AnalysisGroup
			lsStates : lsStates
		analysisGroups = new AnalysisGroupList(analysisGroup)
		exp = new Experiment
			protocol: @protocol
			kind: "ACAS doc for batches"
			recordedBy: recBy
			recordedDate: recDate
			shortDescription: @get('docUpload').get('description')
			analysisGroups:analysisGroups
		exp.get('lsLabels').setBestName new Label
			lsKind: "experiment name"
			labelText: eName
			recordedBy: recBy
			recordedDate: recDate
		exp

	updateDocForBatches: ->
		newDocUpload = new DocUpload
			id:1
		newBatchNameList= new BatchNameList()
		@get('experiment').get('analysisGroups').at(0).get('lsStates').each (analysisGroupState) ->
			analysisGroupState.get('lsValues').each (analysisGroupValue) ->
				lsType= analysisGroupValue.get('lsType')
				value = analysisGroupValue.get(lsType)
				switch lsType
					when "fileValue"
						if value!= null
							newDocUpload.set
								id: analysisGroupValue.get('id')
								currentFileName: value
								docType: "file"
					when "urlValue"
						if value!= null
							newDocUpload.set
								id: analysisGroupValue.get('id')
								url: value
								docType: "url"
					when "stringValue"
						if value!= null
							newDocUpload.set
								documentKind: value
					when "codeValue"
						if value!= null
							newBatchName= new BatchName
								id: analysisGroupValue.id
								preferredName: value
								comment: analysisGroupValue.get('comments')
							newBatchNameList.add(newBatchName)
		@set
			batchNameList : newBatchNameList
			docUpload : newDocUpload
		@



class DocForBatchesController extends Backbone.View
	template: _.template($("#DocForBatchesView").html())

	events:
		"click .bv_saveButton": "save"
		"click .bv_cancelButton": "resetForm"

	initialize: (options) ->
		@options = options
		$(@el).html @template()

		unless @model?
			@model = new DocForBatches()
		@setupSubControllers()

	setupSubControllers: ->
		@docUploadController = new DocUploadController
			model: @model.get('docUpload')
			el: @$('.bv_docUpload')
		@docUploadController.on("invalid", @subFormIsInvalid.bind(@))
		@docUploadController.on("valid", @subFormIsValid.bind(@))
		@docUploadController.on 'amDirty', =>
			@trigger 'amDirty'
		.bind(@)
		@batchListValidator = new BatchListValidatorController
			el: @$(".bv_batchListValidator")
			collection: @model.get('batchNameList')
		@batchListValidator.on("invalid", @subFormIsInvalid.bind(@))
		@batchListValidator.on("valid", @subFormIsValid.bind(@))
		@batchListValidator.on 'amDirty', =>
			@trigger 'amDirty'
		@subFormIsInvalid()

	render: =>
		@batchListValidator.render()
		@docUploadController.render()

		if @model.isNew()
			@$('.bv_title').html("New Document Annotations")
			@$(".bv_deleteButton").hide()
			@$(".bv_saveButton").html("Save")
		else
			@$('.bv_title').html("Edit Document Annotations")
			@$(".bv_deleteButton").show()
			@$(".bv_saveButton").html("Update")
		@

	subFormIsValid: =>
		@trigger 'amDirty'
		if @model.isValid()
			@$(".bv_saveButton").removeAttr 'disabled'

	subFormIsInvalid: =>
		@$(".bv_saveButton").attr 'disabled', 'disabled'

	save: =>
		if @model.isValid()
			$.ajax
				type: 'POST'
				url: "/api/docForBatches"
				data:
					docForBatches: JSON.stringify(@model)
					user: window.AppLaunchParams.loginUserName
				success: (response) =>
					@model.set
						id: response.results.id
					@trigger 'amClean'
					@render()
				error: (err) =>
					@serviceReturn = null
				dataType: 'json'

	resetForm: =>
		$(@el).empty()
		$(@el).html @template()
		@model = new DocForBatches()
		@setupSubControllers()
		@render()


