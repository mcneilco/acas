describe "PickList Select Unit Testing", ->
	beforeEach ->
		@fixture = $.clone($("#fixture").get(0))
		$("#fixture").append("<select id='selectFixture'></select>")
		@selectFixture = $("#selectFixture")

	afterEach ->
		$("#fixture").remove()
		$("body").append $(@fixture)

	describe "PickList Collection", ->
		beforeEach ->
			runs ->
				@serviceReturn = false
				@pickListList = new PickListList window.projectServiceTestJSON.projects
				@pickListList.url = "/api/projects"
				@pickListList.fetch
					success: =>
						@serviceReturn = true
				@pickListList.fetch
			waitsFor ->
				@serviceReturn
		describe "Upon init", ->
			it "should get options from server", ->
				runs ->
					expect(@pickListList.length).toEqual 4
			it "should return non-ignored values", ->
				runs ->
					expect(@pickListList.getCurrent().length).toEqual 3

	describe "PickList controller", ->
		beforeEach ->
			runs ->
				@pickListList = new PickListList()
				@pickListList.url = "/api/projects"

		describe "when displayed", ->
			describe "when displayed with default options", ->
				beforeEach ->
					runs ->
						@pickListController = new PickListSelectController
							el: @selectFixture
							collection: @pickListList
					waitsFor ->
						@pickListList.length > 0
				it " should have three choices", ->
					runs ->
						expect(@pickListController.$("option").length).toEqual 3
				it "should return selected model", ->
					runs ->
						@pickListController.$("option")[1].selected = true
						mdl = @pickListController.getSelectedModel()
						expect(mdl.get("code")).toEqual "project2"
						@pickListController.$("option")[2].selected = true
						mdl = @pickListController.getSelectedModel()
						expect(mdl.get("code")).toEqual "project3"
				it "should return selected code", ->
					runs ->
						@pickListController.$("option")[1].selected = true
						expect(@pickListController.getSelectedCode()).toEqual "project2"
			describe "when displayed with pre-selected value", ->
				beforeEach ->
					runs ->
						@pickListController = new PickListSelectController
							el: @selectFixture
							collection: @pickListList
							selectedCode: "project2"
					waitsFor ->
						@pickListList.length > 0
				it "should show selected value", ->
					runs ->
						expect($(@pickListController.el).val()).toEqual "project2"

			describe "when created with added option not in database", ->
				beforeEach ->
					runs ->
						@pickListController = new PickListSelectController
							el: @selectFixture
							collection: @pickListList
							insertFirstOption: new PickList
								code: "not_set"
								name: "Select Category"
							selectedCode: "not_set"
					waitsFor ->
						@pickListList.length > 0
				it "should have five choices", ->
					runs ->
						expect(@pickListController.$("option").length).toEqual 4
				it "should not set selected", ->
					runs ->
						expect($(@pickListController.el).val()).toEqual "not_set"


			describe "when created with populated collection and no fetch requested", ->
				beforeEach ->
					@pickListController = new PickListSelectController
						el: @selectFixture
						collection: new PickListList window.projectServiceTestJSON.projects
						insertFirstOption: new PickList
							code: "not_set"
							name: "Select Category"
						selectedCode: "not_set"
						autoFetch: false
				it "should have five choices", ->
					runs ->
						expect(@pickListController.$("option").length).toEqual 4
				it "should set selected", ->
					runs ->
						expect($(@pickListController.el).val()).toEqual "not_set"

			describe "when adding options to picklists", ->
				beforeEach ->
					runs ->
						@pickListController = new PickListSelectController
							el: @selectFixture
							collection: @pickListList
					waitsFor ->
						@pickListList.length > 0
				it "should be able to check if the option is in the collection", ->
					runs  ->
						expect(@pickListController.checkOptionInCollection("project1")).toBeTruthy()
						expect(@pickListController.checkOptionInCollection("projectZ")).toBeFalsy()


	describe "AddParameterOptionPanel model testing", ->
		beforeEach ->
			@adop = new AddParameterOptionPanel()
		describe "Existence and Defaults", ->
			it "should be defined", ->
				expect(@adop).toBeDefined()
			it "should have the parameter name set to null", ->
				expect(@adop.get('parameter')).toBeNull()
			it "should have the codeType set to null", ->
				expect(@adop.get('codeType')).toBeNull()
			it "should have the codeKind set to null", ->
				expect(@adop.get('codeKind')).toBeNull()
			it "should have the codeOrigin set to acas ddict", ->
				expect(@adop.get('codeOrigin')).toEqual "ACAS DDICT"
			it "should have the label text be null", ->
				expect(@adop.get('newOptionLabel')).toBeNull()
			it "should have the description be set to null", ->
				expect(@adop.get('newOptionDescription')).toBeNull()
			it "should have the comments be set to null", ->
				expect(@adop.get('newOptionComments')).toBeNull()
		describe "validation", ->
			it "should be invalid when the label is not filled in", ->
				@adop.set newOptionlabel: ""
				expect(@adop.isValid()).toBeFalsy()
				filtErrors = _.filter @adop.validationError, (err) ->
					err.attribute=='newOptionLabel'
				expect(filtErrors.length).toBeGreaterThan 0

	describe "AddParameterOptionPanelController testing", ->
		beforeEach ->
			@adopc = new AddParameterOptionPanelController
				model: new AddParameterOptionPanel
					parameter: "projects"
					codeType: "protocolMetadata"
					codeKind: "projects"
				el: $('#fixture')
			@adopc.render()
		describe "basic startup conditions", ->
			it "should exist", ->
				expect(@adopc).toBeDefined()
			it "should load a template", ->
				expect(@adopc.$('.bv_addParameterOptionModal').length).toEqual 1
			it "should have the save button disabled", ->
				expect(@adopc.$('.bv_addNewParameterOption').attr('disabled')).toEqual 'disabled'
		describe "model updates", ->
			it "should update the newOptionLabel", ->
				@adopc.$('.bv_newOptionLabel').val(" test ")
				@adopc.$('.bv_newOptionLabel').change()
				expect(@adopc.model.get('newOptionLabel')).toEqual "test"
			it "should update the newOptionDescription", ->
				@adopc.$('.bv_newOptionDescription').val(" test description ")
				@adopc.$('.bv_newOptionDescription').change()
				expect(@adopc.model.get('newOptionDescription')).toEqual "test description"
			it "should update the newOptionComments", ->
				@adopc.$('.bv_newOptionComments').val("test comments ")
				@adopc.$('.bv_newOptionComments').change()
				expect(@adopc.model.get('newOptionComments')).toEqual "test comments"
		describe "behavior and validation testing", ->
			it "should show error when the label is not filled in", ->
				@adopc.$('.bv_newOptionLabel').val ""
				@adopc.$('.bv_newOptionLabel').change()
				expect(@adopc.$('.bv_group_newOptionLabel').hasClass("error")).toBeTruthy()
		describe "form validation setup", ->
			it "should be valid and add button is enabled if form fully filled out", ->
				runs ->
					@adopc.$('.bv_newOptionLabel').val "test"
					@adopc.$('.bv_newOptionLabel').change()
					@adopc.$('.bv_newOptionDescription').val "test2"
					@adopc.$('.bv_newOptionDescription').change()
					@adopc.$('.bv_newOptionComments').val "test3"
					@adopc.$('.bv_newOptionComments').change()
					expect(@adopc.isValid()).toBeTruthy()
					expect(@adopc.$('.bv_addNewParameterOption').attr('disabled')).toBeUndefined()

	describe "EditablePickListSelectController", ->
		beforeEach ->
			runs ->
				@editablePickListList = new PickListList()
				@editablePickListList.url = "/api/projects"

		describe "when displayed for users who can add to pick list", ->
			beforeEach ->
				runs ->
					@editablePickListController = new EditablePickListSelectController
						el: $('#fixture')
						collection: @editablePickListList
						selectedCode: "unassigned"
						parameter: "projects"
						codeType: "protocolMetadata"
						codeKind: "projects"
						roles: ["admin"]
					@editablePickListController.render()
				waitsFor ->
					@editablePickListList.length > 0
			describe "when initialized", ->
				it "should have a picklist select controller", ->
					runs ->
						expect(@editablePickListController.pickListController).toBeDefined()
				it "should have an add button", ->
					runs ->
						expect(@editablePickListController.$('.bv_addOptionBtn').length).toEqual 1
			describe "when add button is clicked", ->
				it " should have an add panel controller", ->
					runs ->
						@editablePickListController.$('.bv_addOptionBtn').click()
						expect(@editablePickListController.addPanelController).toBeDefined()
			describe "when user wants to add a parameter option", ->
				describe "should have the picklist controller check if the option is already in the collection", ->
					describe "valid new option", ->
						beforeEach ->
							runs ->
								@editablePickListController.$('.bv_addOptionBtn').click()
								@editablePickListController.addPanelController.$('.bv_newOptionLabel').val "new option"
								@editablePickListController.addPanelController.$('.bv_newOptionDescription').val "new description"
								@editablePickListController.addPanelController.$('.bv_newOptionComments').val "new comments"
								@editablePickListController.addPanelController.$('.bv_newOptionComments').change()
								@editablePickListController.addPanelController.$('.bv_addNewParameterOption').click()
						it "should have the pickListController add a new model to collection", ->
							newOption = @editablePickListController.addPanelController.model.get('newOptionLabel')
							expect(@editablePickListController.pickListController.checkOptionInCollection(newOption)).toBeDefined()
						it "should have the picklist's selected option be the new option", ->
							expect(@editablePickListController.pickListController.getSelectedCode()).toEqual "new option"
							expect(@editablePickListController.$('.bv_errorMessage')).toBeHidden()
					describe "invalid new option", ->
						beforeEach ->
							runs ->
								@editablePickListController.$('.bv_addOptionBtn').click()
								@editablePickListController.addPanelController.$('.bv_newOptionLabel').val "project2"
								@editablePickListController.addPanelController.$('.bv_newOptionDescription').val "test2"
								@editablePickListController.addPanelController.$('.bv_newOptionComments').val "test3"
								@editablePickListController.addPanelController.$('.bv_newOptionComments').change()
								@editablePickListController.addPanelController.$('.bv_addNewParameterOption').click()
						it "should tell user that the option already exists", ->
							expect(@editablePickListController.$('.bv_errorMessage')).toBeVisible()
