beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Compound Reg Bulk Loader module testing", ->
	describe "SDF Property model testing", ->
		beforeEach ->
			@sp = new SdfProperty()
		describe "Existence", ->
			it "should be defined", ->
				expect(@sp).toBeDefined()
	describe "SDF Properties List testing", ->
		beforeEach ->
			@spl = new SdfPropertiesList()
		describe "Existence", ->
			it "should be defined", ->
				expect(@spl).toBeDefined()

	describe "DB Property model testing", ->
		beforeEach ->
			@dp = new DbProperty()
		describe "Existence", ->
			it "should be defined", ->
				expect(@dp).toBeDefined()
	describe "Db Properties List testing", ->
		beforeEach ->
			@dpl = new DbPropertiesList()
		describe "Existence", ->
			it "should be defined", ->
				expect(@dpl).toBeDefined()

	describe "Assigned Property model testing", ->
		beforeEach ->
			@ap = new AssignedProperty()
		describe "Existence and Defaults", ->
			it "should be defined", ->
				expect(@ap).toBeDefined()
			it "should have defaults", ->
				console.log "getting defaults"
				expect(@ap.get('sdfProperty')).toEqual null
				expect(@ap.get('dbProperty')).toEqual "unassigned"
				expect(@ap.get('defaultVal')).toEqual ""

	describe "Assigned Properties List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@apl = new AssignedPropertiesList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@apl).toBeDefined()

#	describe "DetectSdfPropertiesController testing", ->
#		describe "when instantiated with no data", ->
#			beforeEach ->
#				@dspc= new DetectSdfPropertiesController
#					el: $('#fixture')
#					model: new AssignedProperty()
#				@dspc.render()
#			describe "basic existence tests", ->
#				it "should exist", ->
#					expect(@dspc).toBeDefined()
#				it "should load a template", ->
#					expect(@dspc.$('.bv_sdfProperties').length).toEqual 1

	describe "Assigned Property Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@apc= new AssignedPropertyController
					el: $('#fixture')
					model: new AssignedProperty()
				@apc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@apc).toBeDefined()
				it "should load a template", ->
					expect(@apc.$('.bv_sdfProperty').length).toEqual 1
			describe "rendering", ->
				it "should show the sdf property", ->
					expect(@apc.$('.bv_sdfProperty').html()).toEqual "sdfProperty"
				it "should show the database property", ->
					waitsFor ->
						@apc.$('.bv_dbProperty option').length > 0
					, 1000
					runs ->
						expect(@apc.$('.bv_dbProperty').val()).toEqual "unassigned"
				it "should show the default value", ->
					expect(@apc.$('.bv_defaultVal').val()).toEqual ""

	describe "Assigned Properties List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@aplc= new AssignedPropertiesListController
					el: $('#fixture')
					collection: new AssignedPropertiesList()
				@aplc.render()
				@aplc.$('.bv_addDbProperty').removeAttr('disabled')
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@aplc).toBeDefined()
				it "should load a template", ->
					expect(@aplc.$('.bv_addDbProperty').length).toEqual 1
			describe "adding and removing", ->
				it "should have one read when add db prop button is clicked", ->
					@aplc.$('.bv_addDbProperty').click()
					expect(@aplc.$('.bv_propInfo .bv_dbProperty').length).toEqual 1
					expect(@aplc.collection.length).toEqual 1
				it "should have no reads when there is one read and remove is clicked", ->
					@aplc.$('.bv_addDbProperty').click()
					expect(@aplc.collection.length).toEqual 1
					@aplc.$('.bv_deleteProperty').click()
					expect(@aplc.$('.bv_propInfo .bv_dbProperty').length).toEqual 0
					expect(@aplc.collection.length).toEqual 0

	describe "Cmpd Reg Bulk Loader App Controller testing", ->
		beforeEach ->
			@crblap = new CmpdRegBulkLoaderAppController()
			@crblap.render()
		describe "basic loading", ->
			it "should exist", ->
				expect(@crblap).toBeDefined()
			it "Should load the template", ->
				expect(@crblap.$('.bv_headerName').length).toEqual 1
			it "Should load a browseFileController", ->
				expect(@crblap.browseFileController).toBeDefined()
		describe "display logic", ->
			it "should start off with all buttons except the browse files button disabled", ->
				expect(@crblap.$('.bv_readMore').attr('disabled')).toEqual "disabled"
				expect(@crblap.$('.bv_readAll').attr('disabled')).toEqual "disabled"
				expect(@crblap.$('.bv_addDbProperty').attr('disabled')).toEqual "disabled"
				expect(@crblap.$('.bv_regCmpds').attr('disabled')).toEqual "disabled"
