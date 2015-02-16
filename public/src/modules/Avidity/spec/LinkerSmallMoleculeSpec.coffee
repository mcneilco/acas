beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Linker Small Molecule testing', ->
	describe " Parent model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@lsmp = new LinkerSmallMoleculeParent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@lsmp).toBeDefined()
				it "should have a type", ->
					expect(@lsmp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@lsmp.get('lsKind')).toEqual "linker small molecule"
				it "should have the recordedBy set to the logged in user", ->
					expect(@lsmp.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@lsmp.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with one label", ->
					expect(@lsmp.get('lsLabels')).toBeDefined()
					expect(@lsmp.get("lsLabels").length).toEqual 1
					expect(@lsmp.get("lsLabels").getLabelByTypeAndKind("name", "linker small molecule").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@lsmp.get("linker small molecule name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@lsmp.get('lsStates')).toBeDefined()
					expect(@lsmp.get("lsStates").length).toEqual 1
					expect(@lsmp.get("lsStates").getStatesByTypeAndKind("metadata", "linker small molecule parent").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for scientist", ->
						expect(@lsmp.get("scientist")).toBeDefined()
					it "Should have a model attribute for completion date", ->
						expect(@lsmp.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@lsmp.get("notebook")).toBeDefined()
					it "Should have a model attribute for molecular weight", ->
						expect(@lsmp.get("molecular weight")).toBeDefined()
					it "Should have a model attribute for structural file", ->
						expect(@lsmp.get("structural file")).toBeDefined()
			describe "model validation", ->
				it "should be invalid when name is empty", ->
					@lsmp.get("linker small molecule name").set("labelText", "")
					expect(@lsmp.isValid()).toBeFalsy()
					filtErrors = _.filter(@lsmp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when molecular weight is NaN", ->
					@lsmp.get("molecular weight").set("value", "fred")
					expect(@lsmp.isValid()).toBeFalsy()
					filtErrors = _.filter(@lsmp.validationError, (err) ->
						err.attribute=='molecularWeight'
					)
					expect(filtErrors.length).toBeGreaterThan 0

		describe "When created from existing", ->
			beforeEach ->
				@lsmp = new LinkerSmallMoleculeParent JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@lsmp).toBeDefined()
				it "should have a type", ->
					expect(@lsmp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@lsmp.get('lsKind')).toEqual "linker small molecule"
				it "should have a recordedBy set", ->
					expect(@lsmp.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@lsmp.get('recordedDate')).toEqual 1375141508000
				it "Should have label set", ->
					console.log @lsmp
					expect(@lsmp.get("linker small molecule name").get("labelText")).toEqual "Ad"
					label = (@lsmp.get("lsLabels").getLabelByTypeAndKind("name", "linker small molecule"))
					console.log label[0]
					expect(label[0].get('labelText')).toEqual "Ad"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@lsmp.get('lsStates')).toBeDefined()
					expect(@lsmp.get("lsStates").length).toEqual 1
					expect(@lsmp.get("lsStates").getStatesByTypeAndKind("metadata", "linker small molecule parent").length).toEqual 1
				it "Should have a scientist value", ->
					expect(@lsmp.get("scientist").get("value")).toEqual "john"
				it "Should have a completion date value", ->
					expect(@lsmp.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@lsmp.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a molecular weight value", ->
					expect(@lsmp.get("molecular weight").get("value")).toEqual 231
				it "Should have a structural file value", ->
					expect(@lsmp.get("structural file").get("value")).toEqual "TestFile.mol"

			describe "model validation", ->
				beforeEach ->
					@lsmp = new LinkerSmallMoleculeParent window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent
				it "should be valid when loaded from saved", ->
					expect(@lsmp.isValid()).toBeTruthy()
				it "should be invalid when name is empty", ->
					@lsmp.get("linker small molecule name").set("labelText", "")
					expect(@lsmp.isValid()).toBeFalsy()
					filtErrors = _.filter(@lsmp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when scientist not selected", ->
					@lsmp.get('scientist').set('value', "unassigned")
					expect(@lsmp.isValid()).toBeFalsy()
					filtErrors = _.filter(@lsmp.validationError, (err) ->
						err.attribute=='scientist'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when completion date is empty", ->
					@lsmp.get("completion date").set("value", new Date("").getTime())
					expect(@lsmp.isValid()).toBeFalsy()
					filtErrors = _.filter(@lsmp.validationError, (err) ->
						err.attribute=='completionDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when notebook is empty", ->
					@lsmp.get("notebook").set("value", "")
					expect(@lsmp.isValid()).toBeFalsy()
					filtErrors = _.filter(@lsmp.validationError, (err) ->
						err.attribute=='notebook'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when molecular weight is NaN", ->
					@lsmp.get("molecular weight").set("value", "fred")
					expect(@lsmp.isValid()).toBeFalsy()
					filtErrors = _.filter(@lsmp.validationError, (err) ->
						err.attribute=='molecularWeight'
					)
					expect(filtErrors.length).toBeGreaterThan 0

	describe "Linker Small Molecule Batch model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@lsmb= new LinkerSmallMoleculeBatch()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@lsmb).toBeDefined()
				it "should have a type", ->
					expect(@lsmb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@lsmb.get('lsKind')).toEqual "linker small molecule"
				it "should have a recordedBy set to logged in user", ->
					expect(@lsmb.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@lsmb.get('recordedDate')).getHours()).toEqual new Date().getHours()
				#				it "should have an analytical method file type", ->
				#					expect(@lsmb.get('analyticalFileType')).toEqual "unassigned"
				#				it "should have an analytical method fileValue", ->
				#					expect(@lsmb.get('analyticalFileType')).toEqual "unassigned"
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for scientist", ->
						expect(@lsmb.get("scientist")).toBeDefined()
					it "Should have a model attribute for completion date", ->
						expect(@lsmb.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@lsmb.get("notebook")).toBeDefined()
					it "Should have a model attribute for source", ->
						expect(@lsmb.get("source").get).toBeDefined()
						expect(@lsmb.get("source").get('value')).toEqual "Avidity"
					it "Should have a model attribute for source id", ->
						expect(@lsmb.get("source id")).toBeDefined()
					#					it "Should have a model attribute for analytical method file type", ->
					#						expect(@lsmb.get("analytical file type")).toBeDefined()
					it "Should have a model attribute for purity", ->
						expect(@lsmb.get("purity")).toBeDefined()
					it "Should have a model attribute for amount made", ->
						expect(@lsmb.get("amount made")).toBeDefined()
					it "Should have a model attribute for location", ->
						expect(@lsmb.get("location")).toBeDefined()

		describe "When created from existing", ->
			beforeEach ->
				@lsmb = new LinkerSmallMoleculeBatch JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@lsmb).toBeDefined()
				it "should have a type", ->
					expect(@lsmb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@lsmb.get('lsKind')).toEqual "linker small molecule"
				it "should have a scientist set", ->
					expect(@lsmb.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@lsmb.get('recordedDate')).toEqual 1375141508000
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@lsmb.get('lsStates')).toBeDefined()
					expect(@lsmb.get("lsStates").length).toEqual 2
					expect(@lsmb.get("lsStates").getStatesByTypeAndKind("metadata", "linker small molecule batch").length).toEqual 1
					expect(@lsmb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual 1
				it "Should have a scientist value", ->
					expect(@lsmb.get("scientist").get("value")).toEqual "john"
				it "Should have a completion date value", ->
					expect(@lsmb.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@lsmb.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a source value", ->
					expect(@lsmb.get("source").get("value")).toEqual "Avidity"
				it "Should have a source id", ->
					expect(@lsmb.get("source id").get("value")).toEqual "12345"
				it "Should have a purity value", ->
					expect(@lsmb.get("purity").get("value")).toEqual 92
				it "Should have an amount made value", ->
					expect(@lsmb.get("amount made").get("value")).toEqual 2.3
				it "Should have a location value", ->
					expect(@lsmb.get("location").get("value")).toEqual "Cabinet 1"

		describe "model validation", ->
			beforeEach ->
				@lsmb = new LinkerSmallMoleculeBatch window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch
			it "should be valid when loaded from saved", ->
				expect(@lsmb.isValid()).toBeTruthy()
			it "should be invalid when scientist not selected", ->
				@lsmb.get('scientist').set('value', "unassigned")
				expect(@lsmb.isValid()).toBeFalsy()
				filtErrors = _.filter(@lsmb.validationError, (err) ->
					err.attribute=='scientist'
				)
			it "should be invalid when completion date is empty", ->
				@lsmb.get("completion date").set("value", new Date("").getTime())
				expect(@lsmb.isValid()).toBeFalsy()
				filtErrors = _.filter(@lsmb.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when notebook is empty", ->
				@lsmb.get("notebook").set("value", "")
				expect(@lsmb.isValid()).toBeFalsy()
				filtErrors = _.filter(@lsmb.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when source is not selected", ->
				@lsmb.get("source").set("value", "unassigned")
				expect(@lsmb.isValid()).toBeFalsy()
				filtErrors = _.filter(@lsmb.validationError, (err) ->
					err.attribute=='source'
				)
			it "should be invalid when purity is NaN", ->
				@lsmb.get("purity").set("value", "fred")
				expect(@lsmb.isValid()).toBeFalsy()
				filtErrors = _.filter(@lsmb.validationError, (err) ->
					err.attribute=='purity'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when amount made is NaN", ->
				@lsmb.get("amount made").set("value", "fred")
				expect(@lsmb.isValid()).toBeFalsy()
				filtErrors = _.filter(@lsmb.validationError, (err) ->
					err.attribute=='amountMade'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when location is empty", ->
				@lsmb.get("location").set("value", "")
				expect(@lsmb.isValid()).toBeFalsy()
				filtErrors = _.filter(@lsmb.validationError, (err) ->
					err.attribute=='location'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Linker Small Molecule Parent Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@lsmp = new LinkerSmallMoleculeParent()
				@lsmpc = new LinkerSmallMoleculeParentController
					model: @lsmp
					el: $('#fixture')
				@lsmpc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@lsmpc).toBeDefined()
				it "should load the template", ->
					expect(@lsmpc.$('.bv_parentCode').html()).toEqual "Autofilled when saved"
				it "should load the additional parent attributes temlate", ->
					expect(@lsmpc.$('.bv_molecularWeight').length).toEqual 1
		describe "When instantiated from existing", ->
			beforeEach ->
				@lsmp = new LinkerSmallMoleculeParent JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent))
				@lsmpc = new LinkerSmallMoleculeParentController
					model: @lsmp
					el: $('#fixture')
				@lsmpc.render()
			describe "render existing parameters", ->
				it "should show the linker small molecule parent id", ->
					expect(@lsmpc.$('.bv_parentCode').val()).toEqual "LSM000001"
				it "should fill the linker small molecule parent name", ->
					expect(@lsmpc.$('.bv_parentName').val()).toEqual "Ad"
				it "should fill the scientist field", ->
					waitsFor ->
						@lsmpc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						console.log @lsmpc.$('.bv_scientist').val()
						expect(@lsmpc.$('.bv_scientist').val()).toEqual "john"
				it "should fill the completion date field", ->
					expect(@lsmpc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@lsmpc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the molecular weight field", ->
					expect(@lsmpc.$('.bv_molecularWeight').val()).toEqual "231"

			describe "model updates", ->
				it "should update model when parent name is changed", ->
					@lsmpc.$('.bv_parentName').val(" New name   ")
					@lsmpc.$('.bv_parentName').keyup()
					expect(@lsmpc.model.get('linker small molecule name').get('labelText')).toEqual "New name"
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@lsmpc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@lsmpc.$('.bv_scientist').val('unassigned')
						@lsmpc.$('.bv_scientist').change()
						expect(@lsmpc.model.get('scientist').get('value')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@lsmpc.$('.bv_completionDate').val(" 2013-3-16   ")
					@lsmpc.$('.bv_completionDate').keyup()
					expect(@lsmpc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@lsmpc.$('.bv_notebook').val(" Updated notebook  ")
					@lsmpc.$('.bv_notebook').keyup()
					expect(@lsmpc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when molecular weight is changed", ->
					@lsmpc.$('.bv_molecularWeight').val(" 12  ")
					@lsmpc.$('.bv_molecularWeight').keyup()
					expect(@lsmpc.model.get('molecular weight').get('value')).toEqual 12

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@lsmpc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@lsmpc.$('.bv_parentName').val(" Updated entity name   ")
						@lsmpc.$('.bv_parentName').keyup()
						@lsmpc.$('.bv_scientist').val("bob")
						@lsmpc.$('.bv_scientist').change()
						@lsmpc.$('.bv_completionDate').val(" 2013-3-16   ")
						@lsmpc.$('.bv_completionDate').keyup()
						@lsmpc.$('.bv_notebook').val("my notebook")
						@lsmpc.$('.bv_notebook').keyup()
						@lsmpc.$('.bv_molecularWeight').val(" 24")
						@lsmpc.$('.bv_molecularWeight').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@lsmpc.isValid()).toBeTruthy()
					it "should have the update button be enabled", ->
						runs ->
							expect(@lsmpc.$('.bv_updateParent').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@lsmpc.$('.bv_parentName').val("")
							@lsmpc.$('.bv_parentName').keyup()
					it "should be invalid if name not filled in", ->
						runs ->
							expect(@lsmpc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@lsmpc.$('.bv_group_parentName').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@lsmpc.$('.bv_updateParent').attr('disabled')).toEqual 'disabled'
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@lsmpc.$('.bv_scientist').val("")
							@lsmpc.$('.bv_scientist').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@lsmpc.$('.bv_group_scientist').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@lsmpc.$('.bv_completionDate').val("")
							@lsmpc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@lsmpc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@lsmpc.$('.bv_notebook').val("")
							@lsmpc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@lsmpc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when molecular weight not filled", ->
					beforeEach ->
						runs ->
							@lsmpc.$('.bv_molecularWeight').val("")
							@lsmpc.$('.bv_molecularWeight').keyup()
					it "should show error on molecular weight field", ->
						runs ->
							expect(@lsmpc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy()

	describe "Linker Small Molecule Batch Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@lsmb = new LinkerSmallMoleculeBatch()
				@lsmbc = new LinkerSmallMoleculeBatchController
					model: @lsmb
					el: $('#fixture')
				@lsmbc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@lsmbc).toBeDefined()
				it "should load the template", ->
					expect(@lsmbc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "When instantiated from existing", ->
			beforeEach ->
				@lsmb = new LinkerSmallMoleculeBatch JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch))
				@lsmbc = new LinkerSmallMoleculeBatchController
					model: @lsmb
					el: $('#fixture')
				@lsmbc.render()
			describe "render existing parameters", ->
				it "should show the linker small molecule batch id", ->
					expect(@lsmbc.$('.bv_batchCode').val()).toEqual "LSM000001-1"
				it "should fill the scientist field", ->
					waitsFor ->
						@lsmbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						expect(@lsmbc.$('.bv_scientist').val()).toEqual "john"
				it "should fill the completion date field", ->
					expect(@lsmbc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@lsmbc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the source field", ->
					waitsFor ->
						@lsmbc.$('.bv_source option').length > 0
					, 1000
					runs ->
						expect(@lsmbc.$('.bv_source').val()).toEqual "Avidity"
				it "should fill the source id field", ->
					expect(@lsmbc.$('.bv_sourceId').val()).toEqual "12345"
				it "should fill the purity field", ->
					expect(@lsmbc.$('.bv_purity').val()).toEqual "92"
				it "should fill the amount made field", ->
					expect(@lsmbc.$('.bv_amountMade').val()).toEqual "2.3"
				it "should fill the location field", ->
					expect(@lsmbc.$('.bv_location').val()).toEqual "Cabinet 1"
			describe "model updates", ->
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@lsmbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@lsmbc.$('.bv_scientist').val('unassigned')
						@lsmbc.$('.bv_scientist').change()
						expect(@lsmbc.model.get('scientist').get('value')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@lsmbc.$('.bv_completionDate').val(" 2013-3-16   ")
					@lsmbc.$('.bv_completionDate').keyup()
					expect(@lsmbc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@lsmbc.$('.bv_notebook').val(" Updated notebook  ")
					@lsmbc.$('.bv_notebook').keyup()
					expect(@lsmbc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when the source is changed", ->
					waitsFor ->
						@lsmbc.$('.bv_source option').length > 0
					, 1000
					runs ->
						@lsmbc.$('.bv_source').val('unassigned')
						@lsmbc.$('.bv_source').change()
						expect(@lsmbc.model.get('source').get('value')).toEqual "unassigned"
				it "should update model when source id is changed", ->
					@lsmbc.$('.bv_sourceId').val(" 252  ")
					@lsmbc.$('.bv_sourceId').keyup()
					expect(@lsmbc.model.get('source id').get('value')).toEqual "252"
				it "should update model when purity is changed", ->
					@lsmbc.$('.bv_purity').val(" 29  ")
					@lsmbc.$('.bv_purity').keyup()
					expect(@lsmbc.model.get('purity').get('value')).toEqual 29
				it "should update model when amount made is changed", ->
					@lsmbc.$('.bv_amountMade').val(" 12  ")
					@lsmbc.$('.bv_amountMade').keyup()
					expect(@lsmbc.model.get('amount made').get('value')).toEqual 12
				it "should update model when location is changed", ->
					@lsmbc.$('.bv_location').val(" Updated location  ")
					@lsmbc.$('.bv_location').keyup()
					expect(@lsmbc.model.get('location').get('value')).toEqual "Updated location"

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@lsmbc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@lsmbc.$('.bv_scientist').val("bob")
						@lsmbc.$('.bv_scientist').change()
						@lsmbc.$('.bv_completionDate').val(" 2013-3-16   ")
						@lsmbc.$('.bv_completionDate').keyup()
						@lsmbc.$('.bv_notebook').val("my notebook")
						@lsmbc.$('.bv_notebook').keyup()
						@lsmbc.$('.bv_source').val("vendor A")
						@lsmbc.$('.bv_source').change()
						@lsmbc.$('.bv_sourceId').val(" 24")
						@lsmbc.$('.bv_sourceId').keyup()
						@lsmbc.$('.bv_purity').val(" 82")
						@lsmbc.$('.bv_purity').keyup()
						@lsmbc.$('.bv_amountMade').val(" 24")
						@lsmbc.$('.bv_amountMade').keyup()
						@lsmbc.$('.bv_location').val(" Hood 4")
						@lsmbc.$('.bv_location').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@lsmbc.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							expect(@lsmbc.$('.bv_saveBatch').attr('disabled')).toBeUndefined()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@lsmbc.$('.bv_scientist').val("")
							@lsmbc.$('.bv_scientist').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@lsmbc.$('.bv_group_scientist').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@lsmbc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@lsmbc.$('.bv_completionDate').val("")
							@lsmbc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@lsmbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@lsmbc.$('.bv_notebook').val("")
							@lsmbc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@lsmbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when source not selected", ->
					beforeEach ->
						runs ->
							@lsmbc.$('.bv_source').val("")
							@lsmbc.$('.bv_source').change()
					it "should show error on source dropdown", ->
						runs ->
							expect(@lsmbc.$('.bv_group_source').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@lsmbc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when purity not filled", ->
					beforeEach ->
						runs ->
							@lsmbc.$('.bv_purity').val("")
							@lsmbc.$('.bv_purity').keyup()
					it "should show error on purity  field", ->
						runs ->
							expect(@lsmbc.$('.bv_group_purity').hasClass('error')).toBeTruthy()
				describe "when amount made not filled", ->
					beforeEach ->
						runs ->
							@lsmbc.$('.bv_amountMade').val("")
							@lsmbc.$('.bv_amountMade').keyup()
					it "should show error on amount made field", ->
						runs ->
							expect(@lsmbc.$('.bv_group_amountMade').hasClass('error')).toBeTruthy()
				describe "when location not filled", ->
					beforeEach ->
						runs ->
							@lsmbc.$('.bv_location').val("")
							@lsmbc.$('.bv_location').keyup()
					it "should show error on location field", ->
						runs ->
							expect(@lsmbc.$('.bv_group_location').hasClass('error')).toBeTruthy()

	describe "Linker Small Molecule Batch Select Controller testing", ->
		beforeEach ->
			@lsmb = new LinkerSmallMoleculeBatch()
			@lsmbsc = new LinkerSmallMoleculeBatchSelectController
				model: @lsmb
				el: $('#fixture')
			@lsmbsc.render()
		describe "When instantiated", ->
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@lsmbsc).toBeDefined()
				it "should load the template", ->
					expect(@lsmbsc.$('.bv_batchList').length).toEqual 1
			describe "rendering", ->
				it "should have the batch list default to register new batch", ->
					waitsFor ->
						@lsmbsc.$('.bv_batchList option').length > 0
					, 1000
					runs ->
						expect(@lsmbsc.$('.bv_batchList').val()).toEqual "new batch"
				it "should a new batch registration form", ->
					console.log @lsmbsc.$('.bv_batchCode')
					waitsFor ->
						@lsmbsc.$('.bv_batchList option').length > 0
					, 1000
					runs ->
						expect(@lsmbsc.$('.bv_batchCode').val()).toEqual ""
						expect(@lsmbsc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "behavior", ->
			it "should show the information for a selected batch", ->
				waitsFor ->
					@lsmbsc.$('.bv_batchList option').length > 0
				, 1000
				runs ->
					console.log @lsmbsc.$('.bv_batchList')
					@lsmbsc.$('.bv_batchList').val("CB000001-1")
					@lsmbsc.$('.bv_batchList').change()
				waitsFor ->
					@lsmbsc.$('.bv_scientist option').length > 0
				, 1000
				runs ->
					waits(1000)
				runs ->
					expect(@lsmbsc.$('.bv_batchCode').html()).toEqual "CB000001-1"

	describe "Linker Small Molecule Controller", ->
		beforeEach ->
			@lsmc = new LinkerSmallMoleculeController
				model: new LinkerSmallMoleculeParent()
				el: $('#fixture')
			@lsmc.render()
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@lsmc).toBeDefined()
			it "Should load the template", ->
				expect(@lsmc.$('.bv_save').length).toEqual 1
			it "Should load a parent controller", ->
				expect(@lsmc.$('.bv_parent .bv_parentCode').length).toEqual 1
			it "Should load a batch controller", ->
				waitsFor ->
					@lsmc.$('.bv_batchList option').length > 0
				, 1000
				runs ->
					expect(@lsmc.$('.bv_batch .bv_batchCode').length).toEqual 1
		describe "saving parent/batch for the first time", ->
			describe "when form is initialized", ->
				it "should have the save button be disabled initially", ->
					expect(@lsmc.$('.bv_save').attr('disabled')).toEqual 'disabled'
			describe 'when save is clicked', ->
				beforeEach ->
					waitsFor ->
						@lsmc.$('.bv_fileType option').length > 0
					, 1000
					runs ->
						@lsmc.$('.bv_parentName').val(" Updated entity name   ")
						@lsmc.$('.bv_parentName').keyup()
						@lsmc.$('.bv_scientist').val("bob")
						@lsmc.$('.bv_scientist').change()
						@lsmc.$('.bv_completionDate').val(" 2013-3-16   ")
						@lsmc.$('.bv_completionDate').keyup()
						@lsmc.$('.bv_notebook').val("my notebook")
						@lsmc.$('.bv_notebook').keyup()
						@lsmc.$('.bv_source').val("Avidity")
						@lsmc.$('.bv_source').change()
						@lsmc.$('.bv_sourceId').val("12345")
						@lsmc.$('.bv_sourceId').keyup()
						@lsmc.$('.bv_molecularWeight').val(" 24")
						@lsmc.$('.bv_molecularWeight').keyup()
						@lsmc.$('.bv_purity').val(" 24")
						@lsmc.$('.bv_purity').keyup()
						@lsmc.$('.bv_amountMade').val(" 24")
						@lsmc.$('.bv_amountMade').keyup()
						@lsmc.$('.bv_location').val(" Hood 4")
						@lsmc.$('.bv_location').keyup()
					waitsFor ->
						@lsmc.$('.bv_fileType option').length > 0
					, 1000
				it "should have the save button be enabled", ->
					runs ->
						expect(@lsmc.$('.bv_save').attr('disabled')).toBeUndefined()
