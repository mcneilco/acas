beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Internalization Agent testing', ->
	describe "Internalization Agent Parent model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@iap = new InternalizationAgentParent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@iap).toBeDefined()
				it "should have a type", ->
					expect(@iap.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@iap.get('lsKind')).toEqual "internalization agent"
				it "should have an empty scientist", ->
					expect(@iap.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@iap.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with one label", ->
					expect(@iap.get('lsLabels')).toBeDefined()
					expect(@iap.get("lsLabels").length).toEqual 1
					expect(@iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@iap.get("internalization agent name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@iap.get('lsStates')).toBeDefined()
					expect(@iap.get("lsStates").length).toEqual 1
					expect(@iap.get("lsStates").getStatesByTypeAndKind("metadata", "internalization agent parent").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for completion date", ->
						expect(@iap.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@iap.get("notebook")).toBeDefined()
					it "Should have a model attribute for conjugation type", ->
						expect(@iap.get("conjugation type")).toBeDefined()
					it "Should have a model attribute for conjugation site", ->
						expect(@iap.get("conjugation site")).toBeDefined()
			describe "model validation", ->
				it "should be invalid when name is empty", ->
					@iap.get("internalization agent name").set("labelText", "")
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should invalid when recorded date is empty", ->
					@iap.set recordedDate: new Date("").getTime()
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='recordedDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when conjugation type is not selected", ->
					@iap.get("conjugation type").set("value", "unassigned")
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='conjugationType'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when conjugation site is not selected", ->
					@iap.get("conjugation site").set("value", "unassigned")
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='conjugationSite'
					)
					expect(filtErrors.length).toBeGreaterThan 0

		describe "When created from existing", ->
			beforeEach ->
				@iap = new InternalizationAgentParent JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@iap).toBeDefined()
				it "should have a type", ->
					expect(@iap.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@iap.get('lsKind')).toEqual "internalization agent"
				it "should have a scientist set", ->
					expect(@iap.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@iap.get('recordedDate')).toEqual 1375141508000
				it "Should have label set", ->
					console.log @iap
					expect(@iap.get("internalization agent name").get("labelText")).toEqual "EGRF 31-PEG10-Ad"
					label = (@iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent"))
					console.log label[0]
					expect(label[0].get('labelText')).toEqual "EGRF 31-PEG10-Ad"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@iap.get('lsStates')).toBeDefined()
					expect(@iap.get("lsStates").length).toEqual 1
					expect(@iap.get("lsStates").getStatesByTypeAndKind("metadata", "internalization agent parent").length).toEqual 1
				it "Should have a completion date value", ->
					expect(@iap.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@iap.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a conjugation type value", ->
					expect(@iap.get("conjugation type").get("value")).toEqual "conjugated"
				it "Should have a conjugation site value", ->
					expect(@iap.get("conjugation site").get("value")).toEqual "cys"

			describe "model validation", ->
				beforeEach ->
					@iap = new InternalizationAgentParent window.internalizationAgentTestJSON.internalizationAgentParent
				it "should be valid when loaded from saved", ->
					expect(@iap.isValid()).toBeTruthy()
				it "should be invalid when name is empty", ->
					@iap.get("internalization agent name").set("labelText", "")
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='parentName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when recorded date is empty", ->
					@iap.set recordedDate: new Date("").getTime()
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='recordedDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when scientist not selected", ->
					@iap.set recordedBy: ""
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='recordedBy'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when completion date is empty", ->
					@iap.get("completion date").set("value", new Date("").getTime())
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='completionDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when notebook is empty", ->
					@iap.get("notebook").set("value", "")
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='notebook'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when conjugation type is not selected", ->
					@iap.get("conjugation type").set("value", "unassigned")
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='conjugationType'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when conjugation site is not selected", ->
					@iap.get("conjugation site").set("value", "unassigned")
					expect(@iap.isValid()).toBeFalsy()
					filtErrors = _.filter(@iap.validationError, (err) ->
						err.attribute=='conjugationSite'
					)
					expect(filtErrors.length).toBeGreaterThan 0

	describe "InternalizationAgent Parent Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@iap = new InternalizationAgentParent()
				@iapc = new InternalizationAgentParentController
					model: @iap
					el: $('#fixture')
				@iapc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@iapc).toBeDefined()
				it "should load the template", ->
					expect(@iapc.$('.bv_parentCode').html()).toEqual "Autofilled when saved"
				it "should load the additional parent attributes template", ->
					expect(@iapc.$('.bv_conjugationType').length).toEqual 1
		describe "When instantiated from existing", ->
			beforeEach ->
				@iap = new InternalizationAgentParent JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent))
				@iapc = new InternalizationAgentParentController
					model: @iap
					el: $('#fixture')
				@iapc.render()
			describe "render existing parameters", ->
				it "should show the internalization agent parent id", ->
					expect(@iapc.$('.bv_parentCode').val()).toEqual "I000001"
				it "should fill the internalization agent parent name", ->
					expect(@iapc.$('.bv_parentName').val()).toEqual "EGRF 31-PEG10-Ad"
				it "should fill the scientist field", ->
					waitsFor ->
						@iapc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						console.log @iapc.$('.bv_recordedBy').val()
						expect(@iapc.$('.bv_recordedBy').val()).toEqual "jane"
				it "should fill the completion date field", ->
					expect(@iapc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@iapc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the conjugation type field", ->
					waitsFor ->
						@iapc.$('.bv_conjugationType option').length > 0
					, 1000
					runs ->
						console.log @iapc.$('.bv_conjugationType').val()
						console.log @iapc.model
						expect(@iapc.$('.bv_conjugationType').val()).toEqual "conjugated"
				it "should fill the conjugation site field", ->
					waitsFor ->
						@iapc.$('.bv_conjugationSite option').length > 0
					, 1000
					runs ->
						console.log @iapc.$('.bv_conjugationSite').val()
						console.log @iapc.model
						expect(@iapc.$('.bv_conjugationSite').val()).toEqual "cys"

			describe "model updates", ->
				it "should update model when parent name is changed", ->
					@iapc.$('.bv_parentName').val(" New name   ")
					@iapc.$('.bv_parentName').change()
					expect(@iapc.model.get('internalization agent name').get('labelText')).toEqual "New name"
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@iapc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@iapc.$('.bv_recordedBy').val('unassigned')
						@iapc.$('.bv_recordedBy').change()
						expect(@iapc.model.get('recordedBy')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@iapc.$('.bv_completionDate').val(" 2013-3-16   ")
					@iapc.$('.bv_completionDate').change()
					expect(@iapc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@iapc.$('.bv_notebook').val(" Updated notebook  ")
					@iapc.$('.bv_notebook').change()
					expect(@iapc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when the conjugation type is changed", ->
					waitsFor ->
						@iapc.$('.bv_conjugationType option').length > 0
					, 1000
					runs ->
						@iapc.$('.bv_conjugationType').val('unassigned')
						@iapc.$('.bv_conjugationType').change()
						expect(@iapc.model.get('conjugation type').get('value')).toEqual "unassigned"
				it "should update model when the conjugation site is changed", ->
					waitsFor ->
						@iapc.$('.bv_conjugationSite option').length > 0
					, 1000
					runs ->
						@iapc.$('.bv_conjugationSite').val('unassigned')
						@iapc.$('.bv_conjugationSite').change()
						expect(@iapc.model.get('conjugation site').get('value')).toEqual "unassigned"
			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@iapc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@iapc.$('.bv_parentName').val(" Updated entity name   ")
						@iapc.$('.bv_parentName').change()
						@iapc.$('.bv_recordedBy').val("bob")
						@iapc.$('.bv_recordedBy').change()
						@iapc.$('.bv_completionDate').val(" 2013-3-16   ")
						@iapc.$('.bv_completionDate').change()
						@iapc.$('.bv_notebook').val("my notebook")
						@iapc.$('.bv_notebook').change()
						@iapc.$('.bv_conjugationType').val("unconjugated")
						@iapc.$('.bv_conjugationType').change()
						@iapc.$('.bv_conjugationSite').val("lys")
						@iapc.$('.bv_conjugationSite').change()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@iapc.isValid()).toBeTruthy()
					it "should have the update button be enabled", ->
						runs ->
							expect(@iapc.$('.bv_updateParent').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@iapc.$('.bv_parentName').val("")
							@iapc.$('.bv_parentName').change()
					it "should be invalid if name not filled in", ->
						runs ->
							expect(@iapc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@iapc.$('.bv_group_parentName').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@iapc.$('.bv_updateParent').attr('disabled')).toEqual 'disabled'
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@iapc.$('.bv_recordedBy').val("")
							@iapc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@iapc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@iapc.$('.bv_completionDate').val("")
							@iapc.$('.bv_completionDate').change()
					it "should show error in date field", ->
						runs ->
							expect(@iapc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@iapc.$('.bv_notebook').val("")
							@iapc.$('.bv_notebook').change()
					it "should show error on notebook field", ->
						runs ->
							expect(@iapc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when conjugation type not filled", ->
					beforeEach ->
						runs ->
							@iapc.$('.bv_conjugationType').val("unassigned")
							@iapc.$('.bv_conjugationType').change()
					it "should show error on conjugation type field", ->
						runs ->
							expect(@iapc.$('.bv_group_conjugationType').hasClass('error')).toBeTruthy()
				describe "when conjugation site not filled", ->
					beforeEach ->
						runs ->
							@iapc.$('.bv_conjugationSite').val("unassigned")
							@iapc.$('.bv_conjugationSite').change()
					it "should show error on conjugation site field", ->
						runs ->
							expect(@iapc.$('.bv_group_conjugationSite').hasClass('error')).toBeTruthy()

	describe "InternalizationAgent Batch model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@iab= new InternalizationAgentBatch()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@iab).toBeDefined()
				it "should have a type", ->
					expect(@iab.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@iab.get('lsKind')).toEqual "internalization agent"
				it "should have an empty scientist", ->
					expect(@iab.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@iab.get('recordedDate')).getHours()).toEqual new Date().getHours()
				#				it "should have an analytical method file type", ->
				#					expect(@iab.get('analyticalFileType')).toEqual "unassigned"
				#				it "should have an analytical method fileValue", ->
				#					expect(@iab.get('analyticalFileType')).toEqual "unassigned"
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for completion date", ->
						expect(@iab.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@iab.get("notebook")).toBeDefined()
					#					it "Should have a model attribute for analytical method file type", ->
					#						expect(@iab.get("analytical file type")).toBeDefined()
					it "Should have a model attribute for molecular weight", ->
						expect(@iab.get("molecular weight")).toBeDefined()
					it "Should have a model attribute for purity", ->
						expect(@iab.get("purity")).toBeDefined()
					it "Should have a model attribute for amount", ->
						expect(@iab.get("amount")).toBeDefined()
					it "Should have a model attribute for location", ->
						expect(@iab.get("location")).toBeDefined()

		describe "When created from existing", ->
			beforeEach ->
				@iab = new InternalizationAgentBatch JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentBatch))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@iab).toBeDefined()
				it "should have a type", ->
					expect(@iab.get('lsType')).toEqual "batch"
				it "should have a kind", ->
					expect(@iab.get('lsKind')).toEqual "internalization agent"
				it "should have a scientist set", ->
					expect(@iab.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@iab.get('recordedDate')).toEqual 1375141508000
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@iab.get('lsStates')).toBeDefined()
					expect(@iab.get("lsStates").length).toEqual 2
					expect(@iab.get("lsStates").getStatesByTypeAndKind("metadata", "internalization agent batch").length).toEqual 1
					expect(@iab.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual 1
				it "Should have a completion date value", ->
					expect(@iab.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@iab.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a molecular weight value", ->
					expect(@iab.get("molecular weight").get("value")).toEqual 231
				it "Should have a purity value", ->
					expect(@iab.get("purity").get("value")).toEqual 92
				it "Should have an amount value", ->
					expect(@iab.get("amount").get("value")).toEqual 2.3
				it "Should have a location value", ->
					expect(@iab.get("location").get("value")).toEqual "Cabinet 1"

		describe "model validation", ->
			beforeEach ->
				@iab = new InternalizationAgentBatch window.internalizationAgentTestJSON.internalizationAgentBatch
			it "should be valid when loaded from saved", ->
				console.log @iab.validationError
				expect(@iab.isValid()).toBeTruthy()
			it "should be invalid when recorded date is empty", ->
				@iab.set recordedDate: new Date("").getTime()
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='recordedDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when scientist not selected", ->
				@iab.set recordedBy: ""
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='recordedBy'
				)
			it "should be invalid when completion date is empty", ->
				@iab.get("completion date").set("value", new Date("").getTime())
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='completionDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when notebook is empty", ->
				@iab.get("notebook").set("value", "")
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when molecular weight is NaN", ->
				@iab.get("molecular weight").set("value", "fred")
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='molecularWeight'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when purity is NaN", ->
				@iab.get("purity").set("value", "fred")
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='purity'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when amount is NaN", ->
				@iab.get("amount").set("value", "fred")
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='amount'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when location is empty", ->
				@iab.get("location").set("value", "")
				expect(@iab.isValid()).toBeFalsy()
				filtErrors = _.filter(@iab.validationError, (err) ->
					err.attribute=='location'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "InternalizationAgent Batch Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@iab = new InternalizationAgentBatch()
				@iabc = new InternalizationAgentBatchController
					model: @iab
					el: $('#fixture')
				@iabc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@iabc).toBeDefined()
				it "should load the template", ->
					expect(@iabc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
				it "should load the additional batch attributes template", ->
					expect(@iabc.$('.bv_molecularWeight').length).toEqual 1
		describe "When instantiated from existing", ->
			beforeEach ->
				@iab = new InternalizationAgentBatch JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentBatch))
				@iabc = new InternalizationAgentBatchController
					model: @iab
					el: $('#fixture')
				@iabc.render()
			describe "render existing parameters", ->
				it "should show the internalization agent batch id", ->
					expect(@iabc.$('.bv_batchCode').val()).toEqual "I000001-1"
				it "should fill the scientist field", ->
					waitsFor ->
						@iabc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						expect(@iabc.$('.bv_recordedBy').val()).toEqual "jane"
				it "should fill the completion date field", ->
					expect(@iabc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@iabc.$('.bv_notebook').val()).toEqual "Notebook 1"
				it "should fill the amount field", ->
					expect(@iabc.$('.bv_amount').val()).toEqual "2.3"
				it "should fill the molecular weight field", ->
					expect(@iabc.$('.bv_molecularWeight').val()).toEqual "231"
				it "should fill the purity field", ->
					expect(@iabc.$('.bv_purity').val()).toEqual "92"
				it "should fill the location field", ->
					expect(@iabc.$('.bv_location').val()).toEqual "Cabinet 1"
			describe "model updates", ->
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@iabc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@iabc.$('.bv_recordedBy').val('unassigned')
						@iabc.$('.bv_recordedBy').change()
						expect(@iabc.model.get('recordedBy')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@iabc.$('.bv_completionDate').val(" 2013-3-16   ")
					@iabc.$('.bv_completionDate').change()
					expect(@iabc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@iabc.$('.bv_notebook').val(" Updated notebook  ")
					@iabc.$('.bv_notebook').change()
					expect(@iabc.model.get('notebook').get('value')).toEqual "Updated notebook"
				it "should update model when molecular weight is changed", ->
					@iabc.$('.bv_molecularWeight').val(" 12  ")
					@iabc.$('.bv_molecularWeight').change()
					expect(@iabc.model.get('molecular weight').get('value')).toEqual 12
				it "should update model when purity is changed", ->
					@iabc.$('.bv_purity').val(" 22  ")
					@iabc.$('.bv_purity').change()
					expect(@iabc.model.get('purity').get('value')).toEqual 22
				it "should update model when amount is changed", ->
					@iabc.$('.bv_amount').val(" 12  ")
					@iabc.$('.bv_amount').change()
					expect(@iabc.model.get('amount').get('value')).toEqual 12
				it "should update model when location is changed", ->
					@iabc.$('.bv_location').val(" Updated location  ")
					@iabc.$('.bv_location').change()
					expect(@iabc.model.get('location').get('value')).toEqual "Updated location"

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@iabc.$('.bv_recordedBy option').length > 0
					, 1000
					runs ->
						@iabc.$('.bv_recordedBy').val("bob")
						@iabc.$('.bv_recordedBy').change()
						@iabc.$('.bv_completionDate').val(" 2013-3-16   ")
						@iabc.$('.bv_completionDate').change()
						@iabc.$('.bv_notebook').val("my notebook")
						@iabc.$('.bv_notebook').change()
						@iabc.$('.bv_molecularWeight').val(" 24")
						@iabc.$('.bv_molecularWeight').change()
						@iabc.$('.bv_purity').val(" 85")
						@iabc.$('.bv_purity').change()
						@iabc.$('.bv_amount').val(" 24")
						@iabc.$('.bv_amount').change()
						@iabc.$('.bv_location').val(" Hood 4")
						@iabc.$('.bv_location').change()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@iabc.isValid()).toBeTruthy()
					it "should have the save button be enabled", ->
						runs ->
							expect(@iabc.$('.bv_saveBatch').attr('disabled')).toBeUndefined()
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@iabc.$('.bv_recordedBy').val("")
							@iabc.$('.bv_recordedBy').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@iabc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy()
					it "should have the save button be disabled", ->
						runs ->
							expect(@iabc.$('.bv_saveBatch').attr('disabled')).toEqual 'disabled'
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@iabc.$('.bv_completionDate').val("")
							@iabc.$('.bv_completionDate').change()
					it "should show error in date field", ->
						runs ->
							expect(@iabc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@iabc.$('.bv_notebook').val("")
							@iabc.$('.bv_notebook').change()
					it "should show error on notebook field", ->
						runs ->
							expect(@iabc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()
				describe "when molecular weight not filled", ->
					beforeEach ->
						runs ->
							@iabc.$('.bv_molecularWeight').val("")
							@iabc.$('.bv_molecularWeight').change()
					it "should show error on molecular weight field", ->
						runs ->
							expect(@iabc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy()
				describe "when purity not filled", ->
					beforeEach ->
						runs ->
							@iabc.$('.bv_purity').val("")
							@iabc.$('.bv_purity').change()
					it "should show error on purity field", ->
						runs ->
							expect(@iabc.$('.bv_group_purity').hasClass('error')).toBeTruthy()
				describe "when amount not filled", ->
					beforeEach ->
						runs ->
							@iabc.$('.bv_amount').val("")
							@iabc.$('.bv_amount').change()
					it "should show error on amount field", ->
						runs ->
							expect(@iabc.$('.bv_group_amount').hasClass('error')).toBeTruthy()
				describe "when location not filled", ->
					beforeEach ->
						runs ->
							@iabc.$('.bv_location').val("")
							@iabc.$('.bv_location').change()
					it "should show error on location field", ->
						runs ->
							expect(@iabc.$('.bv_group_location').hasClass('error')).toBeTruthy()

	describe "InternalizationAgent Batch Select Controller testing", ->
		beforeEach ->
			@iab = new InternalizationAgentBatch()
			@iabsc = new InternalizationAgentBatchSelectController
				model: @iab
				el: $('#fixture')
			@iabsc.render()
		describe "When instantiated", ->
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@iabsc).toBeDefined()
				it "should load the template", ->
					expect(@iabsc.$('.bv_batchList').length).toEqual 1
			describe "rendering", ->
				it "should have the batch list default to register new batch", ->
					waitsFor ->
						@iabsc.$('.bv_batchList option').length > 0
					, 1000
					runs ->
						expect(@iabsc.$('.bv_batchList').val()).toEqual "new batch"
				it "should a new batch registration form", ->
					console.log @iabsc.$('.bv_batchCode')
					expect(@iabsc.$('.bv_batchCode').val()).toEqual ""
					expect(@iabsc.$('.bv_batchCode').html()).toEqual "Autofilled when saved"
		describe "behavior", ->
			it "should show the information for a selected batch", ->
				waitsFor ->
					@iabsc.$('.bv_batchList option').length > 0
				, 1000
				runs ->
					console.log @iabsc.$('.bv_batchList')
					@iabsc.$('.bv_batchList').val("CB000001-1")
					@iabsc.$('.bv_batchList').change()
				waitsFor ->
					@iabsc.$('.bv_recordedBy option').length > 0
				, 1000
				runs ->
					waits(1000)
				runs ->
					expect(@iabsc.$('.bv_batchCode').html()).toEqual "CB000001-1"
					expect(@iabsc.$('.bv_recordedBy').val()).toEqual "jane"

	describe "InternalizationAgent Controller", ->
		beforeEach ->
			@iac = new InternalizationAgentController
				model: new InternalizationAgentParent()
				el: $('#fixture')
			@iac.render()
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@iac).toBeDefined()
			it "Should load the template", ->
				expect(@iac.$('.bv_save').length).toEqual 1
			it "Should load a parent controller", ->
				expect(@iac.$('.bv_parent .bv_parentCode').length).toEqual 1
			it "Should load a batch controller", ->
				expect(@iac.$('.bv_batch .bv_batchCode').length).toEqual 1
		describe "saving parent/batch for the first time", ->
			describe "when form is initialized", ->
				it "should have the save button be disabled initially", ->
					expect(@iac.$('.bv_save').attr('disabled')).toEqual 'disabled'
			describe 'when save is clicked', ->
				beforeEach ->
					runs ->
						@iac.$('.bv_parentName').val(" Updated entity name   ")
						@iac.$('.bv_parentName').change()
						@iac.$('.bv_recordedBy').val("bob")
						@iac.$('.bv_recordedBy').change()
						@iac.$('.bv_completionDate').val(" 2013-3-16   ")
						@iac.$('.bv_completionDate').change()
						@iac.$('.bv_notebook').val("my notebook")
						@iac.$('.bv_notebook').change()
						@iac.$('.bv_conjugationType').val(" mab")
						@iac.$('.bv_conjugationType').change()
						@iac.$('.bv_conjugationSite').val(" AUC")
						@iac.$('.bv_conjugationSite').change()
						@iac.$('.bv_molecularWeight').val(" 14")
						@iac.$('.bv_molecularWeight').change()
						@iac.$('.bv_purity').val(" 74")
						@iac.$('.bv_purity').change()
						@iac.$('.bv_amount').val(" 24")
						@iac.$('.bv_amount').change()
						@iac.$('.bv_location').val(" Hood 4")
						@iac.$('.bv_location').change()
					waitsFor ->
						@iac.$('.bv_recordedBy option').length > 0
					, 1000
				it "should have the save button be enabled", ->
					runs ->
						expect(@iac.$('.bv_save').attr('disabled')).toBeUndefined()
				it "should update the parent code", ->
					runs ->
						@iac.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@iac.$('.bv_parentCode').html()).toEqual "I000001"
				it "should update the batch code", ->
					runs ->
						@iac.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@iac.$('.bv_batchCode').html()).toEqual "I000001-1"
				it "should show the update parent button", ->
					runs ->
						@iac.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@iac.$('.bv_updateParent')).toBeVisible()
				it "should show the update batch button", ->
					runs ->
						@iac.$('.bv_save').click()
					waits(1000)
					runs ->
						expect(@iac.$('.bv_saveBatch')).toBeVisible()


