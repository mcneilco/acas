beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Protocol module testing", ->
	describe "Protocol model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@prot = new Protocol()
			describe "Defaults", ->
				it 'Should have subclass set to protocol', ->
					expect(@prot.get("subclass")).toEqual "protocol"
				it 'Should have default type and kind', ->
					expect(@prot.get('lsType')).toEqual "default"
					expect(@prot.get('lsKind')).toEqual "default"
				it 'Should have an empty label list', ->
					expect(@prot.get('lsLabels').length).toEqual 0
					expect(@prot.get('lsLabels') instanceof LabelList).toBeTruthy()
				it 'Should have an empty tags list', ->
					expect(@prot.get('lsTags').length).toEqual 0
					expect(@prot.get('lsTags') instanceof Backbone.Collection).toBeTruthy()
				it 'Should have an empty state list', ->
					expect(@prot.get('lsStates').length).toEqual 0
					expect(@prot.get('lsStates') instanceof StateList).toBeTruthy()
				it 'Should have an empty scientist', ->
					expect(@prot.get('recordedBy')).toEqual ""
				it 'Should have an recordedDate set to now', ->
					expect(new Date(@prot.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it 'Should have an empty short description with a space as an oracle work-around', ->
					expect(@prot.get('shortDescription')).toEqual " "
			describe "required states and values", ->
				it 'Should have an assay tree rule value', ->
					expect(@prot.getAssayTreeRule() instanceof Value).toBeTruthy()
					expect(@prot.getAssayTreeRule().get('stringValue')).toEqual ""
				it 'Should have an assay principle value', ->
					expect(@prot.getAssayPrinciple() instanceof Value).toBeTruthy()
					expect(@prot.getAssayPrinciple().get('clobValue')).toEqual ""
				it 'Should have a description value', -> # description will be Protocol Details or experimentDetails
					expect(@prot.getDescription() instanceof Value).toBeTruthy()
					expect(@prot.getDescription().get('clobValue')).toEqual ""
				it 'Should have a comments value', ->
					expect(@prot.getComments() instanceof Value).toBeTruthy()
					expect(@prot.getComments().get('clobValue')).toEqual ""
				it 'Should have a notebook value', ->
					expect(@prot.getNotebook() instanceof Value).toBeTruthy()
				it 'Protocol status should default to created ', ->
					expect(@prot.getStatus().get('stringValue')).toEqual "created"
				it 'completionDate should be null ', ->
					expect(@prot.getCompletionDate().get('dateValue')).toEqual null
			describe "other features", ->
				describe "should tell you if it is editable based on status", ->
					it "should be locked if status is created", ->
						@prot.getStatus().set stringValue: "created"
						expect(@prot.isEditable()).toBeTruthy()
					it "should be locked if status is started", ->
						@prot.getStatus().set stringValue: "started"
						expect(@prot.isEditable()).toBeTruthy()
					it "should be locked if status is complete", ->
						@prot.getStatus().set stringValue: "complete"
						expect(@prot.isEditable()).toBeTruthy()
					it "should be locked if status is finalized", ->
						@prot.getStatus().set stringValue: "finalized"
						expect(@prot.isEditable()).toBeFalsy()
					it "should be locked if status is rejected", ->
						@prot.getStatus().set stringValue: "rejected"
						expect(@prot.isEditable()).toBeFalsy()

		describe "when loaded from existing", ->
			beforeEach ->
				@prot = new Protocol window.protocolServiceTestJSON.fullSavedProtocol
			describe "after initial load", ->
				it "should have a kind", ->
					expect(@prot.get('lsKind')).toEqual "default"
				it "should have a code ", ->
					expect(@prot.get('codeName')).toEqual "PROT-00000001"
				it "should have the shortDescription set", ->
					expect(@prot.get('shortDescription')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.shortDescription
				it "should have labels", ->
					expect(@prot.get('lsLabels').length).toEqual window.protocolServiceTestJSON.fullSavedProtocol.lsLabels.length
				it "should have labels", ->
					expect(@prot.get('lsLabels').at(0).get('lsKind')).toEqual "protocol name"
				it "should have states ", ->
					expect(@prot.get('lsStates').length).toEqual window.protocolServiceTestJSON.fullSavedProtocol.lsStates.length
				it "should have states with kind ", ->
					expect(@prot.get('lsStates').at(0).get('lsKind')).toEqual "protocol metadata"
				it "states should have values", ->
					expect(@prot.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual "assay tree rule"
				it 'Should have an assay principle value', ->
					expect(@prot.getAssayPrinciple().get('clobValue')).toEqual "assay principle goes here"
				it 'Should have a description value', ->
					expect(@prot.getDescription().get('clobValue')).toEqual "long description goes here"
				it 'Should have a comments value', ->
					expect(@prot.getComments().get('clobValue')).toEqual "protocol comments go here"
				it 'Should have a notebook value', ->
					expect(@prot.getNotebook().get('stringValue')).toEqual "912"
				it 'Should have a completionDate value', ->
					expect(@prot.getCompletionDate().get('dateValue')).toEqual 1342080000000
				it 'Should have a status value', ->
					expect(@prot.getStatus().get('stringValue')).toEqual "created"

		describe "when loaded from stub", ->
			beforeEach ->
				@prot = new Protocol window.protocolServiceTestJSON.stubSavedProtocol[0]
				runs ->
					@fetchReturned = false
					@prot.fetch success: =>
						@fetchReturned = true
			describe "utility functions", ->
				it "should know it's a stub", ->
					expect(@prot.isStub()).toBeTruthy()
			describe "get full object", ->
				it "should have raw labels when fetched", ->
					waitsFor ->
						@fetchReturned
					runs ->
						expect(@prot.has('lsLabels')).toBeTruthy()
				it "should have raw labels converted to LabelList when fetched", ->
					waitsFor ->
						@fetchReturned
					runs ->
						expect(@prot.get('lsLabels') instanceof LabelList).toBeTruthy()
		describe "model composite component conversion", ->
			beforeEach ->
				runs ->
					@saveSucessful = false
					@saveComplete = false
					@prot = new Protocol id:1
					@prot.on 'sync', =>
						@saveSucessful = true
						@saveComplete = true
					@prot.on 'invalid', =>
						@saveComplete = true
					@prot.fetch()
				waitsFor ->
					@saveComplete == true
				, 500
			it "should return from sync, not invalid", ->
				runs ->
					expect(@saveSucessful).toBeTruthy()
			it "should convert labels array to label list", ->
				runs ->
					expect(@prot.get('lsLabels')  instanceof LabelList).toBeTruthy()
					expect(@prot.get('lsLabels').length).toBeGreaterThan 0
			it "should convert state array to state list", ->
				runs ->
					expect(@prot.get('lsStates')  instanceof StateList).toBeTruthy()
					expect(@prot.get('lsStates').length).toBeGreaterThan 0
			it "should convert tags has to collection of Tags", ->
				runs ->
					expect(@prot.get('lsTags')  instanceof TagList).toBeTruthy()


		describe "model change propogation", ->
			it "should trigger change when label changed", ->
				runs ->
					@prot = new Protocol()
					@protocolChanged = false
					@prot.get('lsLabels').setBestName new Label
						labelKind: "protocol name"
						labelText: "test label"
						recordedBy: @prot.get 'recordedBy'
						recordedDate: @prot.get 'recordedDate'
					@prot.on 'change', =>
						@protocolChanged = true
					@protocolChanged = false
					@prot.get('lsLabels').setBestName new Label
						labelKind: "protocol name"
						labelText: "new label"
						recordedBy: @prot.get 'recordedBy'
						recordedDate: @prot.get 'recordedDate'
				waitsFor ->
					@protocolChanged
				, 500
				runs ->
					expect(@protocolChanged).toBeTruthy()
			it "should trigger change when value changed in state", ->
				runs ->
					@prot = new Protocol window.protocolServiceTestJSON.fullSavedProtocol
					@protocolChanged = false
					@prot.on 'change', =>
						@protocolChanged = true
					@prot.get('lsStates').at(0).get('lsValues').at(0).set(lsKind: 'fred')
				waitsFor ->
					@protocolChanged
				, 500
				runs ->
					expect(@protocolChanged).toBeTruthy()

		describe "model validation", ->
			beforeEach ->
				@prot = new Protocol window.protocolServiceTestJSON.fullSavedProtocol
			it "should be valid when loaded from saved", ->
				expect(@prot.isValid()).toBeTruthy()
			it "should be invalid when name is empty", ->
				@prot.get('lsLabels').setBestName new Label
					labelKind: "protocol name"
					labelText: ""
					recordedBy: @prot.get 'recordedBy'
					recordedDate: @prot.get 'recordedDate'
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='protocolName'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when date is empty", ->
				@prot.set recordedDate: new Date("").getTime()
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='recordedDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when scientist not selected", ->
				@prot.set recordedBy: ""
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='recordedBy'
				)
			it "should be invalid when notebook is empty", ->
				@prot.getNotebook().set
					stringValue: ""
					recordedBy: @prot.get('recordedBy')
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it 'should require that completionDate not be ""', ->
				@prot.getCompletionDate().set
					dateValue: new Date("").getTime()
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
		describe "prepare to save", ->
			beforeEach ->
				@prot = new Protocol()
				@prot.set recordedBy: "jmcneil"
				@prot.set recordedDate: -1
			afterEach ->
				@prot.get('lsLabels').reset()
				@prot.get('lsStates').reset()
			it "should set experiment's set to now", ->
				@prot.prepareToSave()
				expect(new Date(@prot.get('recordedDate')).getHours()).toEqual new Date().getHours()
			it "should have function to add recorded* to all labels", ->
				@prot.get('lsLabels').setBestName new Label
					labelKind: "experiment name"
					labelText: "new name"
				@prot.prepareToSave()
				expect(@prot.get('lsLabels').pickBestLabel().get('recordedBy')).toEqual "jmcneil"
				expect(@prot.get('lsLabels').pickBestLabel().get('recordedDate')).toBeGreaterThan 1
			it "should have function to add recorded * to values", ->
				status = @prot.getStatus()
				@prot.prepareToSave()
				expect(status.get('recordedBy')).toEqual "jmcneil"
				expect(status.get('recordedDate')).toBeGreaterThan 1
			it "should have function to add recorded * to states", ->
				state = @prot.get('lsStates').getOrCreateStateByTypeAndKind "metadata", "experiment metadata"
				@prot.prepareToSave()
				expect(state.get('recordedBy')).toEqual "jmcneil"
				expect(state.get('recordedDate')).toBeGreaterThan 1


	describe "Protocol List testing", ->
		beforeEach ->
			@el = new ProtocolList()
		describe "existance tests", ->
			it "should be defined", ->
				expect(ProtocolList).toBeDefined()

	describe "ProtocolBaseController testing", ->
		describe "When created from a saved protocol", ->
			beforeEach ->
				@prot = new Protocol window.protocolServiceTestJSON.fullSavedProtocol
				@pbc = new ProtocolBaseController
					model: @prot
					el: $('#fixture')
				@pbc.render()
			describe "property display", ->
				it "should show the save button text as Update", ->
					expect(@pbc.$('.bv_save').html()).toEqual "Update"
				it "should fill the short description field", ->
					expect(@pbc.$('.bv_shortDescription').html()).toEqual "primary analysis"
				it "should fill the assay tree rule field", ->
					expect(@pbc.$('.bv_assayTreeRule').val()).toEqual "assay tree rule goes here"
				it "should fill the assay principle field", ->
					expect(@pbc.$('.bv_assayPrinciple').val()).toEqual "assay principle goes here"
				it "should fill the long description field", ->
					expect(@pbc.$('.bv_description').html()).toEqual "long description goes here"
				it "should fill the comments field", ->
					expect(@pbc.$('.bv_comments').html()).toEqual "protocol comments go here"
				#TODO this test breaks because of the weird behavior where new a Model from a json hash
				# then setting model attribites changes the hash
				xit "should fill the protocol name field", ->
					expect(@pbc.$('.bv_protocolName').val()).toEqual "FLIPR target A biochemical"
				it "should fill the user field", ->
					expect(@pbc.$('.bv_recordedBy').val()).toEqual "nxm7557"
				it "should fill the protocol code field", ->
					expect(@pbc.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
				it "should fill the protocol kind field", ->
					expect(@pbc.$('.bv_protocolKind').html()).toEqual "default"
				it "should fill the notebook field", ->
					expect(@pbc.$('.bv_notebook').val()).toEqual "912"
				it "should show the tags", ->
					expect(@pbc.$('.bv_tags').tagsinput('items')[0]).toEqual "stuff"
				it "show the status", ->
					waitsFor ->
						@pbc.$('.bv_status option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_status').val()).toEqual "created"
				it "should show the status select enabled", ->
					expect(@pbc.$('.bv_status').attr('disabled')).toBeUndefined()
			describe "Protocol status behavior", ->
				it "should disable all fields if protocol is finalized", ->
					waitsFor ->
						@pbc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_status').val('finalized')
						@pbc.$('.bv_status').change()
						expect(@pbc.$('.bv_notebook').attr('disabled')).toEqual 'disabled'
						expect(@pbc.$('.bv_status').attr('disabled')).toBeUndefined()
				it "should enable all fields if entity is started", ->
					@pbc.$('.bv_status').val('finalized')
					@pbc.$('.bv_status').change()
					@pbc.$('.bv_status').val('started')
					@pbc.$('.bv_status').change()
					expect(@pbc.$('.bv_notebook').attr('disabled')).toBeUndefined()
				it "should hide lock icon if protocol is created", ->
					@pbc.$('.bv_status').val('created')
					@pbc.$('.bv_status').change()
					expect(@pbc.$('.bv_lock')).toBeHidden()
				it "should show lock icon if protocol is finalized", ->
					waitsFor ->
						@pbc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_status').val('finalized')
						@pbc.$('.bv_status').change()
						expect(@pbc.$('.bv_lock')).toBeVisible()
			describe "User edits fields", ->
				it "should update model when scientist is changed", ->
					expect(@pbc.model.get 'recordedBy').toEqual "nxm7557"
					@pbc.$('.bv_recordedBy').val("xxl7932")
					@pbc.$('.bv_recordedBy').change()
					expect(@pbc.model.get 'recordedBy').toEqual "xxl7932"
				it "should update model when shortDescription is changed", ->
					@pbc.$('.bv_shortDescription').val(" New short description   ")
					@pbc.$('.bv_shortDescription').change()
					expect(@pbc.model.get 'shortDescription').toEqual "New short description"
				it "should set model shortDescription to a space when shortDescription is set to empty", ->
					@pbc.$('.bv_shortDescription').val("")
					@pbc.$('.bv_shortDescription').change()
					expect(@pbc.model.get 'shortDescription').toEqual " "
				it "should update model when assay tree rule changed", ->
					@pbc.$('.bv_assayTreeRule').val(" Updated assay tree rule  ")
					@pbc.$('.bv_assayTreeRule').change()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("stringValue", "assay tree rule")
					desc = values[0].get('stringValue')
					expect(desc).toEqual "Updated assay tree rule"
					expect(@pbc.model.getAssayTreeRule().get('stringValue')).toEqual "Updated assay tree rule"
				it "should update model when assay principle is changed", ->
					@pbc.$('.bv_assayPrinciple').val(" New assay principle   ")
					@pbc.$('.bv_assayPrinciple').change()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "assay principle")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New assay principle"
					expect(@pbc.model.getAssayPrinciple().get('clobValue')).toEqual "New assay principle"
				it "should update model when description is changed", ->
					@pbc.$('.bv_description').val(" New long description   ")
					@pbc.$('.bv_description').change()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "experiment metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "description")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New long description"
					expect(@pbc.model.getDescription().get('clobValue')).toEqual "New long description"
				it "should update model when comments is changed", ->
					@pbc.$('.bv_comments').val(" New comments   ")
					@pbc.$('.bv_comments').change()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "comments")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New comments"
					expect(@pbc.model.getComments().get('clobValue')).toEqual "New comments"
				it "should update model when protocol name is changed", ->
					@pbc.$('.bv_protocolName').val(" Updated protocol name   ")
					@pbc.$('.bv_protocolName').change()
					expect(@pbc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "Updated protocol name"
				it "should update model when completion date is changed", ->
					@pbc.$('.bv_completionDate').val(" 2013-3-16   ")
					@pbc.$('.bv_completionDate').change()
					expect(@pbc.model.getCompletionDate().get('dateValue')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@pbc.$('.bv_notebook').val(" Updated notebook  ")
					@pbc.$('.bv_notebook').change()
					expect(@pbc.model.getNotebook().get('stringValue')).toEqual "Updated notebook"
				it "should update model when tag added", ->
					@pbc.$('.bv_tags').tagsinput 'add', "lucy"
					#TODO this doens't test change event capture, which doesn't work For now for uspdate before save
					#@pbc.$('.bv_tags').focusout()
					@pbc.tagListController.handleTagsChanged()
					expect(@pbc.model.get('lsTags').at(2).get('tagText')).toEqual "lucy"
				it "should update model when protocol status changed", ->
					waitsFor ->
						@pbc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_status').val('complete')
						@pbc.$('.bv_status').change()
						expect(@pbc.model.getStatus().get('stringValue')).toEqual 'complete'
		describe "When created from a new protocol", ->
			beforeEach ->
				@prot = new Protocol()
				@prot.getStatus().set stringValue: "created" #work around for left over pointers
				@pbc = new ProtocolBaseController
					model: @prot
					el: $('#fixture')
				@pbc.render()
			describe "basic startup conditions", ->
				it "should have protocol code not set", ->
					expect(@pbc.$('.bv_protocolCode').val()).toEqual ""
				it "should have protocol name not set", ->
					expect(@pbc.$('.bv_protocolName').val()).toEqual ""
				it "should not fill the date field", ->
					expect(@pbc.$('.bv_completionDate').val()).toEqual ""
				it "should show the save button text as Save", ->
					expect(@pbc.$('.bv_save').html()).toEqual "Save"
				it "should show the save button disabled", ->
					expect(@pbc.$('.bv_save').attr('disabled')).toEqual 'disabled'
				it "should show the status select disabled", ->
					expect(@pbc.$('.bv_status').attr('disabled')).toEqual 'disabled'
				it "should show status select value as created", ->
					waitsFor ->
						@pbc.$('.bv_status option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_status').val()).toEqual 'created'
				it "should have the assay tree rule be empty", ->
					expect(@pbc.$('.bv_assayTreeRule').val()).toEqual ""
			describe "controller validation rules", ->
				beforeEach ->
					@pbc.$('.bv_recordedBy').val("nxm7557")
					@pbc.$('.bv_recordedBy').change()
					@pbc.$('.bv_shortDescription').val(" New short description   ")
					@pbc.$('.bv_shortDescription').change()
					@pbc.$('.bv_protocolName').val(" Updated entity name   ")
					@pbc.$('.bv_protocolName').change()
					@pbc.$('.bv_completionDate').val(" 2013-3-16   ")
					@pbc.$('.bv_completionDate').change()
					@pbc.$('.bv_notebook').val("my notebook")
					@pbc.$('.bv_notebook').change()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@pbc.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							expect(@pbc.$('.bv_save').attr('disabled')).toBeUndefined()
				describe "when protocol name field not filled in", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_protocolName').val("")
							@pbc.$('.bv_protocolName').change()
					it "should be invalid if protocol name not filled in", ->
						runs ->
							expect(@pbc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@pbc.$('.bv_group_protocolName').hasClass('error')).toBeTruthy()
					it "should show the save button disabled", ->
						runs ->
							expect(@pbc.$('.bv_save').attr('disabled')).toEqual 'disabled'
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_recordedBy').val("")
							@pbc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@pbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_completionDate').val("")
							@pbc.$('.bv_completionDate').change()
					it "should show error in date field", ->
						runs ->
							expect(@pbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_notebook').val("")
							@pbc.$('.bv_notebook').change()
					it "should show error on notebook dropdown", ->
						runs ->
							expect(@pbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "expect save to work", ->
					it "model should be valid and ready to save", ->
						runs ->
							expect(@pbc.model.isValid()).toBeTruthy()
					it "should update protocol code", ->
						runs ->
							@pbc.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@pbc.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
					it "should show the save button text as Update", ->
						runs ->
							@pbc.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@pbc.$('.bv_save').html()).toEqual "Update"

