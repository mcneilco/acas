class window.DocForBatches extends Backbone.Model
	protocol: null
	experiment: null

	initialize: ->
		if @has('json')
			js = @get('json')
			@set
				id: js.id
				docUpload: new DocUpload(js.docUpload)
				batchNameList: new BatchNameList(js.batchNameList)
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
					alert "Could not find required protocol with code: "+docForBatchesProtocolCode+". Please seek help from an administrator"
				else
					@.protocol = new Protocol(json[0])
			error: (err) ->
				console.log 'got ajax error'
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
			stateValue_1 = new AnalysisGroupValue
				valueType: 'fileValue'
				valueKind: 'annotation'
				value: eName
				ignored: false
		else
			eName = @get('docUpload').get('url')
			stateValue_1 = new AnalysisGroupValue
				valueType: 'urlValue'
				valueKind: 'annotation'
				value: eName
				ignored: false
		stateValue_2 = new AnalysisGroupValue
			valueType: 'stringValue'
			valueKind: 'document kind'
			value: @get('docUpload').get('documentKind')
			ignored: false
		stateValues = new AnalysisGroupValueList()
		stateValues.add(stateValue_1)
		stateValues.add(stateValue_2)
		#  _.each myArray, (elem) ->
		@get('batchNameList').each (batchName) ->
			stateValue = new AnalysisGroupValue
				valueType: 'codeValue'
				valueKind: 'batch code'
				comments: batchName.get('comment')
				value: batchName.get('preferredName')
				ignored: false
			stateValues.add(stateValue)

		analysisGroupState = new AnalysisGroupState
			analysisGroupValues:stateValues
			stateKind: 'Document for Batch'
			stateType: 'results'
			recordedBy: @.protocol.get('recordedBy')
		analysisGroupStates = new AnalysisGroupStateList()
		analysisGroupStates.add(analysisGroupState)
		analysisGroup = new AnalysisGroup
			analysisGroupStates : analysisGroupStates
		analysisGroups = new AnalysisGroupList(analysisGroup)
		exp = new Experiment
			protocol: @protocol
			kind: "ACAS doc for batches"
			recordedBy: recBy
			recordedDate: recDate
			shortDescription: @get('docUpload').get('description')
			analysisGroups:analysisGroups
		exp.get('experimentLabels').setBestName new Label
			labelKind: "experiment name"
			labelText: eName
			recordedBy: recBy
			recordedDate: recDate


		exp
	updateDocForBatches: ->
		newDocUpload = new DocUpload()
		newBatchNameList= new BatchNameList()
		console.log @get('experiment')
		@get('experiment').get('analysisGroups').at(0).get('analysisGroupStates').each (analysisGroupState) ->
			analysisGroupState.get('analysisGroupValues').each (analysisGroupValue) ->
				valueType= analysisGroupValue.get('valueType')
				console.log valueType
				switch valueType
					when "fileValue"
						if  analysisGroupValue.get('fileValue')!= null
							newDocUpload.set
								currentFileName: analysisGroupValue.get('fileValue')
					when "urlValue"
						if  analysisGroupValue.get('urlValue')!= null
							newDocUpload.set
								url: analysisGroupValue.get('urlValue')
					when "stringValue"
						if  analysisGroupValue.get('stringValue')!= null
							newDocUpload.set
								documentKind: analysisGroupValue.get('stringValue')
					when "codeValue"
						if  analysisGroupValue.get('codeValue')!= null
							newBatchName= new BatchName
								id: analysisGroupValue.id
								preferredName: analysisGroupValue.get('codeValue')
								comment: analysisGroupValue.get('comments')
							newBatchNameList.add(newBatchName)
		@set
			batchNameList: newBatchNameList
			docUpload: newDocUpload
		@



class window.DocForBatchesController extends Backbone.View
	template: _.template($("#DocForBatchesView").html())

	events:
		"click .bv_saveButton": "save"
		"click .bv_cancelButton": "resetForm"

	initialize: ->
		$(@el).html @template()

		unless @model?
			@model = new DocForBatches()
		@setupSubControllers()

	setupSubControllers: ->
		@docUploadController = new DocUploadController
			model: @model.get('docUpload')
			el: @$('.bv_docUpload')
		@docUploadController.on("invalid", @subFormIsInvalid)
		@docUploadController.on("valid", @subFormIsValid)
		@docUploadController.on 'amDirty', =>
			@trigger 'amDirty'

		@batchListValidator = new BatchListValidatorController
			el: @$(".bv_batchListValidator")
			collection: @model.get('batchNameList')
		@batchListValidator.on("invalid", @subFormIsInvalid)
		@batchListValidator.on("valid", @subFormIsValid)
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
			exp = @model.asExperiment()
			exp.save(null,{
			wait:true,
			success:(model, response)=>
				console.log('Successfully saved!')
				console.log(model)
				@model.set
					experiment: model
				@model.updateDocForBatches()
				@trigger 'amClean'
				@render()
			error: (model, error)=>
				console.log(model.toJSON())
				console.log('error.responseText')
			})
			console.log @model

	resetForm: =>
		$(@el).empty()
		$(@el).html @template()
		@model = new DocForBatches()
		@setupSubControllers()
		@render()


