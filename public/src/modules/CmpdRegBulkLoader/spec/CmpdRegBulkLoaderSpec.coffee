beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Compound Reg Bulk Loader module testing", ->
	describe "Assigned Property model testing", ->
		beforeEach ->
			@ap = new AssignedProperty()
		describe "Existence and Defaults", ->
			it "should be defined", ->
				expect(@ap).toBeDefined()
			it "should have defaults", ->
				expect(@ap.get('sdfProp')).toEqual "sdfProp"
				expect(@ap.get('dbProp')).toEqual "unassigned"
				expect(@ap.get('defaultVal')).toEqual ""

	describe "Assigned Properties List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@apl = new AssignedPropertiesList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@apl).toBeDefined()

	describe "Assigned Property Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@apc= new AssignedPropController
					el: $('#fixture')
					model: new AssignedProperty()
				@apc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@apc).toBeDefined()
				it "should load a template", ->
					expect(@apc.$('.bv_sdfProp').length).toEqual 1
			describe "rendering", ->
				it "should show the sdf property", ->
					expect(@apc.$('.bv_sdfProp').html()).toEqual "sdfProp"
				it "should show the database property", ->
					waitsFor ->
						@apc.$('.bv_dbProp option').length > 0
					, 1000
					runs ->
						expect(@apc.$('.bv_dbProp').val()).toEqual "unassigned"
				it "should show the default value", ->
					expect(@apc.$('.bv_defaultVal').val()).toEqual ""

	describe "Assigned Prop List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@aplc= new AssignedPropListController
					el: $('#fixture')
					collection: new AssignedPropertiesList()
				@aplc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@aplc).toBeDefined()
				it "should load a template", ->
					expect(@aplc.$('.bv_addDbProp').length).toEqual 1
			describe "adding and removing", ->
				it "should have one read when add db prop button is clicked", ->
					@aplc.$('.bv_addDbProp').click()
					expect(@aplc.$('.bv_propInfo .bv_dbProp').length).toEqual 1
					expect(@aplc.collection.length).toEqual 1
				it "should have no reads when there is one read and remove is clicked", ->
					@aplc.$('.bv_addDbProp').click()
					expect(@aplc.collection.length).toEqual 1
					@aplc.$('.bv_deleteProp').click()
					expect(@aplc.$('.bv_propInfo .bv_dbProp').length).toEqual 0
					expect(@aplc.collection.length).toEqual 0

