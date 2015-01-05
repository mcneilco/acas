beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Protein testing', ->
	describe "Protein Parent model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@pp = new ProteinParent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@pp).toBeDefined()
				it "should have a type", ->
					expect(@pp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@pp.get('lsKind')).toEqual "protein"
				it "should have an empty scientist", ->
					expect(@pp.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@pp.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with one label", ->
					expect(@pp.get('lsLabels')).toBeDefined()
					expect(@pp.get("lsLabels").length).toEqual 1
					expect(@pp.get("lsLabels").getLabelByTypeAndKind("name", "protein").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@pp.get("protein name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@pp.get('lsStates')).toBeDefined()
					expect(@pp.get("lsStates").length).toEqual 1
					expect(@pp.get("lsStates").getStatesByTypeAndKind("metadata", "protein parent").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for completion date", ->
						expect(@pp.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@pp.get("notebook")).toBeDefined()
					it "Should have a model attribute for type", ->
						expect(@pp.get("type")).toBeDefined()
					it "Should have a model attribute for aa sequence", ->
						expect(@pp.get("aa sequence")).toBeDefined()
			describe "model validation", ->
				it "should be invalid when name is empty", ->
					@pp.get("protein name").set("labelText", "")
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should invalid when recorded date is empty", ->
					@pp.set recordedDate: new Date("").getTime()
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='recordedDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when type is not selected", ->
					@pp.get("type").set("value", "")
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='type'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when aa sequence is not filled", ->
					@pp.get("aa sequence").set("value", "")
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='sequence'
					)
					expect(filtErrors.length).toBeGreaterThan 0

		describe "When created from existing", ->
			beforeEach ->
				@pp = new ProteinParent JSON.parse(JSON.stringify(window.proteinTestJSON.proteinParent))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@pp).toBeDefined()
				it "should have a type", ->
					expect(@pp.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@pp.get('lsKind')).toEqual "protein"
				it "should have a scientist set", ->
					expect(@pp.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@pp.get('recordedDate')).toEqual 1375141508000
				it "Should have label set", ->
					console.log @pp
					expect(@pp.get("protein name").get("labelText")).toEqual "EGFR 31"
					label = (@pp.get("lsLabels").getLabelByTypeAndKind("name", "protein"))
					console.log label[0]
					expect(label[0].get('labelText')).toEqual "EGFR 31"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@pp.get('lsStates')).toBeDefined()
					expect(@pp.get("lsStates").length).toEqual 1
					expect(@pp.get("lsStates").getStatesByTypeAndKind("metadata", "protein parent").length).toEqual 1
				it "Should have a completion date value", ->
					expect(@pp.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@pp.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a type value", ->
					expect(@pp.get("type").get("value")).toEqual "fab"
				it "Should have a sequence value", ->
					expect(@pp.get("aa sequence").get("value")).toEqual "AUGCGACUG"

			describe "model validation", ->
				beforeEach ->
					@pp = new ProteinParent window.proteinTestJSON.proteinParent
				it "should be valid when loaded from saved", ->
					expect(@pp.isValid()).toBeTruthy()
				it "should be invalid when name is empty", ->
					@pp.get("protein name").set("labelText", "")
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when recorded date is empty", ->
					@pp.set recordedDate: new Date("").getTime()
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='recordedDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when scientist not selected", ->
					@pp.set recordedBy: ""
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='recordedBy'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when completion date is empty", ->
					@pp.get("completion date").set("value", new Date("").getTime())
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='completionDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when notebook is empty", ->
					@pp.get("notebook").set("value", "")
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='notebook'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when type is not selected", ->
					@pp.get("type").set("value", "")
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='type'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when aa sequence is empty", ->
					@pp.get("aa sequence").set("value", "")
					expect(@pp.isValid()).toBeFalsy()
					filtErrors = _.filter(@pp.validationError, (err) ->
						err.attribute=='sequence'
					)
					expect(filtErrors.length).toBeGreaterThan 0

	describe "Protein Parent Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@pp = new ProteinParent()
				@ppc = new ProteinParentController
					model: @pp
					el: $('#fixture')
				@ppc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@ppc).toBeDefined()
				it "should load the template", ->
					expect(@ppc.$('.bv_parentCode').html()).toEqual "autofill when saved"
				it "should load the additional parent attributes template", ->
					expect(@ppc.$('.bv_type').length).toEqual 1
		describe "When instantiated from existing", ->
			beforeEach ->
				@pp = new ProteinParent JSON.parse(JSON.stringify(window.proteinTestJSON.proteinParent))
				@ppc = new ProteinParentController
					model: @pp
					el: $('#fixture')
				@ppc.render()
			describe "render existing parameters", ->
				it "should show the protein parent id", ->
					expect(@ppc.$('.bv_parentCode').val()).toEqual "PROT000001"
				it "should fill the protein parent name", ->
					expect(@ppc.$('.bv_parentName').val()).toEqual "EGFR 31"
				it "should fill the scientist field", ->
					waitsFor ->
						@ppc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						console.log @ppc.$('.bv_recordedBy').val()
						expect(@ppc.$('.bv_recordedBy').val()).toEqual "jane"
				it "should fill the completion date field", ->
					expect(@ppc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@ppc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the type field", ->
					waitsFor ->
						@ppc.$('.bv_type option').length > 0
					, 1000
					runs ->
						console.log @ppc.$('.bv_type').val()
						console.log @ppc.model
						expect(@ppc.$('.bv_type').val()).toEqual "fab"
				it "should fill the aa sequence field", ->
					expect(@ppc.$('.bv_sequence').val()).toEqual "AUGCGACUG"

			describe "model updates", ->
				it "should update model when parent name is changed", ->
					@ppc.$('.bv_parentName').val(" New name   ")
					@ppc.$('.bv_parentName').change()
					expect(@ppc.model.get('protein name').get('labelText')).toEqual "New name"
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@ppc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@ppc.$('.bv_recordedBy').val('unassigned')
						@ppc.$('.bv_recordedBy').change()
						expect(@ppc.model.get('recordedBy')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@ppc.$('.bv_completionDate').val(" 2013-3-16   ")
					@ppc.$('.bv_completionDate').change()
					expect(@ppc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@ppc.$('.bv_notebook').val(" Updated notebook  ")
					@ppc.$('.bv_notebook').change()
					expect(@ppc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when the type is changed", ->
					waitsFor ->
						@ppc.$('.bv_type option').length > 0
					, 1000
					runs ->
						@ppc.$('.bv_type').val('unassigned')
						@ppc.$('.bv_type').change()
						expect(@ppc.model.get('type').get('value')).toEqual "unassigned"
				it "should update model when aa sequence is changed", ->
					@ppc.$('.bv_sequence').val(" Updated sequence  ")
					@ppc.$('.bv_sequence').change()
					expect(@ppc.model.get('aa sequence').get('value')).toEqual "Updated sequence"
			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@ppc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@ppc.$('.bv_parentName').val(" Updated entity name   ")
						@ppc.$('.bv_parentName').change()
						@ppc.$('.bv_recordedBy').val("bob")
						@ppc.$('.bv_recordedBy').change()
						@ppc.$('.bv_completionDate').val(" 2013-3-16   ")
						@ppc.$('.bv_completionDate').change()
						@ppc.$('.bv_notebook').val("my notebook")
						@ppc.$('.bv_notebook').change()
						@ppc.$('.bv_type').val("mab")
						@ppc.$('.bv_type').change()
						@ppc.$('.bv_sequence').val("AUG")
						@ppc.$('.bv_sequence').change()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@ppc.isValid()).toBeTruthy()
				#					it "save button should be enabled", ->
				#						runs ->
				#							expect(@ppc.$('.bv_save').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_parentName').val("")
							@ppc.$('.bv_parentName').change()
					it "should be invalid if name not filled in", ->
						runs ->
							expect(@ppc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@ppc.$('.bv_group_parentName').hasClass('error')).toBeTruthy()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_recordedBy').val("")
							@ppc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@ppc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_completionDate').val("")
							@ppc.$('.bv_completionDate').change()
					it "should show error in date field", ->
						runs ->
							expect(@ppc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_notebook').val("")
							@ppc.$('.bv_notebook').change()
					it "should show error on notebook field", ->
						runs ->
							expect(@ppc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when type not filled", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_type').val("unassigned")
							@ppc.$('.bv_type').change()
					it "should show error on type field", ->
						runs ->
							expect(@ppc.$('.bv_group_type').hasClass('error')).toBeTruthy()
				describe "when sequence not filled", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_sequence').val("")
							@ppc.$('.bv_sequence').change()
					it "should show error on sequence field", ->
						runs ->
							expect(@ppc.$('.bv_group_sequence').hasClass('error')).toBeTruthy()

	describe "Protein Batch model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@cbb= new ProteinBatch()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@cbb).toBeDefined()
				it "should have a type", ->
					expect(@cbb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@cbb.get('lsKind')).toEqual "protein"
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
				@cbb = new ProteinBatch JSON.parse(JSON.stringify(window.proteinTestJSON.proteinBatch))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@cbb).toBeDefined()
				it "should have a type", ->
					expect(@cbb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@cbb.get('lsKind')).toEqual "protein"
				it "should have a scientist set", ->
					expect(@cbb.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@cbb.get('recordedDate')).toEqual 1375141508000
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@cbb.get('lsStates')).toBeDefined()
					expect(@cbb.get("lsStates").length).toEqual 2
					expect(@cbb.get("lsStates").getStatesByTypeAndKind("metadata", "protein batch").length).toEqual 1
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
				@cbb = new ProteinBatch window.proteinTestJSON.proteinBatch
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

	describe "Protein Batch Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@cbb = new ProteinBatch()
				@cbbc = new ProteinBatchController
					model: @cbb
					el: $('#fixture')
				@cbbc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@cbbc).toBeDefined()
				it "should load the template", ->
					expect(@cbbc.$('.bv_batchCode').html()).toEqual "autofill when saved"
		describe "When instantiated from existing", ->
			beforeEach ->
				@cbb = new ProteinBatch JSON.parse(JSON.stringify(window.proteinTestJSON.proteinBatch))
				@cbbc = new ProteinBatchController
					model: @cbb
					el: $('#fixture')
				@cbbc.render()
			describe "render existing parameters", ->
				it "should show the protein batch id", ->
					expect(@cbbc.$('.bv_batchCode').val()).toEqual "PROT000001-1"
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
					@cbbc.$('.bv_completionDate').change()
					expect(@cbbc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@cbbc.$('.bv_notebook').val(" Updated notebook  ")
					@cbbc.$('.bv_notebook').change()
					expect(@cbbc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when amount is changed", ->
					@cbbc.$('.bv_amount').val(" 12  ")
					@cbbc.$('.bv_amount').change()
					expect(@cbbc.model.get('amount').get('value')).toEqual 12
				it "should update model when location is changed", ->
					@cbbc.$('.bv_location').val(" Updated location  ")
					@cbbc.$('.bv_location').change()
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
						@cbbc.$('.bv_completionDate').change()
						@cbbc.$('.bv_notebook').val("my notebook")
						@cbbc.$('.bv_notebook').change()
						@cbbc.$('.bv_amount').val(" 24")
						@cbbc.$('.bv_amount').change()
						@cbbc.$('.bv_location').val(" Hood 4")
						@cbbc.$('.bv_location').change()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@cbbc.isValid()).toBeTruthy()
				#					it "save button should be enabled", ->
				#						runs ->
				#							expect(@ppc.$('.bv_save').attr('disabled')).toBeUndefined()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_recordedBy').val("")
							@cbbc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@cbbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_completionDate').val("")
							@cbbc.$('.bv_completionDate').change()
					it "should show error in date field", ->
						runs ->
							expect(@cbbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_notebook').val("")
							@cbbc.$('.bv_notebook').change()
					it "should show error on notebook field", ->
						runs ->
							expect(@cbbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when amount not filled", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_amount').val("")
							@cbbc.$('.bv_amount').change()
					it "should show error on amount field", ->
						runs ->
							expect(@cbbc.$('.bv_group_amount').hasClass('error')).toBeTruthy()
				describe "when location not filled", ->
					beforeEach ->
						runs ->
							@cbbc.$('.bv_location').val("")
							@cbbc.$('.bv_location').change()
					it "should show error on location field", ->
						runs ->
							expect(@cbbc.$('.bv_group_location').hasClass('error')).toBeTruthy()

	describe "Protein Batch Select Controller testing", ->
		beforeEach ->
			@cbb = new ProteinBatch()
			@cbbsc = new ProteinBatchSelectController
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
					expect(@cbbsc.$('.bv_batchCode').html()).toEqual "autofill when saved"
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

	describe "Protein Controller", ->
		beforeEach ->
			@cbc = new ProteinController
				model: new ProteinParent()
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


