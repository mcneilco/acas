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
					expect(@bem.get('recordedBy')).toEqual ""
				it 'Should have an recordedDate set to now', ->
					expect(new Date(@bem.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it 'Should have an empty short description with a space as an oracle work-around', ->
					expect(@bem.get('shortDescription')).toEqual " "
			describe "required states and values", ->
				it 'Should have a description value', -> # description will be Protocol Details or experimentDetails
					expect(@bem.getDescription() instanceof Value).toBeTruthy()
					expect(@bem.getDescription().get('clobValue')).toEqual ""
				it 'Should have a notebook value', ->
					expect(@bem.getNotebook() instanceof Value).toBeTruthy()
				it 'Entity status should default to created ', ->
					expect(@bem.getStatus().get('stringValue')).toEqual "created"
			describe "other features", ->
				describe "should tell you if it is editable based on status", ->
					it "should be locked if status is created", ->
						@bem.getStatus().set stringValue: "created"
						expect(@bem.isEditable()).toBeTruthy()
					it "should be locked if status is started", ->
						@bem.getStatus().set stringValue: "started"
						expect(@bem.isEditable()).toBeTruthy()
					it "should be locked if status is complete", ->
						@bem.getStatus().set stringValue: "complete"
						expect(@bem.isEditable()).toBeTruthy()
					it "should be locked if status is finalized", ->
						@bem.getStatus().set stringValue: "finalized"
						expect(@bem.isEditable()).toBeFalsy()
					it "should be locked if status is rejected", ->
						@bem.getStatus().set stringValue: "rejected"
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
				it 'Should have a description value', ->
					expect(@bem.getDescription().get('clobValue')).toEqual "long description goes here"
				it 'Should have a notebook value', ->
					expect(@bem.getNotebook().get('stringValue')).toEqual "911"
				it 'Should have a status value', ->
					expect(@bem.getStatus().get('stringValue')).toEqual "started"
					
		describe "model change propogation", ->
			it "should trigger change when label changed", ->
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
				@bem.set recordedBy: ""
				expect(@bem.isValid()).toBeFalsy()
				filtErrors = _.filter(@bem.validationError, (err) ->
					err.attribute=='recordedBy'
				)
			it "should be invalid when notebook is empty", ->
				@bem.getNotebook().set
					stringValue: ""
					recordedBy: @bem.get('recordedBy')
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
				it "should fill the short description field", ->
					expect(@bec.$('.bv_shortDescription').html()).toEqual "experiment created by generic data parser"
				it "should fill the long description field", ->
					expect(@bec.$('.bv_description').html()).toEqual "long description goes here"
				#TODO this test breaks because of the weird behavior where new a Model from a json hash
				# then setting model attribites changes the hash
				xit "should fill the entity name field", ->
					expect(@bec.$('.bv_entityName').val()).toEqual "FLIPR target A biochemical"
				it "should fill the user field", ->
					expect(@bec.$('.bv_recordedBy').val()).toEqual "nxm7557"
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
				it "should disable all fields if entity is finalized", ->
					waitsFor ->
						@bec.$('.bv_status option').length > 0
					, 1000
					runs ->
						@bec.$('.bv_status').val('finalized')
						@bec.$('.bv_status').change()
						expect(@bec.$('.bv_notebook').attr('disabled')).toEqual 'disabled'
						expect(@bec.$('.bv_status').attr('disabled')).toBeUndefined()
				it "should enable all fields if entity is started", ->
					@bec.$('.bv_status').val('finalized')
					@bec.$('.bv_status').change()
					@bec.$('.bv_status').val('started')
					@bec.$('.bv_status').change()
					expect(@bec.$('.bv_notebook').attr('disabled')).toBeUndefined()
				it "should hide lock icon if entity is created", ->
					@bec.$('.bv_status').val('created')
					@bec.$('.bv_status').change()
					expect(@bec.$('.bv_lock')).toBeHidden()
				it "should show lock icon if entity is finalized", ->
					waitsFor ->
						@bec.$('.bv_status option').length > 0
					, 1000
					runs ->
						@bec.$('.bv_status').val('finalized')
						@bec.$('.bv_status').change()
						expect(@bec.$('.bv_lock')).toBeVisible()
			describe "User edits fields", ->
				it "should update model when scientist is changed", ->
					expect(@bec.model.get 'recordedBy').toEqual "nxm7557"
					@bec.$('.bv_recordedBy').val("xxl7932")
					@bec.$('.bv_recordedBy').change()
					expect(@bec.model.get 'recordedBy').toEqual "xxl7932"
				it "should update model when shortDescription is changed", ->
					@bec.$('.bv_shortDescription').val(" New short description   ")
					@bec.$('.bv_shortDescription').change()
					expect(@bec.model.get 'shortDescription').toEqual "New short description"
				it "should set model shortDescription to a space when shortDescription is set to empty", ->
					@bec.$('.bv_shortDescription').val("")
					@bec.$('.bv_shortDescription').change()
					expect(@bec.model.get 'shortDescription').toEqual " "
				it "should update model when description is changed", ->
					@bec.$('.bv_description').val(" New long description   ")
					@bec.$('.bv_description').change()
					states = @bec.model.get('lsStates').getStatesByTypeAndKind "metadata", "experiment metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "description")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New long description"
					expect(@bec.model.getDescription().get('clobValue')).toEqual "New long description"
				it "should update model when entity name is changed", ->
					@bem.set subclass: "entity" # work around for the spec to pass. In a subclass, the dom element would be .bv_[subclass]Name not .bv_entityName
					@bec.render()
					@bec.$('.bv_entityName').val(" Updated entity name   ")
					@bec.$('.bv_entityName').change()
					expect(@bec.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "Updated entity name"
				it "should update model when notebook is changed", ->
					@bec.$('.bv_notebook').val(" Updated notebook  ")
					@bec.$('.bv_notebook').change()
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
						expect(@bec.model.getStatus().get('stringValue')).toEqual 'complete'


		describe "When created from a new entity", ->
			beforeEach ->
				@bem = new BaseEntity()
				@bem.getStatus().set stringValue: "created" #work around for left over pointers
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
				it "should show the status select disabled", ->
					expect(@bec.$('.bv_status').attr('disabled')).toEqual 'disabled'
				it "should show status select value as created", ->
					@bem2 = new BaseEntity()
					@bem2.set subclass: 'experiment' #this is required to load experimentStatus options from the dataDict (no dataDict for entityStatus)
					@bem2.getStatus().set stringValue: "created" #work around for left over pointers
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
					@bec.$('.bv_recordedBy').val("nxm7557")
					@bec.$('.bv_recordedBy').change()
					@bec.$('.bv_shortDescription').val(" New short description   ")
					@bec.$('.bv_shortDescription').change()
					@bec.$('.bv_entityName').val(" Updated entity name   ")
					@bec.$('.bv_entityName').change()
					@bec.$('.bv_notebook').val("my notebook")
					@bec.$('.bv_notebook').change()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@bec.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							expect(@bec.$('.bv_save').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@bec.$('.bv_entityName').val("")
							@bec.$('.bv_entityName').change()
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
						runs ->
							@bec.$('.bv_recordedBy').val("")
							@bec.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@bec.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@bec.$('.bv_notebook').val("")
							@bec.$('.bv_notebook').change()
					it "should show error on notebook dropdown", ->
						runs ->
							expect(@bec.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "expect save to work", ->
					it "model should be valid and ready to save", ->
						runs ->
							expect(@bec.model.isValid()).toBeTruthy()
					it "should update entity code", ->
						runs ->
							@bec.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@bec.$('.bv_entityCode').html()).toEqual "EXPT-00000001"
					it "should show the save button text as Update", ->
						runs ->
							@bec.$('.bv_save').click()
						waits(1000)
						runs ->
							expect(@bec.$('.bv_save').html()).toEqual "Update"

