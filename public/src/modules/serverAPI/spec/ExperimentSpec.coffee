beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Experiment module testing", ->

	describe "Experiment State model testing", ->
		describe "when created empty", ->
			beforeEach ->
				@es = new ExperimentState()
			it "Class should exist", ->
				expect(@es).toBeDefined()
			it "should have defaults", ->
				expect(@es.get('experimentValues') instanceof Backbone.Collection).toBeTruthy()
		describe "When loaded from state json", ->
			beforeEach ->
				@es = new ExperimentState window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates[0]
			describe "after initial load", ->
				it "state should have kind ", ->
					expect(@es.get('stateKind')).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates[0].stateKind
				it "state should have values", ->
					expect(@es.get('experimentValues').length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates[0].experimentValues.length
				it "state should have populated value", ->
					expect(@es.get('experimentValues').at(0).get('valueKind')).toEqual "data transformation rule"
				it "should return requested value", ->
					values = @es.getValuesByTypeAndKind("stringValue", "data transformation rule")
					expect(values.length).toEqual 1
					expect(values[0].get('stringValue')).toEqual "(maximum-minimum)/minimum"
				it "should trigger change when value changed in state", ->
					runs ->
						@stateChanged = false
						@es.on 'change', =>
							@stateChanged = true
						@es.get('experimentValues').at(0).set(valueKind: 'newkind')
					waitsFor ->
						@stateChanged
					, 500
					runs ->
						expect(@stateChanged).toBeTruthy()

	describe "Experiment State List model testing", ->
		beforeEach ->
			@esl = new ExperimentStateList window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates
		describe "after initial load", ->
			it "Class should exist", ->
				expect(@esl).toBeDefined()
			it "should have states ", ->
				expect(@esl.length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates.length
			it "first state should have kind ", ->
				expect(@esl.at(0).get('stateKind')).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates[0].stateKind
			it "states should have values", ->
				expect(@esl.at(0).get('experimentValues').length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates[0].experimentValues.length
			it "first state should have populated value", ->
				expect(@esl.at(0).get('experimentValues').at(0).get('valueKind')).toEqual "data transformation rule"
		describe "Get states by type and kind", ->
			it "should return requested state", ->
				values = @esl.getStatesByTypeAndKind "metadata", "experiment analysis parameters"
				expect(values.length).toEqual 1
				expect(values[0].get('stateTypeAndKind')).toEqual "metadata_experiment analysis parameters"
		describe "Get value by type and kind", ->
			it "should return requested value", ->
				value = @esl.getStateValueByTypeAndKind "metadata", "experiment analysis parameters", "stringValue", "data transformation rule"
				expect(value.get('stringValue')).toEqual "(maximum-minimum)/minimum"

	describe "Experiment model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@exp = new Experiment()
			describe "Defaults", ->
				it 'Should have an empty label list', ->
					expect(@exp.get('experimentLabels').length).toEqual 0
					expect(@exp.get('experimentLabels') instanceof LabelList).toBeTruthy()
				it 'Should have an empty state list', ->
					expect(@exp.get('experimentStates').length).toEqual 0
`				it 'Should have an empty scientist', ->
					expect(@exp.get('recordedBy')).toEqual ""
				it 'Should have an empty recordedDate', ->
					expect(@exp.get('recordedDate')).toBeNull()
				it 'Should have an empty short description', ->
					expect(@exp.get('shortDescription')).toEqual ""
				it 'Should have no protocol', ->
					expect(@exp.get('protocol')).toBeNull()
				it 'Should have an empty analysisGroups', ->
					expect(@exp.get('analysisGroups') instanceof AnalysisGroupList).toBeTruthy()
		describe "when loaded from existing", ->
			beforeEach ->
				@exp = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
			describe "after initial load", ->
				it "should have a kind", ->
					expect(@exp.get('kind')).toEqual "primary screen experiment"
				it "should have the protocol set ", ->
					expect(@exp.get('protocol').id).toEqual 269
				it "should have the analysisGroups set ", ->
					expect(@exp.get('analysisGroups').length).toEqual 1
				it "should have the analysisGroup List", ->
					expect(@exp.get('analysisGroups') instanceof AnalysisGroupList).toBeTruthy()
				it "should have the analysisGroup ", ->
					console.log @exp.get('analysisGroups').at(0) instanceof AnalysisGroup
					expect(@exp.get('analysisGroups').at(0) instanceof AnalysisGroup).toBeTruthy()
				it "should have the analysisGroup id ", ->
					expect(@exp.get('analysisGroups').at(0).id ).toEqual 64782
				it "should have a code ", ->
					expect(@exp.get('codeName')).toEqual "EXPT-00000046"
				it "should have the shortDescription set", ->
					expect(@exp.get('shortDescription')).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.shortDescription
				it "should have labels", ->
					expect(@exp.get('experimentLabels').length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.experimentLabels.length
				it "should have labels", ->
					expect(@exp.get('experimentLabels').at(0).get('labelKind')).toEqual "experiment name"
				it "should have states ", ->
					expect(@exp.get('experimentStates').length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.experimentStates.length
				it "should have states with kind ", ->
					expect(@exp.get('experimentStates').at(0).get('stateKind')).toEqual "experiment analysis parameters"
				it "states should have values", ->
					expect(@exp.get('experimentStates').at(0).get('experimentValues').at(0).get('valueKind')).toEqual "data transformation rule"
		describe "when created from template protocol", ->
			beforeEach ->
				@exp = new Experiment()
				@exp.copyProtocolAttributes new Protocol(window.protocolServiceTestJSON.fullSavedProtocol)
			describe "after initial load", ->
				it "Class should exist", ->
					expect(@exp).toBeDefined()
				it "should have same kind as protocol", ->
					expect(@exp.get('kind')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.kind
				it "should have the protocol set ", ->
					expect(@exp.get('protocol').get('codeName')).toEqual "PROT-00000033"
				it "should have the shortDescription set to the protocols short description", ->
					expect(@exp.get('shortDescription')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.shortDescription
				it "should have the description set to the protocols description", ->
					expect(@exp.get('description')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.description
				it "should not have the labels copied", ->
					expect(@exp.get('experimentLabels').length).toEqual 0
				it "should have the states copied", ->
					expect(@exp.get('experimentStates').length).toEqual window.protocolServiceTestJSON.fullSavedProtocol.protocolStates.length
		describe "model change propogation", ->
			it "should trigger change when label changed", ->
				runs ->
					@exp = new Experiment()
					@experimentChanged = false
					@exp.get('experimentLabels').setBestName new Label
						labelKind: "experiment name"
						labelText: "test label"
						recordedBy: @exp.get 'recordedBy'
						recordedDate: @exp.get 'recordedDate'
					@exp.on 'change', =>
						@experimentChanged = true
					@experimentChanged = false
					@exp.get('experimentLabels').setBestName new Label
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
					@exp.get('experimentStates').at(0).get('experimentValues').at(0).set(valueKind: 'fred')
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
				@exp.get('experimentLabels').setBestName new Label
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
		### hello		expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when protocol not selected", ->
				@exp.set protocol: null
				expect(@exp.isValid()).toBeFalsy()
				filtErrors = _.filter(@exp.validationError, (err) ->
					err.attribute=='protocol'
				)
				expect(filtErrors.length).toBeGreaterThan 0 ###

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
					expect(@exp.get('experimentLabels')  instanceof LabelList).toBeTruthy()
					expect(@exp.get('experimentLabels').length).toBeGreaterThan 0
			it "should convert state array to state list", ->
				runs ->
					expect(@exp.get('experimentStates')  instanceof ExperimentStateList).toBeTruthy()
					expect(@exp.get('experimentStates').length).toBeGreaterThan 0
			it "should convert protocol has to Protocol", ->
				runs ->
					expect(@exp.get('protocol')  instanceof Protocol).toBeTruthy()

	describe "ExperimentBaseController testing", ->
		# This basic controller manages display and editing of basic attributes
		# Other controllers may be setup by a wrapping app controller to handle special
		# experiment attributes like primary screen analysis or dose response fitting.
		describe "When created with an unsaved experiment that has protocol attributes copied in", ->
			beforeEach ->
				@copied = false
				@exp = new Experiment()
				@exp.on "protocol_attributes_copied", =>
					@copied = true
				@exp.copyProtocolAttributes new Protocol(window.protocolServiceTestJSON.fullSavedProtocol)
				@ebc = new ExperimentBaseController
					model: @exp
					el: $('#fixture')
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
					expect(@copied).toBeTruthy()
			describe "populated fields", ->
				it "should show the protocol code", ->
					expect(@ebc.$('.bv_protocolCode').val()).toEqual "PROT-00000033"
				it "should show the protocol name", ->
					expect(@ebc.$('.bv_protocolName').html()).toEqual "FLIPR target A biochemical"
				it "should fill the short description field", ->
					expect(@ebc.$('.bv_shortDescription').html()).toEqual "primary analysis"
			describe "User edits fields", ->
				it "should update model when scientist is changed", ->
					expect(@ebc.model.get 'recordedBy').toEqual ""
					@ebc.$('.bv_recordedBy').val("jmcneil")
					@ebc.$('.bv_recordedBy').change()
					expect(@ebc.model.get 'recordedBy').toEqual "jmcneil"
				it "should update model when shortDescription is changed", ->
					@ebc.$('.bv_shortDescription').val(" New short description   ")
					@ebc.$('.bv_shortDescription').change()
					expect(@ebc.model.get 'shortDescription').toEqual "New short description"
				#					it "should update model when description is changed", ->
				#						@ebc.$('.bv_description').val(" New long description   ")
				#						@ebc.$('.bv_description').change()
				#						states = @ebc.model.get('experimentStates').getStatesByTypeAndKind "metadata", "experiment info"
				#						expect(states.length).toEqual 1
				#						values = states[0].getValuesByTypeAndKind("stringValue", "description")
				#						desc = values[0].get('stringValue')
				#						expect(desc).toEqual "New long description"
				it "should update model when name is changed", ->
					@ebc.$('.bv_experimentName').val(" Updated experiment name   ")
					@ebc.$('.bv_experimentName').change()
					expect(@ebc.model.get('experimentLabels').pickBestLabel().get('labelText')).toEqual "Updated experiment name"
				it "should update model when recorded date is changed", ->
					@ebc.$('.bv_recordedDate').val(" 2013-3-16   ")
					@ebc.$('.bv_recordedDate').change()
					expect(@ebc.model.get 'recordedDate').toEqual new Date("2013-3-16").getTime()
		describe "When created from a saved experiment", ->
			beforeEach ->
				@exp2 = new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
				@ebc = new ExperimentBaseController
					model: @exp2
					el: $('#fixture')
				@ebc.render()
			it "should show the protocol code", ->
				expect(@ebc.$('.bv_protocolCode').val()).toEqual "PROT-00000033"
			it "should show the protocol name", ->
				waits(200) # needs to fill out stub protocol
				runs ->
					expect(@ebc.$('.bv_protocolName').html()).toEqual "FLIPR target A biochemical"
			it "should have use protocol parameters disabled", ->
				expect(@ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual "disabled"
			it "should fill the short description field", ->
				expect(@ebc.$('.bv_shortDescription').html()).toEqual "experiment short description goes here"
			it "should fill the long description field", ->
				expect(@ebc.$('.bv_description').html()).toEqual "My eloquent description"
			#TODO this test breaks because of the weird behavior where new a Model from a json hash
			# then setting model attribites changes the hash
			xit "should fill the name field", ->
				expect(@ebc.$('.bv_experimentName').val()).toEqual "FLIPR target A biochemical"
			it "should fill the date field", ->
				expect(@ebc.$('.bv_recordedDate').val()).toEqual "2013-2-4"
			it "should fill the user field", ->
				expect(@ebc.$('.bv_recordedBy').val()).toEqual "jmcneil"
			it "should fill the code field", ->
				expect(@ebc.$('.bv_experimentCode').html()).toEqual "EXPT-00000046"
		describe "When created from a new experiment", ->
			beforeEach ->
				@exp0 = new Experiment()
				@ebc = new ExperimentBaseController
					model: @exp0
					el: $('#fixture')
				@ebc.render()
			describe "basic startup conditions", ->
				it "should have protocol code not set", ->
					expect(@ebc.$('.bv_protocolCode').val()).toEqual ""
				it "should have use protocol parameters disabled", ->
					expect(@ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual "disabled"
				it "should fill the date field", ->
					expect(@ebc.$('.bv_recordedDate').val()).toEqual ""
			describe "when user picks protocol ", ->
				beforeEach ->
					runs ->
						@ebc.$('.bv_protocolCode').val("PROT-00000033")
						@ebc.$('.bv_protocolCode').change()
				describe "When user picks protocol", ->
					it "should update model", ->
						waits(200) # needs to fetch stub protocol
						runs ->
							expect(@ebc.model.get('protocol').get('codeName')).toEqual "PROT-00000033"
					it "should enable use protocol params", ->
						waits(200) # needs to fill out stub protocol
						runs ->
							expect(@ebc.$('.bv_useProtocolParameters').attr("disabled")).toBeUndefined()
					it "should show the protocol name", ->
						waits(200) # needs to fill out stub protocol
						runs ->
							expect(@ebc.$('.bv_protocolName').html()).toEqual "FLIPR target A biochemical"
				describe "When user and asks to clone attributes should populate fields", ->
					beforeEach ->
						waits(200)
						runs ->
							@ebc.$('.bv_useProtocolParameters').click()
					it "should fill the short description field", ->
						waits(200)
						runs ->
							expect(@ebc.$('.bv_shortDescription').html()).toEqual "primary analysis"
			describe "controller validation rules", ->
				beforeEach ->
					runs ->
						@ebc.$('.bv_recordedBy').val("jmcneil")
						@ebc.$('.bv_recordedBy').change()
						@ebc.$('.bv_recordedDate').val(" 2013-3-16   ")
						@ebc.$('.bv_recordedDate').change()
						@ebc.$('.bv_shortDescription').val(" New short description   ")
						@ebc.$('.bv_shortDescription').change()
						@ebc.$('.bv_protocolCode').val("PROT-00000033")
						@ebc.$('.bv_protocolCode').change()
						@ebc.$('.bv_experimentName').val(" Updated experiment name   ")
						@ebc.$('.bv_experimentName').change()
					waits(200)
					runs ->
						@ebc.$('.bv_useProtocolParameters').click()
					waits(200)
				it "should be valid if form fully filled out", ->
					runs ->
						expect(@ebc.isValid()).toBeTruthy()
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
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_recordedDate').val("")
							@ebc.$('.bv_recordedDate').change()
					it "should show error in date field", ->
						runs ->
							console.log @ebc.$('.bv_group_recordedDate')
							expect(@ebc.$('.bv_group_recordedDate').hasClass('error')).toBeTruthy()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@ebc.$('.bv_recordedBy').val("")
							@ebc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@ebc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
			###
					describe "when protocol not selected", -> #this is not working properly - Fiona
					beforeEach ->
						runs ->
							@ebc.$('.bv_protocolCode').val(null)
							@ebc.$('.bv_protocolCode').change()
							console.log @ebc.model.isValid()
					it "should show error on protocol dropdown", ->
						runs ->
							expect(@ebc.$('.bv_group_protocol').hasClass('error')).toBeTruthy()
###





#TODO  make scientist and date render from and update recorded** if new expt and updated** if existing
#TODO add notebook field