beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Cationic Block testing', ->
	describe " Parent model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@cbp = new CationicBlockParent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@cbp).toBeDefined()
				it "should have a type", ->
					expect(@cbp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@cbp.get('lsKind')).toEqual "cationic block"
				it "should have an empty scientist", ->
					expect(@cbp.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@cbp.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with one label", ->
					expect(@cbp.get('lsLabels')).toBeDefined()
					expect(@cbp.get("lsLabels").length).toEqual 1
					expect(@cbp.get("lsLabels").getLabelByTypeAndKind("name", "cationic block").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@cbp.get("cationic block name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@cbp.get('lsStates')).toBeDefined()
					expect(@cbp.get("lsStates").length).toEqual 1
					expect(@cbp.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for completion date", ->
						expect(@cbp.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@cbp.get("notebook")).toBeDefined()
					it "Should have a model attribute for molecular weight", ->
						expect(@cbp.get("molecular weight")).toBeDefined()
			describe "model validation", ->
				it "should be invalid when name is empty", ->
					@cbp.get("cationic block name").set("labelText", "")
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should invalid when recorded date is empty", ->
					@cbp.set recordedDate: new Date("").getTime()
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='recordedDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when molecular weight is NaN", ->
					@cbp.get("molecular weight").set("value", "fred")
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='molecularWeight'
					)
					expect(filtErrors.length).toBeGreaterThan 0

		describe "When created from existing", ->
			beforeEach ->
				@cbp = new CationicBlockParent JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@cbp).toBeDefined()
				it "should have a type", ->
					expect(@cbp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@cbp.get('lsKind')).toEqual "cationic block"
				it "should have a scientist set", ->
					expect(@cbp.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@cbp.get('recordedDate')).toEqual 1375141508000
				it "Should have label set", ->
					console.log @cbp
					expect(@cbp.get("cationic block name").get("labelText")).toEqual "cMAP10"
					label = (@cbp.get("lsLabels").getLabelByTypeAndKind("name", "cationic block"))
					console.log label[0]
					expect(label[0].get('labelText')).toEqual "cMAP10"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@cbp.get('lsStates')).toBeDefined()
					expect(@cbp.get("lsStates").length).toEqual 1
					expect(@cbp.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual 1
				it "Should have a completion date value", ->
					expect(@cbp.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@cbp.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a molecular weight value", ->
					expect(@cbp.get("molecular weight").get("value")).toEqual 231

			describe "model validation", ->
				beforeEach ->
					@cbp = new CationicBlockParent window.cationicBlockTestJSON.cationicBlockParent
				it "should be valid when loaded from saved", ->
					expect(@cbp.isValid()).toBeTruthy()
				it "should be invalid when name is empty", ->
					@cbp.get("cationic block name").set("labelText", "")
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when recorded date is empty", ->
					@cbp.set recordedDate: new Date("").getTime()
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='recordedDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when scientist not selected", ->
					@cbp.set recordedBy: ""
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='recordedBy'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when completion date is empty", ->
					@cbp.get("completion date").set("value", new Date("").getTime())
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='completionDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when notebook is empty", ->
					@cbp.get("notebook").set("value", "")
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='notebook'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when molecular weight is NaN", ->
					@cbp.get("molecular weight").set("value", "fred")
					expect(@cbp.isValid()).toBeFalsy()
					filtErrors = _.filter(@cbp.validationError, (err) ->
						err.attribute=='molecularWeight'
					)
					expect(filtErrors.length).toBeGreaterThan 0

	describe "Cationic Block Parent Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@cbp = new CationicBlockParent()
				@cbpc = new CationicBlockParentController
					model: @cbp
					el: $('#fixture')
				@cbpc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@cbpc).toBeDefined()
				it "should load the template", ->
					expect(@cbpc.$('.bv_parentCode').html()).toEqual "Autofilled when saved"
				it "should load the additional parent attributes temlate", ->
					expect(@cbpc.$('.bv_molecularWeight').length).toEqual 1
		describe "When instantiated from existing", ->
			beforeEach ->
				@cbp = new CationicBlockParent JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent))
				@cbpc = new CationicBlockParentController
					model: @cbp
					el: $('#fixture')
				@cbpc.render()
			describe "render existing parameters", ->
				it "should show the cationic block parent id", ->
					expect(@cbpc.$('.bv_parentCode').val()).toEqual "CB000001"
				it "should fill the cationic block parent name", ->
					expect(@cbpc.$('.bv_parentName').val()).toEqual "cMAP10"
				it "should fill the scientist field", ->
					waitsFor ->
						@cbpc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						console.log @cbpc.$('.bv_recordedBy').val()
						expect(@cbpc.$('.bv_recordedBy').val()).toEqual "jane"
				it "should fill the completion date field", ->
					expect(@cbpc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@cbpc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the molecular weight field", ->
					expect(@cbpc.$('.bv_molecularWeight').val()).toEqual "231"

			describe "model updates", ->
				it "should update model when parent name is changed", ->
					@cbpc.$('.bv_parentName').val(" New name   ")
					@cbpc.$('.bv_parentName').keyup()
					expect(@cbpc.model.get('cationic block name').get('labelText')).toEqual "New name"
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@cbpc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@cbpc.$('.bv_recordedBy').val('unassigned')
						@cbpc.$('.bv_recordedBy').change()
						expect(@cbpc.model.get('recordedBy')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@cbpc.$('.bv_completionDate').val(" 2013-3-16   ")
					@cbpc.$('.bv_completionDate').keyup()
					expect(@cbpc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@cbpc.$('.bv_notebook').val(" Updated notebook  ")
					@cbpc.$('.bv_notebook').keyup()
					expect(@cbpc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when molecular weight is changed", ->
					@cbpc.$('.bv_molecularWeight').val(" 12  ")
					@cbpc.$('.bv_molecularWeight').keyup()
					expect(@cbpc.model.get('molecular weight').get('value')).toEqual 12

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@cbpc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@cbpc.$('.bv_parentName').val(" Updated entity name   ")
						@cbpc.$('.bv_parentName').keyup()
						@cbpc.$('.bv_recordedBy').val("bob")
						@cbpc.$('.bv_recordedBy').change()
						@cbpc.$('.bv_completionDate').val(" 2013-3-16   ")
						@cbpc.$('.bv_completionDate').keyup()
						@cbpc.$('.bv_notebook').val("my notebook")
						@cbpc.$('.bv_notebook').keyup()
						@cbpc.$('.bv_molecularWeight').val(" 24")
						@cbpc.$('.bv_molecularWeight').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@cbpc.isValid()).toBeTruthy()
					it "should have the update button be enabled", ->
						runs ->
							expect(@cbpc.$('.bv_updateParent').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@cbpc.$('.bv_parentName').val("")
							@cbpc.$('.bv_parentName').keyup()
					it "should be invalid if name not filled in", ->
						runs ->
							expect(@cbpc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@cbpc.$('.bv_group_parentName').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@cbpc.$('.bv_updateParent').attr('disabled')).toEqual 'disabled'
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@cbpc.$('.bv_recordedBy').val("")
							@cbpc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@cbpc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@cbpc.$('.bv_completionDate').val("")
							@cbpc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@cbpc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@cbpc.$('.bv_notebook').val("")
							@cbpc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@cbpc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when molecular weight not filled", ->
					beforeEach ->
						runs ->
							@cbpc.$('.bv_molecularWeight').val("")
							@cbpc.$('.bv_molecularWeight').keyup()
					it "should show error on molecular weight field", ->
						runs ->
							expect(@cbpc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy()

	describe "Cationic Block Batch model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@cbb= new CationicBlockBatch()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@cbb).toBeDefined()
				it "should have a type", ->
					expect(@cbb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@cbb.get('lsKind')).toEqual "cationic block"
				it "should have an empty scientist", ->
					expect(@cbb.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@cbb.get('recordedDate')).getHours()).toEqual new Date().getHours()
				#				it "should have an analytical method file type", ->
				#					expect(@cbb.get('analyticalFileType')).toEqual "unassigned"
				#				it "should have an analytical method fileValue", ->
				#					expect(@cbb.get('analyticalFileType')).toEqual "unassigned"
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for completion date", ->
						expect(@cbb.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@cbb.get("notebook")).toBeDefined()
					#					it "Should have a model attribute for analytical method file type", ->
					#						expect(@cbb.get("analytical file type")).toBeDefined()
					it "Should have a model attribute for amount", ->
						expect(@cbb.get("amount")).toBeDefined()
					it "Should have a model attribute for location", ->
						expect(@cbb.get("location")).toBeDefined()

		describe "When created from existing", ->
			beforeEach ->
				@cbb = new CationicBlockBatch JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockBatch))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@cbb).toBeDefined()
				it "should have a type", ->
					expect(@cbb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@cbb.get('lsKind')).toEqual "cationic block"
				it "should have a scientist set", ->
					expect(@cbb.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@cbb.get('recordedDate')).toEqual 1375141508000
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@cbb.get('lsStates')).toBeDefined()
					expect(@cbb.get("lsStates").length).toEqual 2
					expect(@cbb.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block batch").length).toEqual 1
					expect(@cbb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual 1
				it "Should have a completion date value", ->
					expect(@cbb.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@cbb.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have an amount value", ->
					expect(@cbb.get("amount").get("value")).toEqual 2.3
				it "Should have a location value", ->
					expect(@cbb.get("location").get("value")).toEqual "Cabinet 1"

		describe "model validation", ->
			beforeEach ->
				@cbb = new CationicBlockBatch window.cationicBlockTestJSON.cationicBlockBatch
			it "should be valid when loaded from saved", ->
				expect(@cbb.isValid()).toBeTruthy()
			it "should be invalid when recorded date is empty", ->
				@cbb.set recordedDate: new Date("").getTime()
				expect(@cbb.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbb.validationError, (err) ->
					err.attribute=='recordedDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when scientist not selected", ->
				@cbb.set recordedBy: ""
				expect(@cbb.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbb.validationError, (err) ->
					err.attribute=='recordedBy'
				)
			it "should be invalid when completion date is empty", ->
				@cbb.get("completion date").set("value", new Date("").getTime())
				expect(@cbb.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbb.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when notebook is empty", ->
				@cbb.get("notebook").set("value", "")
				expect(@cbb.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbb.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when amount is NaN", ->
				@cbb.get("amount").set("value", "fred")
				expect(@cbb.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbb.validationError, (err) ->
					err.attribute=='amount'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when location is empty", ->
				@cbb.get("location").set("value", "")
				expect(@cbb.isValid()).toBeFalsy()
				filtErrors = _.filter(@cbb.validationError, (err) ->
					err.attribute=='location'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Cationic Block Batch Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@cbb = new CationicBlockBatch()
				@cbbc = new CationicBlockBatchController
					model: @cbb
					el: $('#fixture')
				@cbbc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@cbbc).toBeDefined()
				it "should load the template", ->
					expect(@cbbc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "When instantiated from existing", ->
			beforeEach ->
				@cbb = new CationicBlockBatch JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockBatch))
				@cbbc = new CationicBlockBatchController
					model: @cbb
					el: $('#fixture')
				@cbbc.render()
			describe "render existing parameters", ->
				it "should show the cationic block batch id", ->
					expect(@cbbc.$('.bv_batchCode').val()).toEqual "CB000001-1"
				it "should fill the scientist field", ->
					waitsFor ->
						@cbbc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						expect(@cbbc.$('.bv_recordedBy').val()).toEqual "jane"
				it "should fill the completion date field", ->
					expect(@cbbc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@cbbc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the amount field", ->
					expect(@cbbc.$('.bv_amount').val()).toEqual "2.3"
				it "should fill the location field", ->
					expect(@cbbc.$('.bv_location').val()).toEqual "Cabinet 1"
			describe "model updates", ->
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@cbbc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@cbbc.$('.bv_recordedBy').val('unassigned')
						@cbbc.$('.bv_recordedBy').change()
						expect(@cbbc.model.get('recordedBy')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@cbbc.$('.bv_completionDate').val(" 2013-3-16   ")
					@cbbc.$('.bv_completionDate').keyup()
					expect(@cbbc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@cbbc.$('.bv_notebook').val(" Updated notebook  ")
					@cbbc.$('.bv_notebook').keyup()
					expect(@cbbc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when amount is changed", ->
					@cbbc.$('.bv_amount').val(" 12  ")
					@cbbc.$('.bv_amount').keyup()
					expect(@cbbc.model.get('amount').get('value')).toEqual 12
				it "should update model when location is changed", ->
					@cbbc.$('.bv_location').val(" Updated location  ")
					@cbbc.$('.bv_location').keyup()
					expect(@cbbc.model.get('location').get('value')).toEqual "Updated location"

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@cbbc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@cbbc.$('.bv_recordedBy').val("bob")
						@cbbc.$('.bv_recordedBy').change()
						@cbbc.$('.bv_completionDate').val(" 2013-3-16   ")
						@cbbc.$('.bv_completionDate').keyup()
						@cbbc.$('.bv_notebook').val("my notebook")
						@cbbc.$('.bv_notebook').keyup()
						@cbbc.$('.bv_amount').val(" 24")
						@cbbc.$('.bv_amount').keyup()
						@cbbc.$('.bv_location').val(" Hood 4")
						@cbbc.$('.bv_location').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@cbbc.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							expect(@cbbc.$('.bv_saveBatch').attr('disabled')).toBeUndefined()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_recordedBy').val("")
							@cbbc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@cbbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@cbbc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_completionDate').val("")
							@cbbc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@cbbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_notebook').val("")
							@cbbc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@cbbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when amount not filled", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_amount').val("")
							@cbbc.$('.bv_amount').keyup()
					it "should show error on amount field", ->
						runs ->
							expect(@cbbc.$('.bv_group_amount').hasClass('error')).toBeTruthy()
				describe "when location not filled", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_location').val("")
							@cbbc.$('.bv_location').keyup()
					it "should show error on location field", ->
						runs ->
							expect(@cbbc.$('.bv_group_location').hasClass('error')).toBeTruthy()

	describe "Cationic Block Batch Select Controller testing", ->
		beforeEach ->
			@cbb = new CationicBlockBatch()
			@cbbsc = new CationicBlockBatchSelectController
				model: @cbb
				el: $('#fixture')
			@cbbsc.render()
		describe "When instantiated", ->
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@cbbsc).toBeDefined()
				it "should load the template", ->
					expect(@cbbsc.$('.bv_batchList').length).toEqual 1
			describe "rendering", ->
				it "should have the batch list default to register new batch", ->
					waitsFor ->
						@cbbsc.$('.bv_batchList option').length > 0
					, 1000
					runs ->
						expect(@cbbsc.$('.bv_batchList').val()).toEqual "new batch"
				it "should a new batch registration form", ->
					console.log @cbbsc.$('.bv_batchCode')
					expect(@cbbsc.$('.bv_batchCode').val()).toEqual ""
					expect(@cbbsc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "behavior", ->
			it "should show the information for a selected batch", ->
				waitsFor ->
					@cbbsc.$('.bv_batchList option').length > 0
				, 1000
				runs ->
					console.log @cbbsc.$('.bv_batchList')
					@cbbsc.$('.bv_batchList').val("CB000001-1")
					@cbbsc.$('.bv_batchList').change()
				waitsFor ->
					@cbbsc.$('.bv_recordedBy option').length > 0
				, 1000
				runs ->
					waits(1000)
				runs ->
					expect(@cbbsc.$('.bv_batchCode').html()).toEqual "CB000001-1"
					expect(@cbbsc.$('.bv_recordedBy').val()).toEqual "jane"

	describe "Cationic Block Controller", ->
		beforeEach ->
			@cbc = new CationicBlockController
				model: new CationicBlockParent()
				el: $('#fixture')
			@cbc.render()
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@cbc).toBeDefined()
			it "Should load the template", ->
				expect(@cbc.$('.bv_save').length).toEqual 1
			it "Should load a parent controller", ->
				expect(@cbc.$('.bv_parent .bv_parentCode').length).toEqual 1
			it "Should load a batch controller", ->
				expect(@cbc.$('.bv_batch .bv_batchCode').length).toEqual 1
		describe "saving parent/batch for the first time", ->
			describe "when form is initialized", ->
				it "should have the save button be disabled initially", ->
					expect(@cbc.$('.bv_save').attr('disabled')).toEqual 'disabled'
			describe 'when save is clicked', ->
				beforeEach ->
					runs ->
						@cbc.$('.bv_parentName').val(" Updated entity name   ")
						@cbc.$('.bv_parentName').keyup()
						@cbc.$('.bv_recordedBy').val("bob")
						@cbc.$('.bv_recordedBy').change()
						@cbc.$('.bv_completionDate').val(" 2013-3-16   ")
						@cbc.$('.bv_completionDate').keyup()
						@cbc.$('.bv_notebook').val("my notebook")
						@cbc.$('.bv_notebook').keyup()
						@cbc.$('.bv_molecularWeight').val(" 24")
						@cbc.$('.bv_molecularWeight').keyup()
						@cbc.$('.bv_amount').val(" 24")
						@cbc.$('.bv_amount').keyup()
						@cbc.$('.bv_location').val(" Hood 4")
						@cbc.$('.bv_location').keyup()
					waitsFor ->
						@cbc.$('.bv_recordedBy option').length > 0
					, 1000
				it "should have the save button be enabled", ->
					runs ->
						expect(@cbc.$('.bv_save').attr('disabled')).toBeUndefined()
				it "should update the parent code", ->
					runs ->
						@cbc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@cbc.$('.bv_parentCode').html()).toEqual "CB000001"
				it "should update the batch code", ->
					runs ->
						@cbc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@cbc.$('.bv_batchCode').html()).toEqual "CB000001-1"
				it "should show the update parent button", ->
					runs ->
						@cbc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@cbc.$('.bv_updateParent')).toBeVisible()
				it "should show the update batch button", ->
					runs ->
						@cbc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@cbc.$('.bv_saveBatch')).toBeVisible()
