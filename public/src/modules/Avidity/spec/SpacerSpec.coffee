beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Spacer testing', ->
	describe " Parent model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@sp = new SpacerParent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@sp).toBeDefined()
				it "should have a type", ->
					expect(@sp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@sp.get('lsKind')).toEqual "spacer"
				it "should have the recordedBy set to the logged in user", ->
					expect(@sp.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@sp.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with one label", ->
					expect(@sp.get('lsLabels')).toBeDefined()
					expect(@sp.get("lsLabels").length).toEqual 1
					expect(@sp.get("lsLabels").getLabelByTypeAndKind("name", "spacer").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@sp.get("spacer name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@sp.get('lsStates')).toBeDefined()
					expect(@sp.get("lsStates").length).toEqual 1
					expect(@sp.get("lsStates").getStatesByTypeAndKind("metadata", "spacer parent").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for scientist", ->
						expect(@sp.get("scientist")).toBeDefined()
					it "Should have a model attribute for completion date", ->
						expect(@sp.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@sp.get("notebook")).toBeDefined()
					it "Should have a model attribute for molecular weight", ->
						expect(@sp.get("molecular weight")).toBeDefined()
					it "Should have a model attribute for structural file", ->
						expect(@sp.get("structural file")).toBeDefined()
			describe "model validation", ->
				it "should be invalid when name is empty", ->
					@sp.get("spacer name").set("labelText", "")
					expect(@sp.isValid()).toBeFalsy()
					filtErrors = _.filter(@sp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when molecular weight is NaN", ->
					@sp.get("molecular weight").set("value", "fred")
					expect(@sp.isValid()).toBeFalsy()
					filtErrors = _.filter(@sp.validationError, (err) ->
						err.attribute=='molecularWeight'
					)
					expect(filtErrors.length).toBeGreaterThan 0

		describe "When created from existing", ->
			beforeEach ->
				@sp = new SpacerParent JSON.parse(JSON.stringify(window.spacerTestJSON.spacerParent))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@sp).toBeDefined()
				it "should have a type", ->
					expect(@sp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@sp.get('lsKind')).toEqual "spacer"
				it "should have a recordedBy set", ->
					expect(@sp.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@sp.get('recordedDate')).toEqual 1375141508000
				it "Should have label set", ->
					console.log @sp
					expect(@sp.get("spacer name").get("labelText")).toEqual "PEG10"
					label = (@sp.get("lsLabels").getLabelByTypeAndKind("name", "spacer"))
					console.log label[0]
					expect(label[0].get('labelText')).toEqual "PEG10"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@sp.get('lsStates')).toBeDefined()
					expect(@sp.get("lsStates").length).toEqual 1
					expect(@sp.get("lsStates").getStatesByTypeAndKind("metadata", "spacer parent").length).toEqual 1
				it "Should have a scientist value", ->
					expect(@sp.get("scientist").get("value")).toEqual "john"
				it "Should have a completion date value", ->
					expect(@sp.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@sp.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a molecular weight value", ->
					expect(@sp.get("molecular weight").get("value")).toEqual 231
				it "Should have a structural file value", ->
					expect(@sp.get("structural file").get("value")).toEqual "TestFile.mol"

			describe "model validation", ->
				beforeEach ->
					@sp = new SpacerParent window.spacerTestJSON.spacerParent
				it "should be valid when loaded from saved", ->
					expect(@sp.isValid()).toBeTruthy()
				it "should be invalid when name is empty", ->
					@sp.get("spacer name").set("labelText", "")
					expect(@sp.isValid()).toBeFalsy()
					filtErrors = _.filter(@sp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when scientist not selected", ->
					@sp.get('scientist').set('value', "unassigned")
					expect(@sp.isValid()).toBeFalsy()
					filtErrors = _.filter(@sp.validationError, (err) ->
						err.attribute=='scientist'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when completion date is empty", ->
					@sp.get("completion date").set("value", new Date("").getTime())
					expect(@sp.isValid()).toBeFalsy()
					filtErrors = _.filter(@sp.validationError, (err) ->
						err.attribute=='completionDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when notebook is empty", ->
					@sp.get("notebook").set("value", "")
					expect(@sp.isValid()).toBeFalsy()
					filtErrors = _.filter(@sp.validationError, (err) ->
						err.attribute=='notebook'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when molecular weight is NaN", ->
					@sp.get("molecular weight").set("value", "fred")
					expect(@sp.isValid()).toBeFalsy()
					filtErrors = _.filter(@sp.validationError, (err) ->
						err.attribute=='molecularWeight'
					)
					expect(filtErrors.length).toBeGreaterThan 0

	describe "Spacer Batch model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@sb= new SpacerBatch()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@sb).toBeDefined()
				it "should have a type", ->
					expect(@sb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@sb.get('lsKind')).toEqual "spacer"
				it "should have a recordedBy set to logged in user", ->
					expect(@sb.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@sb.get('recordedDate')).getHours()).toEqual new Date().getHours()
				#				it "should have an analytical method file type", ->
				#					expect(@sb.get('analyticalFileType')).toEqual "unassigned"
				#				it "should have an analytical method fileValue", ->
				#					expect(@sb.get('analyticalFileType')).toEqual "unassigned"
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for scientist", ->
						expect(@sb.get("scientist")).toBeDefined()
					it "Should have a model attribute for completion date", ->
						expect(@sb.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@sb.get("notebook")).toBeDefined()
					it "Should have a model attribute for source", ->
						expect(@sb.get("source").get).toBeDefined()
						expect(@sb.get("source").get('value')).toEqual "Avidity"
					it "Should have a model attribute for source id", ->
						expect(@sb.get("source id")).toBeDefined()

					#					it "Should have a model attribute for analytical method file type", ->
					#						expect(@sb.get("analytical file type")).toBeDefined()
					it "Should have a model attribute for purity", ->
						expect(@sb.get("purity")).toBeDefined()
					it "Should have a model attribute for amount made", ->
						expect(@sb.get("amount made")).toBeDefined()
					it "Should have a model attribute for location", ->
						expect(@sb.get("location")).toBeDefined()

		describe "When created from existing", ->
			beforeEach ->
				@sb = new SpacerBatch JSON.parse(JSON.stringify(window.spacerTestJSON.spacerBatch))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@sb).toBeDefined()
				it "should have a type", ->
					expect(@sb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@sb.get('lsKind')).toEqual "spacer"
				it "should have a recordedBy set", ->
					expect(@sb.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@sb.get('recordedDate')).toEqual 1375141508000
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@sb.get('lsStates')).toBeDefined()
					expect(@sb.get("lsStates").length).toEqual 2
					expect(@sb.get("lsStates").getStatesByTypeAndKind("metadata", "spacer batch").length).toEqual 1
					expect(@sb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual 1
				it "Should have a scientist value", ->
					expect(@sb.get("scientist").get("value")).toEqual "john"
				it "Should have a completion date value", ->
					expect(@sb.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@sb.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a source value", ->
					expect(@sb.get("source").get("value")).toEqual "Avidity"
				it "Should have a source id", ->
					expect(@sb.get("source id").get("value")).toEqual "12345"
				it "Should have a purity value", ->
					expect(@sb.get("purity").get("value")).toEqual 92
				it "Should have an amount made value", ->
					expect(@sb.get("amount made").get("value")).toEqual 2.3
				it "Should have a location value", ->
					expect(@sb.get("location").get("value")).toEqual "Cabinet 1"

		describe "model validation", ->
			beforeEach ->
				@sb = new SpacerBatch window.spacerTestJSON.spacerBatch
			it "should be valid when loaded from saved", ->
				expect(@sb.isValid()).toBeTruthy()
			it "should be invalid when scientist not selected", ->
				@sb.get('scientist').set('value', "unassigned")
				expect(@sb.isValid()).toBeFalsy()
				filtErrors = _.filter(@sb.validationError, (err) ->
					err.attribute=='scientist'
				)
			it "should be invalid when completion date is empty", ->
				@sb.get("completion date").set("value", new Date("").getTime())
				expect(@sb.isValid()).toBeFalsy()
				filtErrors = _.filter(@sb.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when notebook is empty", ->
				@sb.get("notebook").set("value", "")
				expect(@sb.isValid()).toBeFalsy()
				filtErrors = _.filter(@sb.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when source is not selected", ->
				@sb.get("source").set("value", "unassigned")
				expect(@sb.isValid()).toBeFalsy()
				filtErrors = _.filter(@sb.validationError, (err) ->
					err.attribute=='source'
				)
			it "should be invalid when purity is NaN", ->
				@sb.get("purity").set("value", "fred")
				expect(@sb.isValid()).toBeFalsy()
				filtErrors = _.filter(@sb.validationError, (err) ->
					err.attribute=='purity'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when amount made is NaN", ->
				@sb.get("amount made").set("value", "fred")
				expect(@sb.isValid()).toBeFalsy()
				filtErrors = _.filter(@sb.validationError, (err) ->
					err.attribute=='amountMade'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when location is empty", ->
				@sb.get("location").set("value", "")
				expect(@sb.isValid()).toBeFalsy()
				filtErrors = _.filter(@sb.validationError, (err) ->
					err.attribute=='location'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Spacer Parent Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@sp = new SpacerParent()
				@spc = new SpacerParentController
					model: @sp
					el: $('#fixture')
				@spc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@spc).toBeDefined()
				it "should load the template", ->
					expect(@spc.$('.bv_parentCode').html()).toEqual "Autofilled when saved"
				it "should load the additional parent attributes template", ->
					expect(@spc.$('.bv_molecularWeight').length).toEqual 1
		describe "When instantiated from existing", ->
			beforeEach ->
				@sp = new SpacerParent JSON.parse(JSON.stringify(window.spacerTestJSON.spacerParent))
				@spc = new SpacerParentController
					model: @sp
					el: $('#fixture')
				@spc.render()
			describe "render existing parameters", ->
				it "should show the spacer parent id", ->
					expect(@spc.$('.bv_parentCode').val()).toEqual "SP000001"
				it "should fill the spacer parent name", ->
					expect(@spc.$('.bv_parentName').val()).toEqual "PEG10"
				it "should fill the scientist field", ->
					waitsFor ->
						@spc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						console.log @spc.$('.bv_scientist').val()
						expect(@spc.$('.bv_scientist').val()).toEqual "john"
				it "should fill the completion date field", ->
					expect(@spc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@spc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the molecular weight field", ->
					expect(@spc.$('.bv_molecularWeight').val()).toEqual "231"

			describe "model updates", ->
				it "should update model when parent name is changed", ->
					@spc.$('.bv_parentName').val(" New name   ")
					@spc.$('.bv_parentName').keyup()
					expect(@spc.model.get('spacer name').get('labelText')).toEqual "New name"
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@spc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@spc.$('.bv_scientist').val('unassigned')
						@spc.$('.bv_scientist').change()
						expect(@spc.model.get('scientist').get('value')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@spc.$('.bv_completionDate').val(" 2013-3-16   ")
					@spc.$('.bv_completionDate').keyup()
					expect(@spc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@spc.$('.bv_notebook').val(" Updated notebook  ")
					@spc.$('.bv_notebook').keyup()
					expect(@spc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when molecular weight is changed", ->
					@spc.$('.bv_molecularWeight').val(" 12  ")
					@spc.$('.bv_molecularWeight').keyup()
					expect(@spc.model.get('molecular weight').get('value')).toEqual 12

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@spc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@spc.$('.bv_parentName').val(" Updated entity name   ")
						@spc.$('.bv_parentName').keyup()
						@spc.$('.bv_scientist').val("bob")
						@spc.$('.bv_scientist').change()
						@spc.$('.bv_completionDate').val(" 2013-3-16   ")
						@spc.$('.bv_completionDate').keyup()
						@spc.$('.bv_notebook').val("my notebook")
						@spc.$('.bv_notebook').keyup()
						@spc.$('.bv_molecularWeight').val(" 24")
						@spc.$('.bv_molecularWeight').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@spc.isValid()).toBeTruthy()
					it "should have the update button be enabled", ->
						runs ->
							expect(@spc.$('.bv_updateParent').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@spc.$('.bv_parentName').val("")
							@spc.$('.bv_parentName').keyup()
					it "should be invalid if name not filled in", ->
						runs ->
							expect(@spc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@spc.$('.bv_group_parentName').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@spc.$('.bv_updateParent').attr('disabled')).toEqual 'disabled'
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@spc.$('.bv_scientist').val("")
							@spc.$('.bv_scientist').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@spc.$('.bv_group_scientist').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@spc.$('.bv_completionDate').val("")
							@spc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@spc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@spc.$('.bv_notebook').val("")
							@spc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@spc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when molecular weight not filled", ->
					beforeEach ->
						runs ->
							@spc.$('.bv_molecularWeight').val("")
							@spc.$('.bv_molecularWeight').keyup()
					it "should show error on molecular weight field", ->
						runs ->
							expect(@spc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy()

	describe "Spacer Batch Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@sb = new SpacerBatch()
				@sbc = new SpacerBatchController
					model: @sb
					el: $('#fixture')
				@sbc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@sbc).toBeDefined()
				it "should load the template", ->
					expect(@sbc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "When instantiated from existing", ->
			beforeEach ->
				@sb = new SpacerBatch JSON.parse(JSON.stringify(window.spacerTestJSON.spacerBatch))
				@sbc = new SpacerBatchController
					model: @sb
					el: $('#fixture')
				@sbc.render()
			describe "render existing parameters", ->
				it "should show the spacer batch id", ->
					expect(@sbc.$('.bv_batchCode').val()).toEqual "SP000001-1"
				it "should fill the scientist field", ->
					waitsFor ->
						@sbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						expect(@sbc.$('.bv_scientist').val()).toEqual "john"
				it "should fill the completion date field", ->
					expect(@sbc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@sbc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the source field", ->
					waitsFor ->
						@sbc.$('.bv_source option').length > 0
					, 1000
					runs ->
						expect(@sbc.$('.bv_source').val()).toEqual "Avidity"
				it "should fill the source id field", ->
					expect(@sbc.$('.bv_sourceId').val()).toEqual "12345"
				it "should fill the purity field", ->
					expect(@sbc.$('.bv_purity').val()).toEqual "92"
				it "should fill the amountMade field", ->
					expect(@sbc.$('.bv_amountMade').val()).toEqual "2.3"
				it "should fill the location field", ->
					expect(@sbc.$('.bv_location').val()).toEqual "Cabinet 1"
			describe "model updates", ->
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@sbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@sbc.$('.bv_scientist').val('unassigned')
						@sbc.$('.bv_scientist').change()
						expect(@sbc.model.get('scientist').get('value')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@sbc.$('.bv_completionDate').val(" 2013-3-16   ")
					@sbc.$('.bv_completionDate').keyup()
					expect(@sbc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@sbc.$('.bv_notebook').val(" Updated notebook  ")
					@sbc.$('.bv_notebook').keyup()
					expect(@sbc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when the source is changed", ->
					waitsFor ->
						@sbc.$('.bv_source option').length > 0
					, 1000
					runs ->
						@sbc.$('.bv_source').val('unassigned')
						@sbc.$('.bv_source').change()
						expect(@sbc.model.get('source').get('value')).toEqual "unassigned"
				it "should update model when source id is changed", ->
					@sbc.$('.bv_sourceId').val(" 252  ")
					@sbc.$('.bv_sourceId').keyup()
					expect(@sbc.model.get('source id').get('value')).toEqual "252"
				it "should update model when purity is changed", ->
					@sbc.$('.bv_purity').val(" 29  ")
					@sbc.$('.bv_purity').keyup()
					expect(@sbc.model.get('purity').get('value')).toEqual 29
				it "should update model when amount made is changed", ->
					@sbc.$('.bv_amountMade').val(" 12  ")
					@sbc.$('.bv_amountMade').keyup()
					expect(@sbc.model.get('amount made').get('value')).toEqual 12
				it "should update model when location is changed", ->
					@sbc.$('.bv_location').val(" Updated location  ")
					@sbc.$('.bv_location').keyup()
					expect(@sbc.model.get('location').get('value')).toEqual "Updated location"

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@sbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@sbc.$('.bv_scientist').val("bob")
						@sbc.$('.bv_scientist').change()
						@sbc.$('.bv_completionDate').val(" 2013-3-16   ")
						@sbc.$('.bv_completionDate').keyup()
						@sbc.$('.bv_notebook').val("my notebook")
						@sbc.$('.bv_notebook').keyup()
						@sbc.$('.bv_source').val("vendor A")
						@sbc.$('.bv_source').change()
						@sbc.$('.bv_sourceId').val(" 24")
						@sbc.$('.bv_sourceId').keyup()
						@sbc.$('.bv_purity').val(" 82")
						@sbc.$('.bv_purity').keyup()
						@sbc.$('.bv_amountMade').val(" 24")
						@sbc.$('.bv_amountMade').keyup()
						@sbc.$('.bv_location').val(" Hood 4")
						@sbc.$('.bv_location').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@sbc.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							expect(@sbc.$('.bv_saveBatch').attr('disabled')).toBeUndefined()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@sbc.$('.bv_scientist').val("")
							@sbc.$('.bv_scientist').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@sbc.$('.bv_group_scientist').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@sbc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@sbc.$('.bv_completionDate').val("")
							@sbc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@sbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@sbc.$('.bv_notebook').val("")
							@sbc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@sbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when source not selected", ->
					beforeEach ->
						runs ->
							@sbc.$('.bv_source').val("")
							@sbc.$('.bv_source').change()
					it "should show error on source dropdown", ->
						runs ->
							expect(@sbc.$('.bv_group_source').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@sbc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when purity not filled", ->
					beforeEach ->
						runs ->
							@sbc.$('.bv_purity').val("")
							@sbc.$('.bv_purity').keyup()
					it "should show error on purity  field", ->
						runs ->
							expect(@sbc.$('.bv_group_purity').hasClass('error')).toBeTruthy()
				describe "when amount made not filled", ->
					beforeEach ->
						runs ->
							@sbc.$('.bv_amountMade').val("")
							@sbc.$('.bv_amountMade').keyup()
					it "should show error on amount made field", ->
						runs ->
							expect(@sbc.$('.bv_group_amountMade').hasClass('error')).toBeTruthy()
				describe "when location not filled", ->
					beforeEach ->
						runs ->
							@sbc.$('.bv_location').val("")
							@sbc.$('.bv_location').keyup()
					it "should show error on location field", ->
						runs ->
							expect(@sbc.$('.bv_group_location').hasClass('error')).toBeTruthy()

	describe "Spacer Batch Select Controller testing", ->
		beforeEach ->
			@sb = new SpacerBatch()
			@sbsc = new SpacerBatchSelectController
				model: @sb
				el: $('#fixture')
			@sbsc.render()
		describe "When instantiated", ->
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@sbsc).toBeDefined()
				it "should load the template", ->
					expect(@sbsc.$('.bv_batchList').length).toEqual 1
			describe "rendering", ->
				it "should have the batch list default to register new batch", ->
					waitsFor ->
						@sbsc.$('.bv_batchList option').length > 0
					, 1000
					runs ->
						expect(@sbsc.$('.bv_batchList').val()).toEqual "new batch"
				it "should a new batch registration form", ->
					console.log @sbsc.$('.bv_batchCode')
					waitsFor ->
						@sbsc.$('.bv_batchList option').length > 0
					, 1000
					runs ->
						expect(@sbsc.$('.bv_batchCode').val()).toEqual ""
						expect(@sbsc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "behavior", ->
			it "should show the information for a selected batch", ->
				waitsFor ->
					@sbsc.$('.bv_batchList option').length > 0
				, 1000
				runs ->
					console.log @sbsc.$('.bv_batchList')
					@sbsc.$('.bv_batchList').val("CB000001-1")
					@sbsc.$('.bv_batchList').change()
				waitsFor ->
					@sbsc.$('.bv_scientist option').length > 0
				, 1000
				runs ->
					waits(1000)
				runs ->
					expect(@sbsc.$('.bv_batchCode').html()).toEqual "CB000001-1"

	describe "Spacer Controller", ->
		beforeEach ->
			@sbc = new SpacerController
				model: new SpacerParent()
				el: $('#fixture')
			@sbc.render()
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@sbc).toBeDefined()
			it "Should load the template", ->
				expect(@sbc.$('.bv_save').length).toEqual 1
			it "Should load a parent controller", ->
				expect(@sbc.$('.bv_parent .bv_parentCode').length).toEqual 1
			it "Should load a batch controller", ->
				waitsFor ->
					@sbc.$('.bv_batchList option').length > 0
				, 1000
				runs ->
					expect(@sbc.$('.bv_batch .bv_batchCode').length).toEqual 1
		describe "saving parent/batch for the first time", ->
			describe "when form is initialized", ->
				it "should have the save button be disabled initially", ->
					expect(@sbc.$('.bv_save').attr('disabled')).toEqual 'disabled'
			describe 'when save is clicked', ->
				beforeEach ->
					waitsFor ->
						@sbc.$('.bv_fileType option').length > 0
					, 1000
					runs ->
						@sbc.$('.bv_parentName').val(" Updated entity name   ")
						@sbc.$('.bv_parentName').keyup()
						@sbc.$('.bv_scientist').val("bob")
						@sbc.$('.bv_scientist').change()
						@sbc.$('.bv_completionDate').val(" 2013-3-16   ")
						@sbc.$('.bv_completionDate').keyup()
						@sbc.$('.bv_notebook').val("my notebook")
						@sbc.$('.bv_notebook').keyup()
						@sbc.$('.bv_source').val("Avidity")
						@sbc.$('.bv_source').change()
						@sbc.$('.bv_sourceId').val("12345")
						@sbc.$('.bv_sourceId').keyup()
						@sbc.$('.bv_molecularWeight').val(" 24")
						@sbc.$('.bv_molecularWeight').keyup()
						@sbc.$('.bv_purity').val(" 24")
						@sbc.$('.bv_purity').keyup()
						@sbc.$('.bv_amountMade').val(" 24")
						@sbc.$('.bv_amountMade').keyup()
						@sbc.$('.bv_location').val(" Hood 4")
						@sbc.$('.bv_location').keyup()
					waitsFor ->
						@sbc.$('.bv_fileType option').length > 0
					, 1000
				it "should have the save button be enabled", ->
					runs ->
						expect(@sbc.$('.bv_save').attr('disabled')).toBeUndefined()
				it "should update the parent code", ->
					runs ->
						@sbc.$('.bv_save').click()
					waits(2000)
					runs ->
						expect(@sbc.$('.bv_parentCode').html()).toEqual "SP000001"
				it "should update the batch code", ->
					runs ->
						@sbc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@sbc.$('.bv_batchCode').html()).toEqual "SP000001-1"
				it "should show the update parent button", ->
					runs ->
						@sbc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@sbc.$('.bv_updateParent')).toBeVisible()
				it "should show the update batch button", ->
					runs ->
						@sbc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@sbc.$('.bv_saveBatch')).toBeVisible()



