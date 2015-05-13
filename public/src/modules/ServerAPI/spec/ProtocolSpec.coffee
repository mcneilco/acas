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
					expect(@prot.getScientist().get('codeValue')).toEqual window.AppLaunchParams.loginUserName
				it 'Should have the recordedBy set to the loginUser username', ->
					expect(@prot.get('recordedBy')).toEqual "jmcneil"
				it 'Should have an recordedDate set to now', ->
					expect(new Date(@prot.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it 'Should have an empty short description with a space as an oracle work-around', ->
					expect(@prot.get('shortDescription')).toEqual " "
			describe "required states and values", ->
				it 'Should have an assay tree rule value', ->
					expect(@prot.getAssayTreeRule() instanceof Value).toBeTruthy()
					expect(@prot.getAssayTreeRule().get('stringValue')).toEqual ""
				it 'Should have an assay stage value', ->
					expect(@prot.getAssayStage() instanceof Value).toBeTruthy()
					expect(@prot.getAssayStage().get('codeValue')).toEqual "unassigned"
					expect(@prot.getAssayStage().get('codeOrigin')).toEqual "ACAS DDICT"
					expect(@prot.getAssayStage().get('codeType')).toEqual "assay"
					expect(@prot.getAssayStage().get('codeKind')).toEqual "stage"
				it 'Should have an assay principle value', ->
					expect(@prot.getAssayPrinciple() instanceof Value).toBeTruthy()
					expect(@prot.getAssayPrinciple().get('clobValue')).toEqual ""
				it 'Should have a protocol details value', ->
					expect(@prot.getDetails() instanceof Value).toBeTruthy()
					expect(@prot.getDetails().get('clobValue')).toEqual ""
				it 'Should have a comments value', ->
					expect(@prot.getComments() instanceof Value).toBeTruthy()
					expect(@prot.getComments().get('clobValue')).toEqual ""
				it 'Should have a notebook value', ->
					expect(@prot.getNotebook() instanceof Value).toBeTruthy()
				it 'Protocol status should default to created ', ->
					expect(@prot.getStatus().get('codeValue')).toEqual "created"
				it 'creationDate should be null ', ->
					expect(@prot.getCreationDate().get('dateValue')).toEqual null
			describe "other features", ->
				describe "should tell you if it is editable based on status", ->
					it "should be locked if status is created", ->
						@prot.getStatus().set codeValue: "created"
						expect(@prot.isEditable()).toBeTruthy()
					it "should be locked if status is started", ->
						@prot.getStatus().set codeValue: "started"
						expect(@prot.isEditable()).toBeTruthy()
					it "should be locked if status is complete", ->
						@prot.getStatus().set codeValue: "complete"
						expect(@prot.isEditable()).toBeTruthy()
					it "should be locked if status is approved", ->
						@prot.getStatus().set codeValue: "approved"
						expect(@prot.isEditable()).toBeFalsy()
					it "should be locked if status is rejected", ->
						@prot.getStatus().set codeValue: "rejected"
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
				it 'Should have a protocol details value', ->
					expect(@prot.getDetails().get('clobValue')).toEqual "protocol details go here"
				it 'Should have a comments value', ->
					expect(@prot.getComments().get('clobValue')).toEqual "protocol comments go here"
				it 'Should have a notebook value', ->
					expect(@prot.getNotebook().get('stringValue')).toEqual "912"
				it 'Should have a creationDate value', ->
					expect(@prot.getCreationDate().get('dateValue')).toEqual 1342080000000
				it 'Should have a status value', ->
					expect(@prot.getStatus().get('codeValue')).toEqual "created"

		describe "when loaded from stub", ->
			beforeEach ->
				@prot = new Protocol window.protocolServiceTestJSON.stubSavedProtocol
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
				@prot.getScientist().set codeValue: "unassigned"
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='scientist'
				)
			it "should be invalid when notebook is empty", ->
				@prot.getNotebook().set
					stringValue: ""
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it 'should require that creationDate not be ""', ->
				@prot.getCreationDate().set
					dateValue: new Date("").getTime()
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='creationDate'
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
				it "should fill the assay tree rule field", ->
					expect(@pbc.$('.bv_assayTreeRule').val()).toEqual "/assayTreeRule"
				it "should fill the assay stage field", ->
					waitsFor ->
						@pbc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_assayStage').val()).toEqual "assay development"
				it "should fill the assay principle field", ->
					expect(@pbc.$('.bv_assayPrinciple').val()).toEqual "assay principle goes here"
				it "should fill the protocol details field", ->
					expect(@pbc.$('.bv_details').val()).toEqual "protocol details go here"
				it "should fill the comments field", ->
					expect(@pbc.$('.bv_comments').val()).toEqual "protocol comments go here"
				#TODO this test breaks because of the weird behavior where new a Model from a json hash
				# then setting model attribites changes the hash
				xit "should fill the protocol name field", ->
					expect(@pbc.$('.bv_protocolName').val()).toEqual "FLIPR target A biochemical"
				it "should fill the scientist field", ->
					waitsFor ->
						@pbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_scientist').val()).toEqual "jane"
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
				it "should disable all fields if protocol is approved", ->
					waitsFor ->
						@pbc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_status').val('approved')
						@pbc.$('.bv_status').change()
						expect(@pbc.$('.bv_notebook').attr('disabled')).toEqual 'disabled'
						expect(@pbc.$('.bv_status').attr('disabled')).toBeUndefined()
				it "should enable all fields if entity is started", ->
					@pbc.$('.bv_status').val('approved')
					@pbc.$('.bv_status').change()
					@pbc.$('.bv_status').val('started')
					@pbc.$('.bv_status').change()
					expect(@pbc.$('.bv_notebook').attr('disabled')).toBeUndefined()
				it "should hide lock icon if protocol is created", ->
					@pbc.$('.bv_status').val('created')
					@pbc.$('.bv_status').change()
					expect(@pbc.$('.bv_lock')).toBeHidden()
				it "should show lock icon if protocol is approved", ->
					waitsFor ->
						@pbc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_status').val('approved')
						@pbc.$('.bv_status').change()
						expect(@pbc.$('.bv_lock')).toBeVisible()
			describe "User edits fields", ->
				it "should update model when scientist is changed", ->
					expect(@pbc.model.getScientist().get('codeValue')).toEqual "jane"
					waitsFor ->
						@pbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_scientist').val('unassigned')
						@pbc.$('.bv_scientist').change()
						expect(@pbc.model.getScientist().get('codeValue')).toEqual "unassigned"
				it "should update model when shortDescription is changed", ->
					@pbc.$('.bv_shortDescription').val(" New short description   ")
					@pbc.$('.bv_shortDescription').keyup()
					expect(@pbc.model.get 'shortDescription').toEqual "New short description"
				it "should set model shortDescription to a space when shortDescription is set to empty", ->
					@pbc.$('.bv_shortDescription').val("")
					@pbc.$('.bv_shortDescription').keyup()
					expect(@pbc.model.get 'shortDescription').toEqual " "
				it "should update model when assay tree rule changed", ->
					@pbc.$('.bv_assayTreeRule').val(" Updated assay tree rule  ")
					@pbc.$('.bv_assayTreeRule').keyup()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("stringValue", "assay tree rule")
					desc = values[0].get('stringValue')
					expect(desc).toEqual "Updated assay tree rule"
					expect(@pbc.model.getAssayTreeRule().get('stringValue')).toEqual "Updated assay tree rule"
				it "should update model when assay stage is changed", ->
					@pbc.$('.bv_assayStage').val("unassigned")
					@pbc.$('.bv_assayStage').change()
					expect(@pbc.model.getAssayStage().get('codeValue')).toEqual "unassigned"
				it "should update model when assay principle is changed", ->
					@pbc.$('.bv_assayPrinciple').val(" New assay principle   ")
					@pbc.$('.bv_assayPrinciple').keyup()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "assay principle")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New assay principle"
					expect(@pbc.model.getAssayPrinciple().get('clobValue')).toEqual "New assay principle"
				it "should update model when protocol details is changed", ->
					@pbc.$('.bv_details').val(" New protocol details   ")
					@pbc.$('.bv_details').keyup()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "protocol details")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New protocol details"
					expect(@pbc.model.getDetails().get('clobValue')).toEqual "New protocol details"
				it "should update model when comments is changed", ->
					@pbc.$('.bv_comments').val(" New comments   ")
					@pbc.$('.bv_comments').keyup()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "comments")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New comments"
					expect(@pbc.model.getComments().get('clobValue')).toEqual "New comments"
				it "should update model when protocol name is changed", ->
					@pbc.$('.bv_protocolName').val(" Updated protocol name   ")
					@pbc.$('.bv_protocolName').keyup()
					expect(@pbc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "Updated protocol name"
				it "should update model when creation date is changed", ->
					@pbc.$('.bv_creationDate').val(" 2013-3-16   ")
					@pbc.$('.bv_creationDate').change()
					expect(@pbc.model.getCreationDate().get('dateValue')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@pbc.$('.bv_notebook').val(" Updated notebook  ")
					@pbc.$('.bv_notebook').keyup()
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
						expect(@pbc.model.getStatus().get('codeValue')).toEqual 'complete'
			describe "cancel button behavior testing", ->
				it "should call a fetch on the model when cancel is clicked", ->
					runs ->
						@pbc.$('.bv_protocolName').val(" Updated protocol name   ")
						@pbc.$('.bv_protocolName').keyup()
						expect(@pbc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "Updated protocol name"
						@pbc.$('.bv_cancel').click()
					waits(1000)
					runs ->
						expect(@pbc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "FLIPR target A biochemical"
			describe "new protocol button behavior testing", ->
				it "should create a new protocol when New Protocol is clicked", ->
					runs ->
						@pbc.$('.bv_newEntity').click()
					waits(1000)
					runs ->
						@pbc.$('.bv_confirmClear').click()
						expect(@pbc.$('.bv_protocolCode').html()).toEqual "autofill when saved"
		describe "When created from a new protocol", ->
			beforeEach ->
				@prot = new Protocol()
				@prot.getStatus().set codeValue: "created" #work around for left over pointers
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
					expect(@pbc.$('.bv_creationDate').val()).toEqual ""
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
				it "should have the assay stage be empty", ->
					waitsFor ->
						@pbc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_assayStage').val()).toEqual "unassigned"
			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@pbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_scientist').val("bob")
						@pbc.$('.bv_scientist').change()
						@pbc.$('.bv_shortDescription').val(" New short description   ")
						@pbc.$('.bv_shortDescription').keyup()
						@pbc.$('.bv_protocolName').val(" Updated entity name   ")
						@pbc.$('.bv_protocolName').keyup()
						@pbc.$('.bv_creationDate').val(" 2013-3-16   ")
						@pbc.$('.bv_creationDate').change()
						@pbc.$('.bv_notebook').val("my notebook")
						@pbc.$('.bv_notebook').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							console.log @pbc.model.validationError
							expect(@pbc.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							expect(@pbc.$('.bv_save').attr('disabled')).toBeUndefined()
				describe "when protocol name field not filled in", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_protocolName').val("")
							@pbc.$('.bv_protocolName').keyup()
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
						waitsFor ->
							@pbc.$('.bv_scientist option').length > 0
						, 1000
						runs ->
							@pbc.$('.bv_scientist').val("unassigned")
							@pbc.$('.bv_scientist').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@pbc.$('.bv_group_scientist').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_creationDate').val("")
							@pbc.$('.bv_creationDate').change()
					it "should show error in date field", ->
						runs ->
							expect(@pbc.$('.bv_group_creationDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_notebook').val("")
							@pbc.$('.bv_notebook').keyup()
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
							console.log @pbc.model.validationError
							expect(@pbc.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
					it "should show the save button text as Update", ->
						runs ->
							console.log @pbc.$('.bv_save')
							@pbc.$('.bv_save').removeAttr('disabled')
							@pbc.$('.bv_save').click()
						waits(1000)
						runs ->
							console.log @pbc.model.validationError
							console.log @pbc.model
							expect(@pbc.$('.bv_save').html()).toEqual "Update"
				describe "cancel button behavior testing", ->
					it "should call a fetch on the model when cancel is clicked", ->
						runs ->
							@pbc.$('.bv_cancel').click()
						waits(1000)
						runs ->
							expect(@pbc.$('.bv_protocolName').val()).toEqual ""
				describe "new protocol button behavior testing", ->
					it "should create a new protocol when New Protocol is clicked", ->
						runs ->
							@pbc.$('.bv_newEntity').click()
						waits(1000)
						runs ->
							@pbc.$('.bv_confirmClear').click()
							expect(@pbc.$('.bv_protocolName').val()).toEqual ""

