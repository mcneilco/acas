beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Project testing', ->
	describe " Project model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@proj = new Project()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@proj).toBeDefined()
				it "should have a type", ->
					expect(@proj.get('lsType')).toEqual "project"
				it "should have a kind", ->
					expect(@proj.get('lsKind')).toEqual "project"
				it "should have the recordedBy set to the logged in user", ->
					expect(@proj.get('recordedBy')).toEqual window.AppLaunchParams.loginUser.username
				it "should have a recordedDate set to now", ->
					expect(new Date(@proj.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have a lsLabels with two labels", ->
					expect(@proj.get('lsLabels')).toBeDefined()
					expect(@proj.get("lsLabels").length).toEqual 2
					expect(@proj.get("lsLabels").getLabelByTypeAndKind("name", "project name").length).toEqual 1
					expect(@proj.get("lsLabels").getLabelByTypeAndKind("name", "project alias").length).toEqual 1
				it "Should have a model attribute for the labels in defaultLabels", ->
					expect(@proj.get("project name")).toBeDefined()
					expect(@proj.get("project alias")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@proj.get('lsStates')).toBeDefined()
					expect(@proj.get("lsStates").length).toEqual 1
					expect(@proj.get("lsStates").getStatesByTypeAndKind("metadata", "project metadata").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for start date", ->
						expect(@proj.get("start date")).toBeDefined()
					it "Should have a model attribute for project status", ->
						expect(@proj.get("project status")).toBeDefined()
					it "Should have a model attribute for short description", ->
						expect(@proj.get("short description")).toBeDefined()
					it "Should have a model attribute for project details", ->
						expect(@proj.get("project details")).toBeDefined()
					it "Should have a model attribute for live design id", ->
						expect(@proj.get("live design id")).toBeDefined()
					it "Should have a model attribute for is restricted", ->
						expect(@proj.get("live design id")).toBeDefined()
			describe "model validation", ->
				it "should be invalid when project name is empty", ->
					@proj.get("project name").set("labelText", "")
					expect(@proj.isValid()).toBeFalsy()
					filtErrors = _.filter(@proj.validationError, (err) ->
						err.attribute=='projectName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when project alias is empty", ->
					@proj.get("project alias").set("labelText", "")
					expect(@proj.isValid()).toBeFalsy()
					filtErrors = _.filter(@proj.validationError, (err) ->
						err.attribute=='projectAlias'
					)
					expect(filtErrors.length).toBeGreaterThan 0

		describe "When created from existing", ->
			beforeEach ->
				@proj = new Project JSON.parse(JSON.stringify(window.projectTestJSON.project))
			describe "after initial load", ->
				it "should be defined", ->
					expect(@proj).toBeDefined()
				it "should have a type", ->
					expect(@proj.get('lsType')).toEqual "project"
				it "should have a kind", ->
					expect(@proj.get('lsKind')).toEqual "project"
				it "should have a recordedBy set", ->
					expect(@proj.get('recordedBy')).toEqual "bob"
				it "should have a recordedDate set", ->
					expect(@proj.get('recordedDate')).toEqual 1462553966814
				it "Should have labels set", ->
					expect(@proj.get("project name").get("labelText")).toEqual "Test Project 1"
					label = (@proj.get("lsLabels").getLabelByTypeAndKind("name", "project name"))
					expect(label[0].get('labelText')).toEqual "Test Project 1"
					expect(@proj.get("project alias").get("labelText")).toEqual "Project 1"
					label = (@proj.get("lsLabels").getLabelByTypeAndKind("name", "project alias"))
					expect(label[0].get('labelText')).toEqual "Project 1"
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@proj.get('lsStates')).toBeDefined()
					expect(@proj.get("lsStates").length).toEqual 1
					expect(@proj.get("lsStates").getStatesByTypeAndKind("metadata", "project metadata").length).toEqual 1
				it "Should have a start date value", ->
					expect(@proj.get("start date").get("value")).toEqual 1462518000000
				it "Should have a project status value", ->
					expect(@proj.get("project status").get("value")).toEqual "active"
				it "Should have a short description value", ->
					expect(@proj.get("short description").get("value")).toEqual "Example short description"
				it "Should have a project details value", ->
					expect(@proj.get("project details").get("value")).toEqual "Example project details"
				it "Should have a is restricted value", ->
					expect(@proj.get("is restricted").get("value")).toEqual "true"

			describe "model validation", ->
				beforeEach ->
					@proj = new Project window.projectTestJSON.project
				it "should be valid when loaded from saved", ->
					expect(@proj.isValid()).toBeTruthy()
				it "should be invalid when project name is empty", ->
					@proj.get("project name").set("labelText", "")
					expect(@proj.isValid()).toBeFalsy()
					filtErrors = _.filter(@proj.validationError, (err) ->
						err.attribute=='projectName'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when project alias is empty", ->
					@proj.get("project alias").set("labelText", "")
					expect(@proj.isValid()).toBeFalsy()
					filtErrors = _.filter(@proj.validationError, (err) ->
						err.attribute=='projectAlias'
					)
					expect(filtErrors.length).toBeGreaterThan 0

	describe "Project Controller testing", ->
		describe "When instantiated from new", ->
			beforeEach ->
				@proj = new Project()
				@projc = new ProjectController
					model: @proj
					el: $('#fixture')
				@projc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@projc).toBeDefined()
				it "should load the template", ->
					expect(@projc.$('.bv_projectCode').html()).toEqual ""
		describe "When instantiated from existing", ->
			beforeEach ->
				@proj = new Project JSON.parse(JSON.stringify(window.projectTestJSON.project))
				@projc = new ProjectController
					model: @proj
					el: $('#fixture')
				@projc.render()
			describe "render existing parameters", ->
				it "should fill the project status field", ->
					waitsFor ->
						@projc.$('.bv_status option').length > 0
					, 1000
					runs ->
						expect(@projc.$('.bv_status').val()).toEqual "active"
				it "should show the project code", ->
					expect(@projc.$('.bv_projectCode').val()).toEqual "PROJ-00000001"
				it "should fill the project name", ->
					expect(@projc.$('.bv_projectName').val()).toEqual "Test Project 1"
				it "should check the restricted data box", ->
					expect(@projc.$('.bv_restrictedData').attr("checked")).toEqual "checked"
				it "should fill the project alias", ->
					expect(@projc.$('.bv_projectAlias').val()).toEqual "Project 1"
				it "should fill the start date field", ->
					expect(@projc.$('.bv_startDate').val()).toEqual "2016-05-06"
				it "should fill the short description field", ->
					expect(@projc.$('.bv_shortDescription').val()).toEqual "Example short description"
				it "should fill the project details field", ->
					expect(@projc.$('.bv_projectDetails').val()).toEqual "Example project details"

			describe "model updates", ->
				it "should update model when the project status is changed", ->
					waitsFor ->
						@projc.$('.bv_status option').length > 0
					, 1000
					runs ->
						@projc.$('.bv_status').val('inactive')
						@projc.$('.bv_status').change()
						expect(@projc.model.get('project status').get('value')).toEqual "inactive"
				it "should update model when project name is changed", ->
						@projc.$('.bv_projectName').val('Test Project 2')
						@projc.$('.bv_projectName').keyup()
						expect(@projc.model.get('project name').get('labelText')).toEqual "Test Project 2"
				it "should update model when project alias is changed", ->
						@projc.$('.bv_projectAlias').val('Project 2')
						@projc.$('.bv_projectAlias').keyup()
						expect(@projc.model.get('project alias').get('labelText')).toEqual "Project 2"
				it "should update model when start date is changed", ->
					@projc.$('.bv_startDate').val(" 2013-3-16   ")
					@projc.$('.bv_startDate').keyup()
					expect(@projc.model.get('start date').get('value')).toEqual new Date(2013,2,16).getTime()
				it "should update model when restricted data checkbox is clicked", ->
					@projc.$('.bv_restrictedData').click()
					expect(@projc.model.get('is restricted').get('value')).toEqual "false"
				it "should update model when short description is changed", ->
					@projc.$('.bv_shortDescription').val(" Updated short description  ")
					@projc.$('.bv_shortDescription').keyup()
					expect(@projc.model.get('short description').get('value')).toEqual "Updated short description"
				it "should update model when project details is changed", ->
					@projc.$('.bv_projectDetails').val(" Updated project details  ")
					@projc.$('.bv_projectDetails').keyup()
					expect(@projc.model.get('project details').get('value')).toEqual "Updated project details"

			describe "controller validation rules", ->
				describe "when name field not filled in", ->
					it "should show error if name not filled in", ->
						@projc.$('.bv_projectName').val ""
						@projc.$('.bv_projectName').keyup()
						expect(@projc.$('.bv_group_projectName').hasClass('error')).toBeTruthy()
				describe "when alias field not filled in", ->
					it "should show error if alias not filled in", ->
						@projc.$('.bv_projectAlias').val ""
						@projc.$('.bv_projectAlias').keyup()
						expect(@projc.$('.bv_group_projectAlias').hasClass('error')).toBeTruthy()
