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


	describe "EditablePickList controller", ->
		beforeEach ->
			runs ->
				@editablePickListList = new PickListList()
				@editablePickListList.url = "/api/projects"

		describe "when displayed", ->
			describe "when displayed with default options", ->
				beforeEach ->
					runs ->
						@editablepickListController = new EditablePickListSelectController
							el: @selectFixture
							collection: @editablePickListList
							selectedCode: "unassigned"
							parameter: "projects"
					waitsFor ->
						@editablePickListList.length > 0
				it " should have three choices", ->
					runs ->
						expect(@editablepickListController.$("option").length).toEqual 3
				it "should return selected model", ->
					runs ->
						@editablepickListController.$("option")[1].selected = true
						mdl = @editablepickListController.getSelectedModel()
						expect(mdl.get("code")).toEqual "project2"
						@editablepickListController.$("option")[2].selected = true
						mdl = @editablepickListController.getSelectedModel()
						expect(mdl.get("code")).toEqual "project3"
				it "should return selected code", ->
					runs ->
						@editablepickListController.$("option")[1].selected = true
						expect(@editablepickListController.getSelectedCode()).toEqual "project2"



#	describe "EditablePickListController testing", ->
#		beforeEach ->
#			runs ->
#				@editablePickListList = new PickListList()
#				@editablePickListList.url = "/api/projects"
#
#		describe "when displayed", ->
#			describe "when displayed with default options", ->
#				beforeEach ->
#					runs ->
#						@editablePickListController = new EditablePickListSelectController
#							el: @selectFixture
#							collection: @editablePickListList
#						@editablePickListController.render()
#					waitsFor ->
#						@editablePickListList.length > 0
#				it "should exist when instantiated", ->
#					runs ->
#						expect(@editablePickListController).toBeDefined()
#				it " should have three choices", ->
#					runs ->
#						expect(@editablePickListController.$("option").length).toEqual 3
#				it "should have an add button", ->
#					runs ->
#						expect(@editablePickListController.$('.bv_addParameterOptionBtn').length).toEqual 1


#	describe "EditablePickList controller", ->
#		beforeEach ->
#			@eplsc = new EditablePickListSelectController
#				model: new PrimaryScreenProtocol()
#			@eplsc.render()
#		describe "when instantiated", ->
#			it "should exist", ->
#				expect(@eplsc).toBeDefined()
#			it "should have the parameter variable set to assay activity", ->
#				expect(@eplsc.parameter).toEqual "assayActivity"
#			it "should show a picklist", ->
#				waitsFor ->
#					@eplsc.$('.bv_assayActivity option').length > 0
#				, 1000
#				runs ->
#					expect(@eplsc.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "unassigned"
#					expect(@eplsc.$('.bv_assayActivity').val()).toEqual "unassigned"

#			it "should have an add button", ->
#				waitsFor ->
#					@eplsc.$('.bv_assayActivity option').length > 0
#				, 1000
#				runs ->
#				expect(@eplsc.$('.bv_addParameterOptionBtn').length).toEqual 1

