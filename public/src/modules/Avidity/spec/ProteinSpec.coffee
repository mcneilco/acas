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
					expect(@ppc.$('.bv_parentCode').html()).toEqual "Autofilled when saved"
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
					@ppc.$('.bv_parentName').keyup()
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
					@ppc.$('.bv_completionDate').keyup()
					expect(@ppc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@ppc.$('.bv_notebook').val(" Updated notebook  ")
					@ppc.$('.bv_notebook').keyup()
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
					@ppc.$('.bv_sequence').keyup()
					expect(@ppc.model.get('aa sequence').get('value')).toEqual "Updated sequence"
			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@ppc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@ppc.$('.bv_parentName').val(" Updated entity name   ")
						@ppc.$('.bv_parentName').keyup()
						@ppc.$('.bv_recordedBy').val("bob")
						@ppc.$('.bv_recordedBy').change()
						@ppc.$('.bv_completionDate').val(" 2013-3-16   ")
						@ppc.$('.bv_completionDate').keyup()
						@ppc.$('.bv_notebook').val("my notebook")
						@ppc.$('.bv_notebook').keyup()
						@ppc.$('.bv_type').val("mab")
						@ppc.$('.bv_type').change()
						@ppc.$('.bv_sequence').val("AUG")
						@ppc.$('.bv_sequence').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@ppc.isValid()).toBeTruthy()
					it "should have the update button be enabled", ->
						runs ->
							expect(@ppc.$('.bv_updateParent').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_parentName').val("")
							@ppc.$('.bv_parentName').keyup()
					it "should be invalid if name not filled in", ->
						runs ->
							expect(@ppc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@ppc.$('.bv_group_parentName').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@ppc.$('.bv_updateParent').attr('disabled')).toEqual 'disabled'
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
							@ppc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@ppc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@ppc.$('.bv_notebook').val("")
							@ppc.$('.bv_notebook').keyup()
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
							@ppc.$('.bv_sequence').keyup()
					it "should show error on sequence field", ->
						runs ->
							expect(@ppc.$('.bv_group_sequence').hasClass('error')).toBeTruthy()

	describe "Protein Batch model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@pb= new ProteinBatch()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@pb).toBeDefined()
				it "should have a type", ->
					expect(@pb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@pb.get('lsKind')).toEqual "protein"
				it "should have an empty scientist", ->
					expect(@pb.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@pb.get('recordedDate')).getHours()).toEqual new Date().getHours()
				#				it "should have an analytical method file type", ->
				#					expect(@pb.get('analyticalFileType')).toEqual "unassigned"
				#				it "should have an analytical method fileValue", ->
				#					expect(@pb.get('analyticalFileType')).toEqual "unassigned"
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for completion date", ->
						expect(@pb.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@pb.get("notebook")).toBeDefined()
					it "Should have a model attribute for source", ->
						expect(@pb.get("source").get).toBeDefined()
						expect(@pb.get("source").get('value')).toEqual "Avidity"
					it "Should have a model attribute for source id", ->
						expect(@pb.get("source id")).toBeDefined()
					#					it "Should have a model attribute for analytical method file type", ->
					#						expect(@pb.get("analytical file type")).toBeDefined()
					it "Should have a model attribute for amount made", ->
						expect(@pb.get("amount made")).toBeDefined()
					it "Should have a model attribute for location", ->
						expect(@pb.get("location")).toBeDefined()

		describe "When created from existing", ->
			beforeEach ->
				@pb = new ProteinBatch JSON.parse(JSON.stringify(window.proteinTestJSON.proteinBatch))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@pb).toBeDefined()
				it "should have a type", ->
					expect(@pb.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@pb.get('lsKind')).toEqual "protein"
				it "should have a scientist set", ->
					expect(@pb.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@pb.get('recordedDate')).toEqual 1375141508000
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@pb.get('lsStates')).toBeDefined()
					expect(@pb.get("lsStates").length).toEqual 2
					expect(@pb.get("lsStates").getStatesByTypeAndKind("metadata", "protein batch").length).toEqual 1
					expect(@pb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual 1
				it "Should have a completion date value", ->
					expect(@pb.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@pb.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a source value", ->
					expect(@pb.get("source").get("value")).toEqual "Avidity"
				it "Should have a source id", ->
					expect(@pb.get("source id").get("value")).toEqual "12345"
				it "Should have an amount made value", ->
					expect(@pb.get("amount made").get("value")).toEqual 2.3
				it "Should have a location value", ->
					expect(@pb.get("location").get("value")).toEqual "Cabinet 1"

		describe "model validation", ->
			beforeEach ->
				@pb = new ProteinBatch window.proteinTestJSON.proteinBatch
			it "should be valid when loaded from saved", ->
				expect(@pb.isValid()).toBeTruthy()
			it "should be invalid when recorded date is empty", ->
				@pb.set recordedDate: new Date("").getTime()
				expect(@pb.isValid()).toBeFalsy()
				filtErrors = _.filter(@pb.validationError, (err) ->
					err.attribute=='recordedDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when scientist not selected", ->
				@pb.set recordedBy: ""
				expect(@pb.isValid()).toBeFalsy()
				filtErrors = _.filter(@pb.validationError, (err) ->
					err.attribute=='recordedBy'
				)
			it "should be invalid when completion date is empty", ->
				@pb.get("completion date").set("value", new Date("").getTime())
				expect(@pb.isValid()).toBeFalsy()
				filtErrors = _.filter(@pb.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when notebook is empty", ->
				@pb.get("notebook").set("value", "")
				expect(@pb.isValid()).toBeFalsy()
				filtErrors = _.filter(@pb.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when source is not selected", ->
				@pb.get("source").set("value", "unassigned")
				expect(@pb.isValid()).toBeFalsy()
				filtErrors = _.filter(@pb.validationError, (err) ->
					err.attribute=='source'
				)
			it "should be invalid when amount made is NaN", ->
				@pb.get("amount made").set("value", "fred")
				expect(@pb.isValid()).toBeFalsy()
				filtErrors = _.filter(@pb.validationError, (err) ->
					err.attribute=='amountMade'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when location is empty", ->
				@pb.get("location").set("value", "")
				expect(@pb.isValid()).toBeFalsy()
				filtErrors = _.filter(@pb.validationError, (err) ->
					err.attribute=='location'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Protein Batch Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@pb = new ProteinBatch()
				@pbc = new ProteinBatchController
					model: @pb
					el: $('#fixture')
				@pbc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@pbc).toBeDefined()
				it "should load the template", ->
					expect(@pbc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "When instantiated from existing", ->
			beforeEach ->
				@pb = new ProteinBatch JSON.parse(JSON.stringify(window.proteinTestJSON.proteinBatch))
				@pbc = new ProteinBatchController
					model: @pb
					el: $('#fixture')
				@pbc.render()
			describe "render existing parameters", ->
				it "should show the protein batch id", ->
					expect(@pbc.$('.bv_batchCode').val()).toEqual "PROT000001-1"
				it "should fill the scientist field", ->
					waitsFor ->
						@pbc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_recordedBy').val()).toEqual "jane"
				it "should fill the completion date field", ->
					expect(@pbc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@pbc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the source field", ->
					waitsFor ->
						@pbc.$('.bv_source option').length > 0
					, 1000
					runs ->
						expect(@pbc.$('.bv_source').val()).toEqual "Avidity"
				it "should fill the source id field", ->
					expect(@pbc.$('.bv_sourceId').val()).toEqual "12345"
				it "should fill the amount made field", ->
					expect(@pbc.$('.bv_amountMade').val()).toEqual "2.3"
				it "should fill the location field", ->
					expect(@pbc.$('.bv_location').val()).toEqual "Cabinet 1"
			describe "model updates", ->
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@pbc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_recordedBy').val('unassigned')
						@pbc.$('.bv_recordedBy').change()
						expect(@pbc.model.get('recordedBy')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@pbc.$('.bv_completionDate').val(" 2013-3-16   ")
					@pbc.$('.bv_completionDate').keyup()
					expect(@pbc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@pbc.$('.bv_notebook').val(" Updated notebook  ")
					@pbc.$('.bv_notebook').keyup()
					expect(@pbc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when the source is changed", ->
					waitsFor ->
						@pbc.$('.bv_source option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_source').val('unassigned')
						@pbc.$('.bv_source').change()
						expect(@pbc.model.get('source').get('value')).toEqual "unassigned"
				it "should update model when source id is changed", ->
					@pbc.$('.bv_sourceId').val(" 252  ")
					@pbc.$('.bv_sourceId').keyup()
					expect(@pbc.model.get('source id').get('value')).toEqual "252"
				it "should update model when amount made is changed", ->
					@pbc.$('.bv_amountMade').val(" 12  ")
					@pbc.$('.bv_amountMade').keyup()
					expect(@pbc.model.get('amount made').get('value')).toEqual 12
				it "should update model when location is changed", ->
					@pbc.$('.bv_location').val(" Updated location  ")
					@pbc.$('.bv_location').keyup()
					expect(@pbc.model.get('location').get('value')).toEqual "Updated location"

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@pbc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@pbc.$('.bv_recordedBy').val("bob")
						@pbc.$('.bv_recordedBy').change()
						@pbc.$('.bv_completionDate').val(" 2013-3-16   ")
						@pbc.$('.bv_completionDate').keyup()
						@pbc.$('.bv_notebook').val("my notebook")
						@pbc.$('.bv_notebook').keyup()
						@pbc.$('.bv_source').val("vendor A")
						@pbc.$('.bv_source').change()
						@pbc.$('.bv_sourceId').val(" 24")
						@pbc.$('.bv_sourceId').keyup()
						@pbc.$('.bv_amountMade').val(" 24")
						@pbc.$('.bv_amountMade').keyup()
						@pbc.$('.bv_location').val(" Hood 4")
						@pbc.$('.bv_location').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@pbc.isValid()).toBeTruthy()
					it "save button should be enabled", ->
						runs ->
							expect(@pbc.$('.bv_saveBatch').attr('disabled')).toBeUndefined()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_recordedBy').val("")
							@pbc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@pbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@pbc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_completionDate').val("")
							@pbc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@pbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_notebook').val("")
							@pbc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@pbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when source not selected", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_source').val("")
							@pbc.$('.bv_source').change()
					it "should show error on source dropdown", ->
						runs ->
							expect(@pbc.$('.bv_group_source').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@pbc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when amount made not filled", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_amountMade').val("")
							@pbc.$('.bv_amountMade').keyup()
					it "should show error on amount made field", ->
						runs ->
							expect(@pbc.$('.bv_group_amountMade').hasClass('error')).toBeTruthy()
				describe "when location not filled", ->
					beforeEach ->
						runs ->
							@pbc.$('.bv_location').val("")
							@pbc.$('.bv_location').keyup()
					it "should show error on location field", ->
						runs ->
							expect(@pbc.$('.bv_group_location').hasClass('error')).toBeTruthy()

	describe "Protein Batch Select Controller testing", ->
		beforeEach ->
			@pb = new ProteinBatch()
			@pbsc = new ProteinBatchSelectController
				model: @pb
				el: $('#fixture')
			@pbsc.render()
		describe "When instantiated", ->
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@pbsc).toBeDefined()
				it "should load the template", ->
					expect(@pbsc.$('.bv_batchList').length).toEqual 1
			describe "rendering", ->
				it "should have the batch list default to register new batch", ->
					waitsFor ->
						@pbsc.$('.bv_batchList option').length > 0
					, 1000
					runs ->
						expect(@pbsc.$('.bv_batchList').val()).toEqual "new batch"
				it "should a new batch registration form", ->
					console.log @pbsc.$('.bv_batchCode')
					expect(@pbsc.$('.bv_batchCode').val()).toEqual ""
					expect(@pbsc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "behavior", ->
			it "should show the information for a selected batch", ->
				waitsFor ->
					@pbsc.$('.bv_batchList option').length > 0
				, 1000
				runs ->
					console.log @pbsc.$('.bv_batchList')
					@pbsc.$('.bv_batchList').val("CB000001-1")
					@pbsc.$('.bv_batchList').change()
				waitsFor ->
					@pbsc.$('.bv_recordedBy option').length > 0
				, 1000
				runs ->
					waits(1000)
				runs ->
					expect(@pbsc.$('.bv_batchCode').html()).toEqual "CB000001-1"
					expect(@pbsc.$('.bv_recordedBy').val()).toEqual "jane"

	describe "Protein Controller", ->
		beforeEach ->
			@pc = new ProteinController
				model: new ProteinParent()
				el: $('#fixture')
			@pc.render()
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@pc).toBeDefined()
			it "Should load the template", ->
				expect(@pc.$('.bv_save').length).toEqual 1
			it "Should load a parent controller", ->
				expect(@pc.$('.bv_parent .bv_parentCode').length).toEqual 1
			it "Should load a batch controller", ->
				expect(@pc.$('.bv_batch .bv_batchCode').length).toEqual 1
		describe "saving parent/batch for the first time", ->
			describe "when form is initialized", ->
				it "should have the save button be disabled initially", ->
					expect(@pc.$('.bv_save').attr('disabled')).toEqual 'disabled'
			describe 'when save is clicked', ->
				beforeEach ->
					runs ->
						@pc.$('.bv_parentName').val(" Updated entity name   ")
						@pc.$('.bv_parentName').keyup()
						@pc.$('.bv_recordedBy').val("bob")
						@pc.$('.bv_recordedBy').change()
						@pc.$('.bv_completionDate').val(" 2013-3-16   ")
						@pc.$('.bv_completionDate').keyup()
						@pc.$('.bv_notebook').val("my notebook")
						@pc.$('.bv_notebook').keyup()
						@pc.$('.bv_type').val(" mab")
						@pc.$('.bv_type').change()
						@pc.$('.bv_sequence').val(" AUC")
						@pc.$('.bv_sequence').keyup()
						@pc.$('.bv_source').val("Avidity")
						@pc.$('.bv_source').change()
						@pc.$('.bv_sourceId').val("12345")
						@pc.$('.bv_sourceId').keyup()
						@pc.$('.bv_amountMade').val(" 24")
						@pc.$('.bv_amountMade').keyup()
						@pc.$('.bv_location').val(" Hood 4")
						@pc.$('.bv_location').keyup()
					waitsFor ->
						@pc.$('.bv_recordedBy option').length > 0
					, 1000
				it "should have the save button be enabled", ->
					runs ->
						expect(@pc.$('.bv_save').attr('disabled')).toBeUndefined()
				it "should update the parent code", ->
					runs ->
						@pc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@pc.$('.bv_parentCode').html()).toEqual "PROT000001"
				it "should update the batch code", ->
					runs ->
						@pc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@pc.$('.bv_batchCode').html()).toEqual "PROT000001-1"
				it "should show the update parent button", ->
					runs ->
						@pc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@pc.$('.bv_updateParent')).toBeVisible()
				it "should show the update batch button", ->
					runs ->
						@pc.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@pc.$('.bv_saveBatch')).toBeVisible()


