beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)


describe "Base Entity testing", ->
	describe "Base entity model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@bem = new BaseEntity()
			describe "Defaults", ->
				it 'Should have a subclass default to entity', ->
					expect(@bem.get("subclass")).toEqual "entity"
				it 'Should have default type and kind', ->
					expect(@bem.get('lsType')).toEqual "default"
					expect(@bem.get('lsKind')).toEqual "default"
				it 'Should have an empty label list', ->
					expect(@bem.get('lsLabels').length).toEqual 0
					expect(@bem.get('lsLabels') instanceof LabelList).toBeTruthy()
				it 'Should have an empty tags list', ->
					expect(@bem.get('lsTags').length).toEqual 0
					expect(@bem.get('lsTags') instanceof Backbone.Collection).toBeTruthy()
				it 'Should have an empty state list', ->
					expect(@bem.get('lsStates').length).toEqual 0
					expect(@bem.get('lsStates') instanceof StateList).toBeTruthy()
				it 'Should have an empty scientist', ->
					expect(@bem.getScientist().get('codeValue')).toEqual window.AppLaunchParams.loginUserName
					expect(@bem.getScientist().get('codeType')).toEqual "assay"
					expect(@bem.getScientist().get('codeKind')).toEqual "scientist"
					expect(@bem.getScientist().get('codeOrigin')).toEqual "ACAS authors"
				it 'Should have the recordedBy set to the loginUser username', ->
					expect(@bem.get('recordedBy')).toEqual "jmcneil"
				it 'Should have an recordedDate set to now', ->
					expect(new Date(@bem.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it 'Should have an empty short description with a space as an oracle work-around', ->
					expect(@bem.get('shortDescription')).toEqual " "
			describe "required states and values", ->
				it 'Should have a entity details value', ->
					expect(@bem.getDetails() instanceof Value).toBeTruthy()
					expect(@bem.getDetails().get('clobValue')).toEqual ""
				it 'Should have a comments value', ->
					expect(@bem.getComments() instanceof Value).toBeTruthy()
					expect(@bem.getComments().get('clobValue')).toEqual ""
				it 'Should have a notebook value', ->
					expect(@bem.getNotebook() instanceof Value).toBeTruthy()
				it 'Entity status should default to created and should have default code type, kind, and origin', ->
					expect(@bem.getStatus().get('codeValue')).toEqual "created"
					expect(@bem.getStatus().get('codeType')).toEqual "entity"
					expect(@bem.getStatus().get('codeKind')).toEqual "status"
					expect(@bem.getStatus().get('codeOrigin')).toEqual "ACAS DDICT"
			describe "other features", ->
				describe "should tell you if it is editable based on status", ->
					it "should be locked if status is created", ->
						@bem.getStatus().set codeValue: "created"
						expect(@bem.isEditable()).toBeTruthy()
					it "should be locked if status is started", ->
						@bem.getStatus().set codeValue: "started"
						expect(@bem.isEditable()).toBeTruthy()
					it "should be locked if status is complete", ->
						@bem.getStatus().set codeValue: "complete"
						expect(@bem.isEditable()).toBeTruthy()
					it "should be locked if status is approved", ->
						@bem.getStatus().set codeValue: "approved"
						expect(@bem.isEditable()).toBeFalsy()
					it "should be locked if status is rejected", ->
						@bem.getStatus().set codeValue: "rejected"
						expect(@bem.isEditable()).toBeFalsy()

		describe "when loaded from existing", ->
			beforeEach ->
				@bem = new BaseEntity window.baseEntityServiceTestJSON.savedExperimentWithAnalysisGroups
#				@bem.set urlRoot: "/api/experiments"
				@bem.set subclass: "experiment"
			describe "after initial load", ->
				it "should have a kind", ->
					expect(@bem.get('lsKind')).toEqual "ACAS doc for batches" # changed from get kind to get lsKind
				it "should have a code ", ->
					expect(@bem.get('codeName')).toEqual "EXPT-00000222"
				it "should have the shortDescription set", ->
					expect(@bem.get('shortDescription')).toEqual window.baseEntityServiceTestJSON.savedExperimentWithAnalysisGroups.shortDescription
				it "should have labels", ->
					expect(@bem.get('lsLabels').length).toEqual window.baseEntityServiceTestJSON.savedExperimentWithAnalysisGroups.lsLabels.length
				it "should have labels", ->
					expect(@bem.get('lsLabels').at(0).get('lsKind')).toEqual "experiment name"
				it 'Should have a entity details value', ->
					expect(@bem.getDetails().get('clobValue')).toEqual "experiment details go here"
				it 'Should have a notebook value', ->
					expect(@bem.getNotebook().get('stringValue')).toEqual "911"
				it 'Should have a status value', ->
					expect(@bem.getStatus().get('codeValue')).toEqual "started"
		describe "model change propogation", ->
			it "should triggprier change when label changed", ->
				runs ->
					@bem = new BaseEntity()
					@baseEntityChanged = false
					@bem.get('lsLabels').setBestName new Label
						labelKind: "experiment name"
						labelText: "test label"
						recordedBy: @bem.get 'recordedBy'
						recordedDate: @bem.get 'recordedDate'
					@bem.on 'change', =>
						@baseEntityChanged = true
					@baseEntityChanged = false
					@bem.get('lsLabels').setBestName new Label
						labelKind: "experiment name"
						labelText: "new label"
						recordedBy: @bem.get 'recordedBy'
						recordedDate: @bem.get 'recordedDate'
				waitsFor ->
					@baseEntityChanged
				, 500
				runs ->
					expect(@baseEntityChanged).toBeTruthy()
			it "should trigger change when value changed in state", ->
				runs ->
					@bem = new BaseEntity window.baseEntityServiceTestJSON.fullExperimentFromServer
					@bemerimentChanged = false
					@bem.on 'change', =>
						@baseEntityChanged = true
					@bem.get('lsStates').at(0).get('lsValues').at(0).set(codeValue: 'fred')
				waitsFor ->
					@baseEntityChanged
				, 500
				runs ->
					expect(@baseEntityChanged).toBeTruthy()

		describe "model validation", ->
			beforeEach ->
				@bem = new BaseEntity window.baseEntityServiceTestJSON.fullExperimentFromServer
#				@bem.set urlRoot: "/api/experiments"
				@bem.set subclass: "experiment"
			it "should be valid when loaded from saved", ->
				expect(@bem.isValid()).toBeTruthy()
			it "should be invalid when name is empty", ->
				@bem.get('lsLabels').setBestName new Label
					labelKind: "experiment name"
					labelText: ""
					recordedBy: @bem.get 'recordedBy'
					recordedDate: @bem.get 'recordedDate'
				expect(@bem.isValid()).toBeFalsy()
				filtErrors = _.filter(@bem.validationError, (err) ->
					err.attribute=='experimentName'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when date is empty", ->
				@bem.set recordedDate: new Date("").getTime()
				expect(@bem.isValid()).toBeFalsy()
				filtErrors = _.filter(@bem.validationError, (err) ->
					err.attribute=='recordedDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when scientist not selected", ->
				@bem.getScientist().set codeValue: "unassigned"
				expect(@bem.isValid()).toBeFalsy()
				filtErrors = _.filter(@bem.validationError, (err) ->
					err.attribute=='scientist'
				)
			it "should be invalid when notebook is empty", ->
				@bem.getNotebook().set
					stringValue: ""
				expect(@bem.isValid()).toBeFalsy()
				filtErrors = _.filter(@bem.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
		describe "prepare to save", ->
			beforeEach ->
				@bem = new BaseEntity()
#				@bem.set urlRoot: "/api/experiments"
				@bem.set subclass: "experiment"
				@bem.set recordedBy: "jmcneil"
				@bem.set recordedDate: -1
			afterEach ->
				@bem.get('lsLabels').reset()
				@bem.get('lsStates').reset()
			it "should set experiment's set to now", ->
				@bem.prepareToSave()
				expect(new Date(@bem.get('recordedDate')).getHours()).toEqual new Date().getHours()
			it "should have function to add recorded* to all labels", ->
				@bem.get('lsLabels').setBestName new Label
					labelKind: "experiment name"
					labelText: "new name"
				@bem.prepareToSave()
				expect(@bem.get('lsLabels').pickBestLabel().get('recordedBy')).toEqual "jmcneil"
				expect(@bem.get('lsLabels').pickBestLabel().get('recordedDate')).toBeGreaterThan 1
			it "should have function to add recorded * to values", ->
				status = @bem.getStatus()
				@bem.prepareToSave()
				expect(status.get('recordedBy')).toEqual "jmcneil"
				expect(status.get('recordedDate')).toBeGreaterThan 1
			it "should have function to add recorded * to states", ->
				state = @bem.get('lsStates').getOrCreateStateByTypeAndKind "metadata", "experiment metadata"
				@bem.prepareToSave()
				expect(state.get('recordedBy')).toEqual "jmcneil"
				expect(state.get('recordedDate')).toBeGreaterThan 1

		describe "model composite component conversion", ->
			beforeEach ->
				runs ->
					@saveSucessful = false
					@saveComplete = false
					@bem = new BaseEntity id: 1
					@bem.on 'sync', =>
						@saveSucessful = true
						@saveComplete = true
					@bem.on 'invalid', =>
						@saveComplete = true
					@bem.fetch()
				waitsFor ->
					@saveComplete == true
				, 500
			it "should return from sync, not invalid", ->
				runs ->
					expect(@saveSucessful).toBeTruthy()
			it "should convert labels array to label list", ->
				runs ->
					expect(@bem.get('lsLabels')  instanceof LabelList).toBeTruthy()
#					expect(@bem.get('lsLabels').length).toBeGreaterThan 0
			it "should convert state array to state list", ->
				runs ->
					expect(@bem.get('lsStates')  instanceof StateList).toBeTruthy()
					expect(@bem.get('lsStates').length).toBeGreaterThan 0
			it "should convert tags has to collection of Tags", ->
				runs ->
					expect(@bem.get('lsTags')  instanceof TagList).toBeTruthy()

		describe "duplicated entity", ->
			beforeEach ->
				@bem = new BaseEntity window.baseEntityServiceTestJSON.fullExperimentFromServer
				#				@bem.set urlRoot: "/api/experiments"
				@bem.set subclass: "experiment"
				@copiedEntity = @bem.duplicateEntity(@bem)
			it "should have the same lsType as the original entity", ->
				expect(@copiedEntity.get('lsType')).toEqual @bem.get('lsType')
			it "should have the same lsKind as the original entity", ->
				expect(@copiedEntity.get('lsType')).toEqual @bem.get('lsKind')
			it "should have the status set to created", ->
				expect(@copiedEntity.getStatus().get('codeValue')).toEqual "created"
			it "should have the code name be undefined", ->
				expect(@copiedEntity.get('codeName')).toBeUndefined()
			it "should have the entity name be empty", ->
				expect(@copiedEntity.get('lsLabels').length).toEqual 0
				expect(@copiedEntity.get('lsLabels') instanceof LabelList).toBeTruthy()
			it "should have the scientist be unassigned", ->
				expect(@copiedEntity.getScientist().get('codeValue')).toEqual "unassigned"
			it "should have the recordedBy be jmcneil", ->
				expect(@copiedEntity.get('recordedBy')).toEqual "jmcneil"
			it "should have the recorded date be set to now", ->
				expect(new Date(@copiedEntity.get('recordedDate')).getHours()).toEqual new Date().getHours()
			it "should have the protocol be duplicated when the entity is an experiment", ->
				expect(@copiedEntity.get('protocol')).toEqual @bem.get('protocol')
			xit "should have the same project as the original entity", ->
				expect(@copiedEntity.getProjectCode()).toEqual @bem.getProjectCode()
			it "should have the notebook be empty", ->
				expect(@copiedEntity.getNotebook().get('stringValue')).toEqual ""
			it "should have the same lsTags", ->
				expect(@copiedEntity.get('lsTags')).toEqual @bem.get('lsTags')
			it "should have the same short description", ->
				expect(@copiedEntity.get('shortDescription')).toEqual @bem.get('shortDescription')
			it "should have the same description", ->
				expect(@copiedEntity.getDetails().get('clobValue')).toEqual @bem.getDetails().get('clobValue')
			it "should have the same comments", ->
				expect(@copiedEntity.getComments().get('clobValue')).toEqual @bem.getComments().get('clobValue')

	describe "Base Entity List testing", ->
		beforeEach ->
			@el = new BaseEntityList()
		describe "existance tests", ->
			it "should be defined", ->
				expect(BaseEntityList).toBeDefined()

	describe "BaseEntityController testing", ->
		describe "When created from a saved entity", ->
			beforeEach ->
				@bem = new BaseEntity window.experimentServiceTestJSON.fullExperimentFromServer
#				@bem.set urlRoot: "/api/experiments"
				@bem.set subclass: "experiment"
				@bec = new BaseEntityController
					model: @bem
					el: $('#fixture')
				@bec.render()
			describe "property display", ->
				it "should show the save button text as Update", ->
					expect(@bec.$('.bv_save').html()).toEqual "Update"
				it "should show the create new entity button", ->
					expect(@bec.$('.bv_newEntity')).toBeVisible()
				it "should have the cancel button be disabled", ->
					expect(@bec.$('.bv_newEntity')).toBeVisible()
				it "should fill the short description field", ->
					expect(@bec.$('.bv_shortDescription').html()).toEqual "experiment created by generic data parser"
				xit "should fill the entity details field", ->
					#test breaks because subclass was set to experiment instead of entity
					expect(@bec.$('.bv_details').html()).toEqual "experiment details goes here"
				it "should fill the comments field", ->
					expect(@bec.$('.bv_comments').val()).toEqual "comments go here"
				#TODO this test breaks because of the weird behavior where new a Model from a json hash
				# then setting model attribites changes the hash
				xit "should fill the entity name field", ->
					expect(@bec.$('.bv_entityName').val()).toEqual "FLIPR target A biochemical"
				it "should fill the scientist field", ->
					waitsFor ->
						@bec.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						expect(@bec.$('.bv_scientist').val()).toEqual "jane"
				it "should fill the entity code field", ->
					@bem.set subclass: "entity" # work around for the spec to pass. In a subclass, the dom element would be .bv_[subclass]Code not .bv_entityCode
					@bec.render()
					expect(@bec.$('.bv_entityCode').html()).toEqual "EXPT-00000001"
				it "should fill the entity kind field", ->
					@bem.set subclass: "entity" # work around for the spec to pass. In a subclass, the dom element would be .bv_[subclass]Kind not .bv_entityKind
					@bec.render()
					expect(@bec.$('.bv_entityKind').html()).toEqual "default"
				it "should fill the notebook field", ->
					expect(@bec.$('.bv_notebook').val()).toEqual "911"
				it "should show the tags", ->
					expect(@bec.$('.bv_tags').tagsinput('items')[0]).toEqual "stuff"
				it "show the status", ->
					waitsFor ->
						@bec.$('.bv_status option').length > 0
					, 1000
					runs ->
						expect(@bec.$('.bv_status').val()).toEqual "started"
				it "should show the status select enabled", ->
					expect(@bec.$('.bv_status').attr('disabled')).toBeUndefined()
			describe "Entity status behavior", ->
				it "should disable all fields if entity is approved", ->
					waitsFor ->
						@bec.$('.bv_status option').length > 0
					, 1000
					runs ->
						@bec.$('.bv_status').val('approved')
						@bec.$('.bv_status').change()
						expect(@bec.$('.bv_notebook').attr('disabled')).toEqual 'disabled'
						expect(@bec.$('.bv_status').attr('disabled')).toBeUndefined()
				it "should enable all fields if entity is started", ->
					@bec.$('.bv_status').val('approved')
					@bec.$('.bv_status').change()
					@bec.$('.bv_status').val('started')
					@bec.$('.bv_status').change()
					expect(@bec.$('.bv_notebook').attr('disabled')).toBeUndefined()
				it "should hide lock icon if entity is created", ->
					@bec.$('.bv_status').val('created')
					@bec.$('.bv_status').change()
					expect(@bec.$('.bv_lock')).toBeHidden()
				it "should show lock icon if entity is approved", ->
					waitsFor ->
						@bec.$('.bv_status option').length > 0
					, 1000
					runs ->
						@bec.$('.bv_status').val('approved')
						@bec.$('.bv_status').change()
						expect(@bec.$('.bv_lock')).toBeVisible()
			describe "User edits fields", ->
				it "should enable the cancel button", ->
					@bec.model.trigger 'change'
					expect(@bec.$('.bv_cancel').attr('disabled')).toBeUndefined()
				it "should update model when scientist is changed", ->
					expect(@bec.model.getScientist().get('codeValue')).toEqual "jane"
					waitsFor ->
						@bec.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@bec.$('.bv_scientist').val('unassigned')
						@bec.$('.bv_scientist').change()
						expect(@bec.model.getScientist().get('codeValue')).toEqual "unassigned"
				it "should update model when shortDescription is changed", ->
					@bec.$('.bv_shortDescription').val(" New short description   ")
					@bec.$('.bv_shortDescription').keyup()
					expect(@bec.model.get 'shortDescription').toEqual "New short description"
				it "should set model shortDescription to a space when shortDescription is set to empty", ->
					@bec.$('.bv_shortDescription').val("")
					@bec.$('.bv_shortDescription').keyup()
					expect(@bec.model.get 'shortDescription').toEqual " "
				xit "should update model when entity details is changed", ->
					#test breaks because subclass is set to experiment
					@bec.$('.bv_details').val(" New experiment details   ")
					@bec.$('.bv_details').keyup()
					states = @bec.model.get('lsStates').getStatesByTypeAndKind "metadata", "experiment metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "experiment details")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New experiment details"
					expect(@bec.model.getDetails().get('clobValue')).toEqual "New experiment details"
				it "should update model when comments is changed", ->
					@bec.$('.bv_comments').val(" New comments   ")
					@bec.$('.bv_comments').keyup()
					states = @bec.model.get('lsStates').getStatesByTypeAndKind "metadata", "experiment metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "comments")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New comments"
					expect(@bec.model.getComments().get('clobValue')).toEqual "New comments"
				it "should update model when entity name is changed", ->
					@bem.set subclass: "entity" # work around for the spec to pass. In a subclass, the dom element would be .bv_[subclass]Name not .bv_entityName
					@bec.render()
					@bec.$('.bv_entityName').val(" Updated entity name   ")
					@bec.$('.bv_entityName').keyup()
					expect(@bec.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "Updated entity name"
				it "should update model when notebook is changed", ->
					@bec.$('.bv_notebook').val(" Updated notebook  ")
					@bec.$('.bv_notebook').keyup()
					expect(@bec.model.getNotebook().get('stringValue')).toEqual "Updated notebook"
				it "should update model when tag added", ->
					@bec.$('.bv_tags').tagsinput 'add', "lucy"
					#TODO this doens't test change event capture, which doesn't work For now for uspdate before save
					#@bec.$('.bv_tags').focusout()
					@bec.tagListController.handleTagsChanged()
					expect(@bec.model.get('lsTags').at(2).get('tagText')).toEqual "lucy"
				it "should update model when entity status changed", ->
					waitsFor ->
						@bec.$('.bv_status option').length > 0
					, 1000
					runs ->
						@bec.$('.bv_status').val('complete')
						@bec.$('.bv_status').change()
						expect(@bec.model.getStatus().get('codeValue')).toEqual 'complete'


		describe "When created from a new entity", ->
			beforeEach ->
				@bem = new BaseEntity()
				@bem.getStatus().set codeValue: "created" #work around for left over pointers
				@bec = new BaseEntityController
					model: @bem
					el: $('#fixture')
				@bec.render()
			describe "basic startup conditions", ->
				it "should have entity code not set", ->
					expect(@bec.$('.bv_entityCode').val()).toEqual ""
				it "should have entity name not set", ->
					expect(@bec.$('.bv_entityName').val()).toEqual ""
				it "should show the save button text as Save", ->
					expect(@bec.$('.bv_save').html()).toEqual "Save"
				it "should show the save button disabled", ->
					expect(@bec.$('.bv_save').attr('disabled')).toEqual 'disabled'
				it "should hide the create new entity button", ->
					expect(@bec.$('.bv_newEntity')).toBeHidden()
				it "should have the cancel button be disabled", ->
					expect(@bec.$('.bv_cancel').attr('disabled')).toEqual 'disabled'
				it "should show the status select disabled", ->
					expect(@bec.$('.bv_status').attr('disabled')).toEqual 'disabled'
				it "should show status select value as created", ->
					@bem2 = new BaseEntity()
					@bem2.set subclass: 'experiment' #this is required to load experimentStatus options from the dataDict (no dataDict for entityStatus)
					@bem2.getStatus().set codeValue: "created" #work around for left over pointers
					@bec2 = new BaseEntityController
						model: @bem2
						el: $('#fixture')
					@bec.render()
					waitsFor ->
						@bec2.$('.bv_status option').length > 0
					, 1000
					runs ->
						expect(@bec2.$('.bv_status').val()).toEqual 'created'
			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@bec.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@bec.$('.bv_scientist').val("bob")
						@bec.$('.bv_scientist').change()
						@bec.$('.bv_shortDescription').val(" New short description   ")
						@bec.$('.bv_shortDescription').keyup()
						@bec.$('.bv_entityName').val(" Updated entity name   ")
						@bec.$('.bv_entityName').keyup()
						@bec.$('.bv_notebook').val("my notebook")
						@bec.$('.bv_notebook').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@bec.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							console.log @bec.model.validationError
							expect(@bec.$('.bv_save').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@bec.$('.bv_entityName').val("")
							@bec.$('.bv_entityName').keyup()
					it "should be invalid if entity name not filled in", ->
						runs ->
							expect(@bec.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@bec.$('.bv_group_entityName').hasClass('error')).toBeTruthy()
					it "should show the save button disabled", ->
						runs ->
							expect(@bec.$('.bv_save').attr('disabled')).toEqual 'disabled'
				describe "when scientist not selected", ->
					beforeEach ->
						waitsFor ->
							@bec.$('.bv_scientist option').length > 0
						, 1000
						runs ->
							@bec.$('.bv_scientist').val("unassigned")
							@bec.$('.bv_scientist').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@bec.$('.bv_group_scientist').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@bec.$('.bv_notebook').val("")
							@bec.$('.bv_notebook').keyup()
					it "should show error on notebook dropdown", ->
						runs ->
							expect(@bec.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
