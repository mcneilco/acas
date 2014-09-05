beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Experiment module testing", ->
	describe "Experiment model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@exp = new Experiment()
			describe "Defaults", ->
				it 'Should have default type and kind', ->
					expect(@exp.get('lsType')).toEqual "default"
					expect(@exp.get('lsKind')).toEqual "default"
				it 'Should have an empty label list', ->
					expect(@exp.get('lsLabels').length).toEqual 0
					expect(@exp.get('lsLabels') instanceof LabelList).toBeTruthy()
				it 'Should have an empty tags list', ->
					expect(@exp.get('lsTags').length).toEqual 0
					expect(@exp.get('lsTags') instanceof Backbone.Collection).toBeTruthy()
				it 'Should have an empty state list', ->
					expect(@exp.get('lsStates').length).toEqual 0
					expect(@exp.get('lsStates') instanceof StateList).toBeTruthy()
				it 'Should have an empty scientist', ->
					expect(@exp.get('recordedBy')).toEqual ""
				it 'Should have an recordedDate set to now', ->
					expect(new Date(@exp.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it 'Should have an empty short description with a space as an oracle work-around', ->
					expect(@exp.get('shortDescription')).toEqual " "
				it 'Should have no protocol', ->
					expect(@exp.get('protocol')).toBeNull()
				it 'Should have an empty analysisGroups', ->
					expect(@exp.get('analysisGroups') instanceof AnalysisGroupList).toBeTruthy()
			describe "required states and values", ->
				it 'Should have a description value', ->
					expect(@exp.getDescription() instanceof Value).toBeTruthy()
					expect(@exp.getDescription().get('clobValue')).toEqual ""
				it 'Should have a notebook value', ->
					expect(@exp.getNotebook() instanceof Value).toBeTruthy()
				it 'Should have a project value', ->
					expect(@exp.getProjectCode() instanceof Value).toBeTruthy()
				it 'Project code should default to unassigned ', ->
					expect(@exp.getProjectCode().get('codeValue')).toEqual "unassigned"
				it 'Experiment status should default to created ', ->
					expect(@exp.getStatus().get('stringValue')).toEqual "created"
				it 'completionDate should be null ', ->
					expect(@exp.getCompletionDate().get('dateValue')).toEqual null
			describe "other features", ->
				describe "should tell you if it is editable based on status", ->
					it "should be locked if status is New", ->
						@exp.getStatus().set stringValue: "New"
						expect(@exp.isEditable()).toBeTruthy()
					it "should be locked if status is started", ->
						@exp.getStatus().set stringValue: "started"
						expect(@exp.isEditable()).toBeTruthy()
					it "should be locked if status is complete", ->
						@exp.getStatus().set stringValue: "complete"
						expect(@exp.isEditable()).toBeTruthy()
					it "should be locked if status is finalized", ->
						@exp.getStatus().set stringValue: "finalized"
						expect(@exp.isEditable()).toBeFalsy()
					it "should be locked if status is rejected", ->
						@exp.getStatus().set stringValue: "rejected"
						expect(@exp.isEditable()).toBeFalsy()

		describe "when loaded from existing", ->
			beforeEach ->
				@exp = new Experiment window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups
			describe "after initial load", ->
				it "should have a kind", ->
					expect(@exp.get('lsKind')).toEqual "ACAS doc for batches" # changed from get kind to get lsKind
				it "should have the protocol set ", ->
					expect(@exp.get('protocol').id).toEqual 2403
				it "should have the analysisGroups set ", ->
					expect(@exp.get('analysisGroups').length).toEqual 1
				it "should have the analysisGroup List", ->
					expect(@exp.get('analysisGroups') instanceof AnalysisGroupList).toBeTruthy()
				it "should have the analysisGroup ", ->
					expect(@exp.get('analysisGroups').at(0) instanceof AnalysisGroup).toBeTruthy()
				it "should have the states ", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates') instanceof StateList).toBeTruthy()
				it "should have the states lsKind ", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsKind')).toEqual 'Document for Batch'
				it "should have the states lsType", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsType')).toEqual 'results'
				it "should have the states recordedBy", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('recordedBy')).toEqual 'jmcneil'
				it "should have the AnalysisGroupValues ", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues') instanceof ValueList).toBeTruthy()
				it "should have the AnalysisGroupValues array", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').length).toEqual 3
				it "should have the AnalysisGroupValue ", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0) instanceof Value).toBeTruthy()
				it "should have the AnalysisGroupValue valueKind ", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual "annotation"
				it "should have the AnalysisGroupValue valueType", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('lsType')).toEqual "fileValue"
				it "should have the AnalysisGroupValue value", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('fileValue')).toEqual "exampleUploadedFile.txt"
				it "should have the AnalysisGroupValue comment", ->
					expect(@exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('comments')).toEqual "ok"
				it "should have the analysisGroup id ", ->
					expect(@exp.get('analysisGroups').at(0).id ).toEqual 64782
				it "should have a code ", ->
					expect(@exp.get('codeName')).toEqual "EXPT-00000222"
				it "should have the shortDescription set", ->
					expect(@exp.get('shortDescription')).toEqual window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups.shortDescription
				it "should have labels", ->
					expect(@exp.get('lsLabels').length).toEqual window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups.lsLabels.length
				it "should have labels", ->
					expect(@exp.get('lsLabels').at(0).get('lsKind')).toEqual "experiment name"
				it 'Should have a description value', ->
					expect(@exp.getDescription().get('clobValue')).toEqual "long description goes here"
				it 'Should have a notebook value', ->
					expect(@exp.getNotebook().get('stringValue')).toEqual "911"
				it 'Should have a project value', ->
					expect(@exp.getProjectCode().get('codeValue')).toEqual "project1"
				it 'Should have a completionDate value', ->
					expect(@exp.getCompletionDate().get('dateValue')).toEqual 1342080000000
				it 'Should have a status value', ->
					expect(@exp.getStatus().get('stringValue')).toEqual "started"
		describe "when created from template protocol", ->
			beforeEach ->
				@exp = new Experiment()
				@exp.getNotebook().set stringValue: "spec test NB"
				@exp.getCompletionDate().set dateValue: 2000000000000
				@exp.getProjectCode().set codeValue: "project45"
				@exp.copyProtocolAttributes new Protocol(window.protocolServiceTestJSON.fullSavedProtocol)
			describe "after initial load", ->
				it "Class should exist", ->
					expect(@exp).toBeDefined()
				it "should have same kind as protocol", ->
					expect(@exp.get('lsKind')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.lsKind
				it "should have the protocol set ", ->
					expect(@exp.get('protocol').get('codeName')).toEqual "PROT-00000001"
				it "should have the shortDescription set to the protocols short description", ->
					expect(@exp.get('shortDescription')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.shortDescription
				it "should have the description set to the protocols description", ->
					expect(@exp.get('description')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.description
				it "should not have the labels copied", ->
					expect(@exp.get('lsLabels').length).toEqual 0
				it "should have the states copied", ->
					expect(@exp.get('lsStates').length).toEqual window.protocolServiceTestJSON.fullSavedProtocol.lsStates.length
				it 'Should have a description value', ->
					expect(@exp.getDescription().get('clobValue')).toEqual "long description goes here"
				it 'Should not override set notebook value', ->
					expect(@exp.getNotebook().get('stringValue')).toEqual "spec test NB"
				it 'Should not override completionDate value', ->
					expect(@exp.getCompletionDate().get('dateValue')).toEqual 2000000000000
				it 'Should not override projectCode value', ->
					expect(@exp.getProjectCode().get('codeValue')).toEqual "project45"
				it 'Should not have a tags', ->
					expect(@exp.get('lsTags').length).toEqual 0
				it 'Should have a status value of created', ->
					expect(@exp.getStatus().get('stringValue')).toEqual "created"
		describe "model change propogation", ->
			it "should trigger change when label changed", ->
				runs ->
					@exp = new Experiment()
					@experimentChanged = false
					@exp.get('lsLabels').setBestName new Label
						labelKind: "experiment name"
						labelText: "test label"
						recordedBy: @exp.get 'recordedBy'
						recordedDate: @exp.get 'recordedDate'
					@exp.on 'change', =>
						@experimentChanged = true
					@experimentChanged = false
					@exp.get('lsLabels').setBestName new Label
						labelKind: "experiment name"
						labelText: "new label"
						recordedBy: @exp.get 'recordedBy'
						recordedDate: @exp.get 'recordedDate'
				waitsFor ->
					@experimentChanged
				, 500
				runs ->
					expect(@experimentChanged).toBeTruthy()
			it "should trigger change when value changed in state", ->
				runs ->
					@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
					@experimentChanged = false
					@exp.on 'change', =>
						@experimentChanged = true
					@exp.get('lsStates').at(0).get('lsValues').at(0).set(codeValue: 'fred')
				waitsFor ->
					@experimentChanged
				, 500
				runs ->
					expect(@experimentChanged).toBeTruthy()
		describe "model validation", ->
			beforeEach ->
				@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
			it "should be valid when loaded from saved", ->
				expect(@exp.isValid()).toBeTruthy()
			it "should be invalid when name is empty", ->
				@exp.get('lsLabels').setBestName new Label
					labelKind: "experiment name"
					labelText: ""
					recordedBy: @exp.get 'recordedBy'
					recordedDate: @exp.get 'recordedDate'
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='experimentName'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when date is empty", ->
				@exp.set recordedDate: new Date("").getTime()
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='recordedDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when scientist not selected", ->
				@exp.set recordedBy: ""
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='recordedBy'
				)
			it "should be invalid when protocol not selected", ->
				@exp.set protocol: null
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='protocolCode'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when notebook is empty", ->
				@exp.getNotebook().set
					stringValue: ""
					recordedBy: @exp.get('recordedBy')
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when projectCode is unassigned", ->
				@exp.getProjectCode().set
					codeValue: "unassigned"
					recordedBy: @exp.get('recordedBy')
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='projectCode'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it 'should require that completionDate not be ""', ->
				@exp.getCompletionDate().set
					dateValue: new Date("").getTime()
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
		describe "prepare to save", ->
			beforeEach ->
				@exp = new Experiment()
				@exp.set recordedBy: "jmcneil"
				@exp.set recordedDate: -1
			afterEach ->
				@exp.get('lsLabels').reset()
				@exp.get('lsStates').reset()
			it "should set experiment's set to now", ->
				@exp.prepareToSave()
				expect(new Date(@exp.get('recordedDate')).getHours()).toEqual new Date().getHours()
			it "should have function to add recorded* to all labels", ->
				@exp.get('lsLabels').setBestName new Label
					labelKind: "experiment name"
					labelText: "new name"
				@exp.prepareToSave()
				expect(@exp.get('lsLabels').pickBestLabel().get('recordedBy')).toEqual "jmcneil"
				expect(@exp.get('lsLabels').pickBestLabel().get('recordedDate')).toBeGreaterThan 1
			it "should have function to add recorded * to values", ->
				status = @exp.getStatus()
				@exp.prepareToSave()
				expect(status.get('recordedBy')).toEqual "jmcneil"
				expect(status.get('recordedDate')).toBeGreaterThan 1
			it "should have function to add recorded * to states", ->
				state = @exp.get('lsStates').getOrCreateStateByTypeAndKind "metadata", "experiment metadata"
				@exp.prepareToSave()
				expect(state.get('recordedBy')).toEqual "jmcneil"
				expect(state.get('recordedDate')).toBeGreaterThan 1

		describe "model composite component conversion", ->
			beforeEach ->
				runs ->
					@saveSucessful = false
					@saveComplete = false
					@exp = new Experiment id: 1
					@exp.on 'sync', =>
						@saveSucessful = true
						@saveComplete = true
					@exp.on 'invalid', =>
						@saveComplete = true
					@exp.fetch()
				waitsFor ->
					@saveComplete == true
				, 500
			it "should return from sync, not invalid", ->
				runs ->
					expect(@saveSucessful).toBeTruthy()
			it "should convert labels array to label list", ->
				runs ->
					expect(@exp.get('lsLabels')  instanceof LabelList).toBeTruthy()
					expect(@exp.get('lsLabels').length).toBeGreaterThan 0
			it "should convert state array to state list", ->
				runs ->
					expect(@exp.get('lsStates')  instanceof StateList).toBeTruthy()
					expect(@exp.get('lsStates').length).toBeGreaterThan 0
			it "should convert protocol  to Protocol", ->
				runs ->
					expect(@exp.get('protocol')  instanceof Protocol).toBeTruthy()
			it "should convert tags has to collection of Tags", ->
				runs ->
					expect(@exp.get('lsTags')  instanceof TagList).toBeTruthy()


	describe "Experiment List testing", ->
		beforeEach ->
			@el = new ExperimentList()
		describe "existance tests", ->
			it "should be defined", ->
				expect(ExperimentList).toBeDefined()

	describe "ExperimentBaseController testing", ->
		# This basic controller manages display and editing of basic attributes
		# Other controllers may be setup by a wrapping app controller to handle special
		# experiment attributes like primary screen analysis or dose response fitting.
		describe "When created with an unsaved experiment that has protocol attributes copied in", ->
			beforeEach ->
				runs ->
					@copied = false
					@exp0 = new Experiment()
					# I should not have to clear these. I think (hope) it is a bug in spec runner
					@exp0.getNotebook().set stringValue: null
					@exp0.getCompletionDate().set dateValue: null
					@exp0.getProjectCode().set codeValue: null
					@exp0.on "protocol_attributes_copied", =>
						@copied = true
					@exp0.copyProtocolAttributes new Protocol(window.protocolServiceTestJSON.fullSavedProtocol)
					@ebc = new ExperimentBaseController
						model: @exp0
						el: $('#fixture')
						protocolFilter: "?protocolKind=FLIPR"
					@ebc.render()
			describe "Basic loading", ->
				it "Class should exist", ->
					expect(@ebc).toBeDefined()
				it "Should load the template", ->
					expect(@ebc.$('.bv_experimentCode').html()).toEqual "autofill when saved"
				it "should trigger copy complete", ->
					waitsFor ->
						@copied
					, 500
					runs ->
						expect(@copied).toBeTruthy()
			describe "it should show a picklist for protocols", ->
				beforeEach ->
					waitsFor ->
						@ebc.$('.bv_protocolCode option').length > 0
					,
						1000
					runs ->
				it "should show protocol options after loading them from server", ->
					expect(@ebc.$('.bv_protocolCode option').length).toBeGreaterThan 0
			describe "it should show a picklist for projects", ->
				beforeEach ->
					waitsFor ->
						@ebc.$('.bv_projectCode option').length > 0
					,
						1000
					runs ->
				it "should show project options after loading them from server", ->
					expect(@ebc.$('.bv_projectCode option').length).toBeGreaterThan 0
				it "should default to unassigned", ->
					expect(@ebc.$('.bv_projectCode').val()).toEqual "unassigned"
			describe "it should show a picklist for experiment statuses", ->
				beforeEach ->
					waitsFor ->
						@ebc.$('.bv_status option').length > 0
					,
						1000
					runs ->
				it "should show status options after loading them from server", ->
					expect(@ebc.$('.bv_status option').length).toBeGreaterThan 0
				it "should default to created", ->
					expect(@ebc.$('.bv_status').val()).toEqual "created"
			describe "populated fields", ->
				it "should show the protocol code", ->
					waitsFor ->
						@ebc.$('.bv_protocolCode option').length > 0
					, 1000
					runs ->
						expect(@ebc.$('.bv_protocolCode').val()).toEqual "PROT-00000001"
				it "should fill the short description field", ->
					expect(@ebc.$('.bv_shortDescription').html()).toEqual "primary analysis"
				it "should fill the description field", ->
					expect(@ebc.$('.bv_description').html()).toEqual "long description goes here"
				it "should not fill the notebook field", ->
					expect(@ebc.$('.bv_notebook').val()).toEqual ""
			describe "User edits fields", ->
				it "should update model when scientist is changed", ->
					expect(@ebc.model.get 'recordedBy').toEqual ""
					@ebc.$('.bv_recordedBy').val("nxm7557")
					@ebc.$('.bv_recordedBy').change()
					expect(@ebc.model.get 'recordedBy').toEqual "nxm7557"
				it "should update model when shortDescription is changed", ->
					@ebc.$('.bv_shortDescription').val(" New short description   ")
					@ebc.$('.bv_shortDescription').change()
					expect(@ebc.model.get 'shortDescription').toEqual "New short description"
				it "should set model shortDescription to a space when shortDescription is set to empty", ->
					@ebc.$('.bv_shortDescription').val("")
					@ebc.$('.bv_shortDescription').change()
					expect(@ebc.model.get 'shortDescription').toEqual " "
				it "should update model when description is changed", ->
					@ebc.$('.bv_description').val(" New long description   ")
					@ebc.$('.bv_description').change()
					states = @ebc.model.get('lsStates').getStatesByTypeAndKind "metadata", "experiment metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "description")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New long description"
					expect(@ebc.model.getDescription().get('clobValue')).toEqual "New long description"
				it "should update model when name is changed", ->
					@ebc.$('.bv_experimentName').val(" Updated experiment name   ")
					@ebc.$('.bv_experimentName').change()
					expect(@ebc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "Updated experiment name"
				it "should update model when completion date is changed", ->
					@ebc.$('.bv_completionDate').val(" 2013-3-16   ")
					@ebc.$('.bv_completionDate').change()
					expect(@ebc.model.getCompletionDate().get('dateValue')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@ebc.$('.bv_notebook').val(" Updated notebook  ")
					@ebc.$('.bv_notebook').change()
					expect(@ebc.model.getNotebook().get('stringValue')).toEqual "Updated notebook"
				it "should update model when protocol is changed", ->
					waitsFor ->
						@ebc.$('.bv_protocolCode option').length > 0
					, 1000
					runs ->
						# manually change protocol, then let this set back since I don't have other stubs to load
						@ebc.model.set protocol: {}
						@ebc.$('.bv_protocolCode').val("PROT-00000001")
						@ebc.$('.bv_protocolCode').change()
					#changing protocol needs a server round trip
					waits 1000
					runs ->
						expect(@ebc.model.get('protocol').get('codeName')).toEqual "PROT-00000001"
				it "should update model when project is changed", ->
					waitsFor ->
						@ebc.$('.bv_projectCode option').length > 0
					, 1000
					runs ->
						@ebc.$('.bv_projectCode').val("project2")
						@ebc.$('.bv_projectCode').change()
						expect(@ebc.model.getProjectCode().get('codeValue')).toEqual "project2"
				it "should update model when tag added", ->
					@ebc.$('.bv_tags').tagsinput 'add', "lucy"
					#TODO this doens't test change event capture, which doesn't work For now for uspdate before save
					#@ebc.$('.bv_tags').focusout()
					@ebc.tagListController.handleTagsChanged()
					expect(@ebc.model.get('lsTags').at(0).get('tagText')).toEqual "lucy"
				it "should update model when experiment status changed", ->
					waitsFor ->
						@ebc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@ebc.$('.bv_status').val('complete')
						@ebc.$('.bv_status').change()
						expect(@ebc.model.getStatus().get('stringValue')).toEqual 'complete'
		describe "When created from a saved experiment", ->
			beforeEach ->
				@exp2 = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
				@ebc = new ExperimentBaseController
					model: @exp2
					el: $('#fixture')
					protocolFilter: "?protocolKind=FLIPR"
				@ebc.render()
			describe "property display", ->
				it "should show the protocol code", ->
					waitsFor ->
						@ebc.$('.bv_protocolCode option').length > 0
					, 1000
					runs ->
						expect(@ebc.$('.bv_protocolCode').val()).toEqual "PROT-00000001"
				it "should show the project code", ->
					waitsFor ->
						@ebc.$('.bv_projectCode option').length > 0
					, 1000
					runs ->
						expect(@ebc.$('.bv_projectCode').val()).toEqual "project1"
				it "should show the save button text as Update", ->
					expect(@ebc.$('.bv_save').html()).toEqual "Update"
				it "should hide the protocol parameters button because we are chaning the behaviopr and may eliminate it", ->
					expect(@ebc.$('.bv_useProtocolParameters')).toBeHidden()
				it "should have use protocol parameters disabled", ->
					expect(@ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual "disabled"
				it "should have protocol select disabled", ->
					expect(@ebc.$('.bv_protocolCode').attr("disabled")).toEqual "disabled"
				it "should fill the short description field", ->
					expect(@ebc.$('.bv_shortDescription').html()).toEqual "experiment created by generic data parser"
				it "should fill the long description field", ->
					expect(@ebc.$('.bv_description').html()).toEqual "long description goes here"
				#TODO this test breaks because of the weird behavior where new a Model from a json hash
				# then setting model attribites changes the hash
				xit "should fill the name field", ->
					expect(@ebc.$('.bv_experimentName').val()).toEqual "FLIPR target A biochemical"
				it "should fill the date field in the same format is the date picker", ->
					expect(@ebc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the user field", ->
					expect(@ebc.$('.bv_recordedBy').val()).toEqual "nxm7557"
				it "should fill the code field", ->
					expect(@ebc.$('.bv_experimentCode').html()).toEqual "EXPT-00000001"
				it "should fill the notebook field", ->
					expect(@ebc.$('.bv_notebook').val()).toEqual "911"
				it "should show the tags", ->
					expect(@ebc.$('.bv_tags').tagsinput('items')[0]).toEqual "stuff"
				it "show the status", ->
					waitsFor ->
						@ebc.$('.bv_status option').length > 0
					, 1000
					runs ->
						expect(@ebc.$('.bv_status').val()).toEqual "started"
				it "should show the status select enabled", ->
					expect(@ebc.$('.bv_status').attr('disabled')).toBeUndefined()
			describe "Experiment status behavior", ->
				it "should disable all fields if experiment is finalized", ->
					waitsFor ->
						@ebc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@ebc.$('.bv_status').val('finalized')
						@ebc.$('.bv_status').change()
						expect(@ebc.$('.bv_notebook').attr('disabled')).toEqual 'disabled'
						expect(@ebc.$('.bv_status').attr('disabled')).toBeUndefined()
				it "should enable all fields if experiment is started", ->
					@ebc.$('.bv_status').val('finalized')
					@ebc.$('.bv_status').change()
					@ebc.$('.bv_status').val('started')
					@ebc.$('.bv_status').change()
					expect(@ebc.$('.bv_notebook').attr('disabled')).toBeUndefined()
				it "should hide lock icon if experiment is new", ->
					@ebc.$('.bv_status').val('new')
					@ebc.$('.bv_status').change()
					expect(@ebc.$('.bv_lock')).toBeHidden()
				it "should show lock icon if experiment is finalized", ->
					waitsFor ->
						@ebc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@ebc.$('.bv_status').val('finalized')
						@ebc.$('.bv_status').change()
						expect(@ebc.$('.bv_lock')).toBeVisible()

		describe "When created from a new experiment", ->
			beforeEach ->
				@exp0 = new Experiment()
				@exp0.getStatus().set stringValue: "created" #work around for left over pointers
				@ebc = new ExperimentBaseController
					model: @exp0
					el: $('#fixture')
					protocolFilter: "?protocolKind=FLIPR"
				@ebc.render()
			describe "basic startup conditions", ->
				it "should have protocol code not set", ->
					waitsFor ->
						@ebc.$('.bv_protocolCode option').length > 0
					, 1000
					runs ->
						expect(@ebc.$('.bv_protocolCode').val()).toEqual "unassigned"
				it "should have project code not set", ->
					waitsFor ->
						@ebc.$('.bv_projectCode option').length > 0
					, 1000
					runs ->
						expect(@ebc.$('.bv_projectCode').val()).toEqual "unassigned"
				it "should have use protocol parameters disabled", ->
					expect(@ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual "disabled"
				it "should have protocol select enabled", ->
					expect(@ebc.$('.bv_protocolCode').attr("disabled")).toBeUndefined()
				it "should not fill the date field", ->
					expect(@ebc.$('.bv_completionDate').val()).toEqual ""
				it "should show the save button text as Save", ->
					expect(@ebc.$('.bv_save').html()).toEqual "Save"
				it "should show the save button disabled", ->
					expect(@ebc.$('.bv_save').attr('disabled')).toEqual 'disabled'
				it "should show status select value as created", ->
					waitsFor ->
						@ebc.$('.bv_protocolCode option').length > 0
					, 1000
					runs ->
						console.log @ebc.model.getStatus()
						expect(@ebc.$('.bv_status').val()).toEqual 'created'
				it "should show the status select disabled", ->
					expect(@ebc.$('.bv_status').attr('disabled')).toEqual 'disabled'
			describe "when user picks protocol ", ->
				beforeEach ->
					runs ->
						@ebc.$('.bv_protocolCode').val("PROT-00000001")
						@ebc.$('.bv_protocolCode').change()
						waits(1000) # needs to fetch stub protocol
				describe "When user picks protocol", ->
					it "should update model", ->
						runs ->
							expect(@ebc.model.get('protocol').get('codeName')).toEqual "PROT-00000001"
					it "should fill the short description field because the protocol attrobutes are automatically copied", ->
						runs ->
							expect(@ebc.$('.bv_shortDescription').html()).toEqual "primary analysis"
					it "should enable use protocol params", ->
						runs ->
							expect(@ebc.$('.bv_useProtocolParameters').attr("disabled")).toBeUndefined()
				xdescribe "When user and asks to clone attributes should populate fields", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_useProtocolParameters').click()
					it "should fill the short description field", ->
						runs ->
							expect(@ebc.$('.bv_shortDescription').html()).toEqual "primary analysis"
			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@ebc.$('.bv_protocolCode option').length > 0 && @ebc.$('.bv_projectCode option').length > 0
					, 1000
					runs ->
						@ebc.$('.bv_recordedBy').val("nxm7557")
						@ebc.$('.bv_recordedBy').change()
						@ebc.$('.bv_shortDescription').val(" New short description   ")
						@ebc.$('.bv_shortDescription').change()
						@ebc.$('.bv_protocolCode').val("PROT-00000001")
						@ebc.$('.bv_protocolCode').change()
						@ebc.$('.bv_experimentName').val(" Updated experiment name   ")
						@ebc.$('.bv_experimentName').change()
					waits(200)
					runs ->
						#@ebc.$('.bv_useProtocolParameters').click()
						# must set notebook and project after copying protocol params because those are rest
						@ebc.$('.bv_projectCode').val("project1")
						@ebc.$('.bv_projectCode').change()
						@ebc.$('.bv_notebook').val("my notebook")
						@ebc.$('.bv_notebook').change()
						@ebc.$('.bv_completionDate').val(" 2013-3-16   ")
						@ebc.$('.bv_completionDate').change()
					waits(200)
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@ebc.isValid()).toBeTruthy()
							console.log @ebc.model.validationError
					it "save button should be enabled", ->
						runs ->
							expect(@ebc.$('.bv_save').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_experimentName').val("")
							@ebc.$('.bv_experimentName').change()
					it "should be invalid if experiment name not filled in", ->
						runs ->
							expect(@ebc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@ebc.$('.bv_group_experimentName').hasClass('error')).toBeTruthy()
					it "should show the save button disabled", ->
						runs ->
							expect(@ebc.$('.bv_save').attr('disabled')).toEqual 'disabled'
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_completionDate').val("")
							@ebc.$('.bv_completionDate').change()
					it "should show error in date field", ->
						runs ->
							expect(@ebc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_recordedBy').val("")
							@ebc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@ebc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
				describe "when protocol not selected", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_protocolCode').val("unassigned")
							@ebc.$('.bv_protocolCode').change()
					it "should show error on protocol dropdown", ->
						runs ->
							expect(@ebc.$('.bv_group_protocolCode').hasClass('error')).toBeTruthy()
				describe "when project not selected", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_projectCode').val("unassigned")
							@ebc.$('.bv_projectCode').change()
					it "should show error on project dropdown", ->
						runs ->
							expect(@ebc.$('.bv_group_projectCode').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_notebook').val("")
							@ebc.$('.bv_notebook').change()
					it "should show error on notebook dropdown", ->
						runs ->
							expect(@ebc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "expect save to work", ->
					it "model should be valid and ready to save", ->
						runs ->
							expect(@ebc.model.isValid()).toBeTruthy()
					it "should update experiment code", ->
						runs ->
							@ebc.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@ebc.$('.bv_experimentCode').html()).toEqual "EXPT-00000001"
					it "should show the save button text as Update", ->
						runs ->
							@ebc.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@ebc.$('.bv_save').html()).toEqual "Update"

#TODO all the specs that include copying protocol params have a hard 1 second wait. Add trigger to watch