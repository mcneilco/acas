beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Protocol module testing", ->
	describe "AbstractProtocolParameter", ->
		it "should have defaults", ->
			@app = new AbstractProtocolParameter()
			expect(@app.get('parameter')).toEqual "abstractParameter"

	describe "Assay Activity Model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@aa = new AssayActivity()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@aa).toBeDefined()
				it "should have defaults", ->
					expect(@aa.get('assayActivity')).toEqual "unassigned"
		describe "model validation tests", ->
			beforeEach ->
				@aa = new AssayActivity window.protocolServiceTestJSON.assayActivities[0]
			it "should be valid as initialized", ->
				expect(@aa.isValid()).toBeTruthy()

	describe "Target Origin Model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@tori = new TargetOrigin()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@tori).toBeDefined()
				it "should have defaults", ->
					expect(@tori.get('targetOrigin')).toEqual "unassigned"
		describe "model validation tests", ->
			beforeEach ->
				@tori = new AssayActivity window.protocolServiceTestJSON.targetOrigins[0]
			it "should be valid as initialized", ->
				expect(@tori.isValid()).toBeTruthy()

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
				it 'Should have an empty assay tree rule', ->
					expect(@prot.get('assayTreeRule')).toEqual null
				it 'Should have the select DNS target list be checked', ->
					expect(@prot.get('dnsTargetList')).toEqual true
				it 'Should have the assayStage default to unassigned', ->
					expect(@prot.get('assayStage')).toEqual "unassigned"
				it 'Should have an default maxY curve display of 100', ->
					expect(@prot.get('maxY')).toEqual 100
				it 'Should have an default minY curve display of 0', ->
					expect(@prot.get('minY')).toEqual 0
				it 'Should have an assay activity list', ->
					expect(@prot.get('assayActivityList') instanceof AssayActivityList).toBeTruthy()
				it 'Should have a targetOrigin list', ->
					expect(@prot.get('targetOriginList') instanceof TargetOriginList).toBeTruthy()
			describe "required states and values", ->
				it 'Should have a description value', -> # description will be Protocol Details or experimentDetails
					expect(@prot.getDescription() instanceof Value).toBeTruthy()
					expect(@prot.getDescription().get('clobValue')).toEqual ""
				it 'Should have a notebook value', ->
					expect(@prot.getNotebook() instanceof Value).toBeTruthy()
				it 'Protocol status should default to created ', ->
					expect(@prot.getStatus().get('stringValue')).toEqual "created"
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
					expect(@prot.get('lsStates').at(0).get('lsKind')).toEqual "protocol controls"
				it "states should have values", ->
					expect(@prot.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual "data analysis parameters"
				it 'Should have a description value', ->
					expect(@prot.getDescription().get('clobValue')).toEqual "long description goes here"
				it 'Should have a notebook value', ->
					expect(@prot.getNotebook().get('stringValue')).toEqual "912"
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
			it 'should convert assayActivityList to AssayActivityList', ->
				runs ->
					expect(@prot.get('assayActivityList')instanceof AssayActivityList).toBeTruthy()
			it 'should convert targetOriginList to TargetOriginList', ->
				runs ->
					console.log @prot.get('targetOriginList')
					expect(@prot.get('targetOriginList')instanceof TargetOriginList).toBeTruthy()


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
			it "should be invalid when maxY is NaN", ->
				@prot.set maxY: NaN
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='maxY'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when minY is NaN", ->
				@prot.set minY: NaN
				expect(@prot.isValid()).toBeFalsy()
				filtErrors = _.filter(@prot.validationError, (err) ->
					err.attribute=='minY'
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

	describe "Assay Activity List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@aal = new AssayActivityList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@aal).toBeDefined()
		describe "When loaded form existing", ->
			beforeEach ->
				@aal = new AssayActivityList window.protocolServiceTestJSON.assayActivities
			it "should have two assay activities", ->
				expect(@aal.length).toEqual 2
			it "should have the correct info for the first assay activity", ->
				assayOne = @aal.at(0)
				expect(assayOne.get('assayActivity')).toEqual "luminescence"
			it "should have the correct info for the second assay activity", ->
				assayTwo = @aal.at(1)
				expect(assayTwo.get('assayActivity')).toEqual "fluorescence"
		describe "collection validation", ->
			beforeEach ->
				@aal= new AssayActivityList window.protocolServiceTestJSON.assayActivities
			it "should be invalid if a assay activity is selected more than once", ->
				@aal.at(0).set assayActivity: "luminescence"
				@aal.at(1).set assayActivity: "luminescence"
				expect((@aal.validateCollection()).length).toBeGreaterThan 0

	describe "Target Origin List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@tol = new TargetOriginList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@tol).toBeDefined()
		describe "When loaded form existing", ->
			beforeEach ->
				@tol = new TargetOriginList window.protocolServiceTestJSON.targetOrigins
			it "should have two target origins", ->
				expect(@tol.length).toEqual 2
			it "should have the correct info for the first target origin", ->
				targetOne = @tol.at(0)
				expect(targetOne.get('targetOrigin')).toEqual "human"
			it "should have the correct info for the second target origin", ->
				targetTwo = @tol.at(1)
				expect(targetTwo.get('targetOrigin')).toEqual "chimpanzee"
		describe "collection validation", ->
			beforeEach ->
				@tol= new TargetOriginList window.protocolServiceTestJSON.targetOrigins
			it "should be invalid if a assay activity is selected more than once", ->
				@tol.at(0).set targetOrigin: "human"
				@tol.at(1).set targetOrigin: "human"
				expect((@tol.validateCollection()).length).toBeGreaterThan 0

	describe "Protocol List testing", ->
		beforeEach ->
			@el = new ProtocolList()
		describe "existance tests", ->
			it "should be defined", ->
				expect(ProtocolList).toBeDefined()


	describe "AssayActivityController", ->
		describe "when instantiated", ->
			beforeEach ->
				@aac = new AssayActivityController
					model: new AssayActivity window.protocolServiceTestJSON.assayActivities[0]
					el: $('#fixture')
				@aac.render()
			describe "basic existance tests", ->
				it "should exist", ->
					expect(@aac).toBeDefined()
				it "should load a template", ->
					expect(@aac.$('.bv_assayActivity').length).toEqual 1
			describe "render existing parameters", ->
				it "should show assay activity", ->
					waitsFor ->
						@aac.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						expect(@aac.$('.bv_assayActivity').val()).toEqual "luminescence"
			describe "model updates", ->
				it "should update the assay activity", ->
					waitsFor ->
						@aac.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						@aac.$('.bv_assayActivity').val("fluorescence")
						@aac.$('.bv_assayActivity').change()
						expect(@aac.model.get('assayActivity')).toEqual "fluorescence"

	describe "TargetOriginController", ->
		describe "when instantiated", ->
			beforeEach ->
				@toc = new TargetOriginController
					model: new TargetOrigin window.protocolServiceTestJSON.targetOrigins[0]
					el: $('#fixture')
				@toc.render()
			describe "basic existance tests", ->
				it "should exist", ->
					expect(@toc).toBeDefined()
				it "should load a template", ->
					expect(@toc.$('.bv_targetOrigin').length).toEqual 1
			describe "render existing parameters", ->
				it "should show target origin", ->
					waitsFor ->
						@toc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@toc.$('.bv_targetOrigin').val()).toEqual "human"
			describe "model updates", ->
				it "should update the target origin ", ->
					waitsFor ->
						@toc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						@toc.$('.bv_targetOrigin').val("chimpanzee")
						@toc.$('.bv_targetOrigin').change()
						expect(@toc.model.get('targetOrigin')).toEqual "chimpanzee"

	describe "Assay Activity List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@aalc= new AssayActivityListController
					el: $('#fixture')
					collection: new AssayActivityList()
				@aalc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@aalc).toBeDefined()
				it "should load a template", ->
					expect(@aalc.$('.bv_addActivityButton').length).toEqual 1
			describe "rendering", ->
				it "should show one activity", ->
					expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual 1
					expect(@aalc.collection.length).toEqual 1
			describe "adding and removing", ->
				it "should have two activities when add button is clicked", ->
					@aalc.$('.bv_addActivityButton').click()
					expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual 2
					expect(@aalc.collection.length).toEqual 2
				it "should have one activity when there are two activities and remove is clicked", ->
					@aalc.$('.bv_addActivityButton').click()
					expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual 2
					@aalc.$('.bv_deleteActivity:eq(0)').click()
					expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual 1
					expect(@aalc.collection.length).toEqual 1
				it "should always have one activity", ->
					expect(@aalc.collection.length).toEqual 1
					@aalc.$('.bv_deleteActivity').click()
					expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual 1
					expect(@aalc.collection.length).toEqual 1

		describe "when instantiated with data", ->
			beforeEach ->
				@aalc= new AssayActivityListController
					el: $('#fixture')
					collection: new AssayActivityList window.protocolServiceTestJSON.assayActivities
				@aalc.render()
			it "should have two activities", ->
				expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual 2
				expect(@aalc.collection.length).toEqual 2
			it "should have the correct info for the first activity", ->
				waitsFor ->
					@aalc.$('.bv_assayActivity option').length > 0
				, 1000
				runs ->
					expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity:eq(0)').val()).toEqual "luminescence"
			it "should have the correct info for the second activity", ->
				waitsFor ->
					@aalc.$('.bv_assayActivity option').length > 0
				, 1000
				runs ->
					expect(@aalc.$('.bv_assayActivityInfo .bv_assayActivity:eq(1)').val()).toEqual "fluorescence"

	describe "Target Origin List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@tolc= new TargetOriginListController
					el: $('#fixture')
					collection: new TargetOriginList()
				@tolc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@tolc).toBeDefined()
				it "should load a template", ->
					expect(@tolc.$('.bv_addTargetOriginButton').length).toEqual 1
			describe "rendering", ->
				it "should show one target origin", ->
					expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual 1
					expect(@tolc.collection.length).toEqual 1
			describe "adding and removing", ->
				it "should have two target origins when add button is clicked", ->
					@tolc.$('.bv_addTargetOriginButton').click()
					expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual 2
					expect(@tolc.collection.length).toEqual 2
				it "should have one target origin when there are two target origins and remove is clicked", ->
					@tolc.$('.bv_addTargetOriginButton').click()
					expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual 2
					@tolc.$('.bv_deleteTargetOrigin:eq(0)').click()
					expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual 1
					expect(@tolc.collection.length).toEqual 1
				it "should always have one target origin", ->
					expect(@tolc.collection.length).toEqual 1
					@tolc.$('.bv_deleteTargetOrigin').click()
					expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual 1
					expect(@tolc.collection.length).toEqual 1

		describe "when instantiated with data", ->
			beforeEach ->
				@tolc= new TargetOriginListController
					el: $('#fixture')
					collection: new TargetOriginList window.protocolServiceTestJSON.targetOrigins
				@tolc.render()
			it "should have two target origin", ->
				expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual 2
				expect(@tolc.collection.length).toEqual 2
			it "should have the correct info for the first target origin", ->
				waitsFor ->
					@tolc.$('.bv_targetOrigin option').length > 0
				, 1000
				runs ->
					expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin:eq(0)').val()).toEqual "human"
			it "should have the correct info for the second target origin", ->
				waitsFor ->
					@tolc.$('.bv_targetOrigin option').length > 0
				, 1000
				runs ->
					expect(@tolc.$('.bv_targetOriginInfo .bv_targetOrigin:eq(1)').val()).toEqual "chimpanzee"


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
				it "should fill the long description field", ->
					expect(@pbc.$('.bv_description').html()).toEqual "long description goes here"
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
				it "should fill the assay tree rule",  ->
					expect(@pbc.$('.bv_assayTreeRule').val()).toEqual "example assay tree rule"
				it "should have the select dns target list checkbox checked",  ->
					expect(@pbc.$('.bv_dnsTargetList').attr("checked")).toEqual "checked"
				it "should show the assay stage",  ->
					waitsFor ->
						@pbc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_assayStage').val()).toEqual "assay development"
				it "should fill the max Y value",  ->
					expect(@pbc.$('.bv_maxY').val()).toEqual "200"
				it "should fill the min Y value",  ->
					expect(@pbc.$('.bv_minY').val()).toEqual "2"
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
				it "should update model when description is changed", ->
					@pbc.$('.bv_description').val(" New long description   ")
					@pbc.$('.bv_description').change()
					states = @pbc.model.get('lsStates').getStatesByTypeAndKind "metadata", "protocol metadata"
					expect(states.length).toEqual 1
					values = states[0].getValuesByTypeAndKind("clobValue", "description")
					desc = values[0].get('clobValue')
					expect(desc).toEqual "New long description"
					expect(@pbc.model.getDescription().get('clobValue')).toEqual "New long description"
				it "should update model when protocol name is changed", ->
					@pbc.$('.bv_protocolName').val(" Updated protocol name   ")
					@pbc.$('.bv_protocolName').change()
					expect(@pbc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual "Updated protocol name"
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
				it "should update model when assay tree rule changed", ->
					@pbc.$('.bv_assayTreeRule').val(" Updated assay tree rule  ")
					@pbc.$('.bv_assayTreeRule').change()
					expect(@pbc.model.get('assayTreeRule')).toEqual "Updated assay tree rule"
				it "should update the select DNS target list", ->
					@pbc.$('.bv_dnsTargetList').click()
					@pbc.$('.bv_dnsTargetList').click()
					expect(@pbc.model.get('dnsTargetList')).toBeFalsy()
					# don't know why there needs to be two clicks for spec to pass
				it "should update model when assay stage changed", ->
					waitsFor ->
						@pbc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_assayStage').val('unassigned')
						@pbc.$('.bv_assayStage').change()
						expect(@pbc.model.get('assayStage')).toEqual 'unassigned'
				it "should update model when maxY changed", ->
					@pbc.$('.bv_maxY').val(" 50  ")
					@pbc.$('.bv_maxY').change()
					expect(@pbc.model.get('maxY')).toEqual 50
				it "should update model when minY changed", ->
					@pbc.$('.bv_minY').val(" 5  ")
					@pbc.$('.bv_minY').change()
					expect(@pbc.model.get('minY')).toEqual 5

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
				it "should have the select dns target list be checked", ->
					expect(@pbc.$('.bv_dnsTargetList').attr("checked")).toEqual "checked"
				it "should show assay stage select value as unassigned", ->
					waitsFor ->
						@pbc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_assayStage').val()).toEqual 'unassigned'
				it "should have the maxY value be 100", ->
					expect(@pbc.$('.bv_maxY').val()).toEqual '100'
				it "should have the minY value be 100", ->
					expect(@pbc.$('.bv_minY').val()).toEqual '0'
			describe "controller validation rules", ->
				beforeEach ->
					@pbc.$('.bv_recordedBy').val("nxm7557")
					@pbc.$('.bv_recordedBy').change()
					@pbc.$('.bv_shortDescription').val(" New short description   ")
					@pbc.$('.bv_shortDescription').change()
					@pbc.$('.bv_protocolName').val(" Updated entity name   ")
					@pbc.$('.bv_protocolName').change()
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
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_notebook').val("")
							@pbc.$('.bv_notebook').change()
					it "should show error on notebook dropdown", ->
						runs ->
							expect(@pbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when maxY is NaN", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_maxY').val("b")
							@pbc.$('.bv_maxY').change()
					it "should show error on maxY field", ->
						runs ->
							expect(@pbc.$('.bv_group_maxY').hasClass('error')).toBeTruthy()
				describe "when minY is NaN", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_minY').val("b")
							@pbc.$('.bv_minY').change()
					it "should show error on minY field", ->
						runs ->
							expect(@pbc.$('.bv_group_minY').hasClass('error')).toBeTruthy()
				describe "when assay activity is selected more than once", ->
					it "should show error for each of the duplicated activities", ->
						@pbc.$('.bv_addActivityButton').click()
						waitsFor ->
							@pbc.$('.bv_assayActivityInfo .bv_assayActivity option').length > 0
						, 1000
						runs ->
							@pbc.$('.bv_assayActivity:eq(0)').val "fluorescence"
							@pbc.$('.bv_assayActivity:eq(0)').change()
							@pbc.$('.bv_assayActivity:eq(1)').val "fluorescence"
							@pbc.$('.bv_assayActivity:eq(1)').change()
							expect(@pbc.$('.bv_group_assayActivity:eq(0)').hasClass('error')).toBeTruthy()
							expect(@pbc.$('.bv_group_assayActivity:eq(1)').hasClass('error')).toBeTruthy()
				describe "when target origin is selected more than once", ->
					it "should show error for each of the duplicated target origins", ->
						@pbc.$('.bv_addTargetOriginButton').click()
						waitsFor ->
							@pbc.$('.bv_targetOriginInfo .bv_targetOrigin option').length > 0
						, 1000
						runs ->
							@pbc.$('.bv_targetOrigin:eq(0)').val "human"
							@pbc.$('.bv_targetOrigin:eq(0)').change()
							@pbc.$('.bv_targetOrigin:eq(1)').val "human"
							@pbc.$('.bv_targetOrigin:eq(1)').change()
							expect(@pbc.$('.bv_group_targetOrigin:eq(0)').hasClass('error')).toBeTruthy()
							expect(@pbc.$('.bv_group_targetOrigin:eq(1)').hasClass('error')).toBeTruthy()

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

