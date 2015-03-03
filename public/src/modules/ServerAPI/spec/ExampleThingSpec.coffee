beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Example Thing testing', ->
	describe "Example Thing model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@et = new ExampleThing()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@et).toBeDefined()
				it "should have a type", ->
					expect(@et.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@et.get('lsKind')).toEqual "cationic block"
				it "should have the recordedBy set to the logged in user", ->
					expect(@et.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@et.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with one label", ->
					expect(@et.get('lsLabels')).toBeDefined()
					expect(@et.get("lsLabels").length).toEqual 1
					expect(@et.get("lsLabels").getLabelByTypeAndKind("name", "cationic block").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@et.get("cationic block name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@et.get('lsStates')).toBeDefined()
					expect(@et.get("lsStates").length).toEqual 1
					expect(@et.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for scientist", ->
						expect(@et.get("scientist")).toBeDefined()
					it "Should have a model attribute for completion date", ->
						expect(@et.get("completion date")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@et.get("notebook")).toBeDefined()
					it "Should have a model attribute for structural file", ->
						expect(@et.get("structural file")).toBeDefined()
			describe "model validation", ->
				it "should be invalid when name is empty", ->
					@et.get("cationic block name").set("labelText", "")
					expect(@et.isValid()).toBeFalsy()
					filtErrors = _.filter(@et.validationError, (err) ->
						err.attribute=='thingName'
					)
					expect(filtErrors.length).toBeGreaterThan 0

		describe "When created from existing", ->
			beforeEach ->
				@et = new ExampleThing JSON.parse(JSON.stringify(window.exampleThingTestJSON.exampleThing))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@et).toBeDefined()
				it "should have a type", ->
					expect(@et.get('lsType')).toEqual "parent"
				it "should have a kind", ->
					expect(@et.get('lsKind')).toEqual "cationic block"
				it "should have a recordedBy set", ->
					expect(@et.get('recordedBy')).toEqual "jane"
				it "should have a recordedDate set", ->
					expect(@et.get('recordedDate')).toEqual 1375141508000
				it "Should have label set", ->
					console.log @et
					expect(@et.get("cationic block name").get("labelText")).toEqual "cMAP10"
					label = (@et.get("lsLabels").getLabelByTypeAndKind("name", "cationic block"))
					console.log label[0]
					expect(label[0].get('labelText')).toEqual "cMAP10"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@et.get('lsStates')).toBeDefined()
					expect(@et.get("lsStates").length).toEqual 1
					expect(@et.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual 1
				it "Should have a scientist value", ->
					expect(@et.get("scientist").get("value")).toEqual "john"
				it "Should have a completion date value", ->
					expect(@et.get("completion date").get("value")).toEqual 1342080000000
				it "Should have a notebook value", ->
					expect(@et.get("notebook").get("value")).toEqual "Notebook 1"
				it "Should have a structural file value", ->
					expect(@et.get("structural file").get("value")).toEqual "TestFile.mol"

			describe "model validation", ->
				beforeEach ->
					@et = new ExampleThing window.exampleThingTestJSON.exampleThing
				it "should be valid when loaded from saved", ->
					expect(@et.isValid()).toBeTruthy()
				it "should be invalid when name is empty", ->
					@et.get("cationic block name").set("labelText", "")
					expect(@et.isValid()).toBeFalsy()
					filtErrors = _.filter(@et.validationError, (err) ->
						err.attribute=='thingName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when scientist not selected", ->
					@et.get('scientist').set('value', "unassigned")
					expect(@et.isValid()).toBeFalsy()
					filtErrors = _.filter(@et.validationError, (err) ->
						err.attribute=='scientist'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when completion date is empty", ->
					@et.get("completion date").set("value", new Date("").getTime())
					expect(@et.isValid()).toBeFalsy()
					filtErrors = _.filter(@et.validationError, (err) ->
						err.attribute=='completionDate'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when notebook is empty", ->
					@et.get("notebook").set("value", "")
					expect(@et.isValid()).toBeFalsy()
					filtErrors = _.filter(@et.validationError, (err) ->
						err.attribute=='notebook'
					)
					expect(filtErrors.length).toBeGreaterThan 0

	describe "Cationic Block Parent Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@et = new ExampleThing()
				@etc = new ExampleThingController
					model: @et
					el: $('#fixture')
				@etc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@etc).toBeDefined()
				it "should load the template", ->
					expect(@etc.$('.bv_thingCode').html()).toEqual "Autofilled when saved"
				it "should load the additional parent attributes temlate", ->
					expect(@etc.$('.bv_structuralFile').length).toEqual 1
		describe "When instantiated from existing", ->
			beforeEach ->
				@et = new ExampleThing JSON.parse(JSON.stringify(window.exampleThingTestJSON.exampleThing))
				@etc = new ExampleThingController
					model: @et
					el: $('#fixture')
				@etc.render()
			describe "render existing parameters", ->
				it "should show the cationic block parent id", ->
					expect(@etc.$('.bv_thingCode').val()).toEqual "CB000001"
				it "should fill the cationic block parent name", ->
					expect(@etc.$('.bv_thingName').val()).toEqual "cMAP10"
				it "should fill the scientist field", ->
					waitsFor ->
						@etc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						console.log @etc.$('.bv_scientist').val()
						expect(@etc.$('.bv_scientist').val()).toEqual "john"
				it "should fill the completion date field", ->
					expect(@etc.$('.bv_completionDate').val()).toEqual "2012-07-12"
				it "should fill the notebook field", ->
					expect(@etc.$('.bv_notebook').val()).toEqual "Notebook 1"

			describe "model updates", ->
				it "should update model when parent name is changed", ->
					@etc.$('.bv_thingName').val(" New name   ")
					@etc.$('.bv_thingName').keyup()
					expect(@etc.model.get('cationic block name').get('labelText')).toEqual "New name"
				it "should update model when the scientist is changed", ->
					waitsFor ->
						@etc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@etc.$('.bv_scientist').val('unassigned')
						@etc.$('.bv_scientist').change()
						expect(@etc.model.get('scientist').get('value')).toEqual "unassigned"
				it "should update model when completion date is changed", ->
					@etc.$('.bv_completionDate').val(" 2013-3-16   ")
					@etc.$('.bv_completionDate').keyup()
					expect(@etc.model.get('completion date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when notebook is changed", ->
					@etc.$('.bv_notebook').val(" Updated notebook  ")
					@etc.$('.bv_notebook').keyup()
					expect(@etc.model.get('notebook').get('value')).toEqual "Updated notebook"

			describe "controller validation rules", ->
				beforeEach ->
					waitsFor ->
						@etc.$('.bv_scientist option').length > 0
					, 1000
					runs ->
						@etc.$('.bv_thingName').val(" Updated entity name   ")
						@etc.$('.bv_thingName').keyup()
						@etc.$('.bv_scientist').val("bob")
						@etc.$('.bv_scientist').change()
						@etc.$('.bv_completionDate').val(" 2013-3-16   ")
						@etc.$('.bv_completionDate').keyup()
						@etc.$('.bv_notebook').val("my notebook")
						@etc.$('.bv_notebook').keyup()
				describe "form validation setup", ->
					it "should be valid if form fully filled out", ->
						runs ->
							expect(@etc.isValid()).toBeTruthy()
					it "should have the update button be enabled", ->
						runs ->
							expect(@etc.$('.bv_updateParent').attr('disabled')).toBeUndefined()
				describe "when name field not filled in", ->
					beforeEach ->
						runs ->
							@etc.$('.bv_thingName').val("")
							@etc.$('.bv_thingName').keyup()
					it "should be invalid if name not filled in", ->
						runs ->
							expect(@etc.isValid()).toBeFalsy()
					it "should show error in name field", ->
						runs ->
							expect(@etc.$('.bv_group_thingName').hasClass('error')).toBeTruthy()
					it "should have the update button be disabled", ->
						runs ->
							expect(@etc.$('.bv_saveThing').attr('disabled')).toEqual 'disabled'
				describe "when scientist not selected", ->
					beforeEach ->
						runs ->
							@etc.$('.bv_scientist').val("")
							@etc.$('.bv_scientist').change()
					it "should show error on scientist dropdown", ->
						runs ->
							expect(@etc.$('.bv_group_scientist').hasClass('error')).toBeTruthy()
				describe "when date field not filled in", ->
					beforeEach ->
						runs ->
							@etc.$('.bv_completionDate').val("")
							@etc.$('.bv_completionDate').keyup()
					it "should show error in date field", ->
						runs ->
							expect(@etc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy()
				describe "when notebook not filled", ->
					beforeEach ->
						runs ->
							@etc.$('.bv_notebook').val("")
							@etc.$('.bv_notebook').keyup()
					it "should show error on notebook field", ->
						runs ->
							expect(@etc.$('.bv_group_notebook').hasClass('error')).toBeTruthy()

