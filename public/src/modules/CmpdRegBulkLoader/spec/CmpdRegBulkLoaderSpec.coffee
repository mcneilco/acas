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
		describe "when loaded from new", ->
			beforeEach ->
				@spl = new SdfPropertiesList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@spl).toBeDefined()
		describe "when loaded from passed in attributes", ->
			beforeEach ->
				@spl = new SdfPropertiesList window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['sdfProperties']
			describe "Existence", ->
				it "should be defined", ->
					expect(@spl).toBeDefined()
				it "should have 5 properties", ->
					expect(@spl.length).toEqual 5
				it "should have the correct values for each attribute in the models", ->
					prop1 = @spl.at(0)
					expect(prop1.get('name')).toEqual "prop1"


	describe "DB Property model testing", ->
		beforeEach ->
			@dp = new DbProperty()
		describe "Existence", ->
			it "should be defined", ->
				expect(@dp).toBeDefined()
	describe "Db Properties List testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@dpl = new DbPropertiesList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@dpl).toBeDefined()
		describe "when loaded from passed in attributes", ->
			beforeEach ->
				@dpl = new DbPropertiesList window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['dbProperties']
			describe "Existence", ->
				it "should be defined", ->
					expect(@dpl).toBeDefined()
			describe "features", ->
				it "should return a filtered array of required properties", ->
					expect(@dpl.getRequired().length).toEqual 4
				it "should have 5 properties", ->
					expect(@dpl.length).toEqual 5
				it "should have the correct values for each attribute in the models", ->
					prop1 = @dpl.at(0)
					expect(prop1.get('name')).toEqual "db1"

	describe "Assigned Property model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@ap = new AssignedProperty()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@ap).toBeDefined()
				it "should have a default sdfProperty", ->
					expect(@ap.get('sdfProperty')).toEqual null
				it "should have a default dbProperty", ->
					expect(@ap.get('dbProperty')).toEqual "none"
				it "should have a default defaultVal", ->
					expect(@ap.get('defaultVal')).toEqual ""
				it "should have a default required value", ->
					expect(@ap.get('required')).toBeFalsy()
		describe "model validation tests", ->
			beforeEach ->
				@ap = new AssignedProperty window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['bulkloadProperties'][0]
			it "should be invalid when the dbProperty is required (and not corporate id) and the default value is empty", ->
				@ap.set
					required: true
					dbProperty: "test"
					defaultVal: ""
				expect(@ap.isValid()).toBeFalsy()
				filtErrors = _.filter @ap.validationError, (err) ->
					err.attribute=='defaultVal'
				expect(filtErrors.length).toBeGreaterThan 0
	describe "Assigned Properties List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@apl = new AssignedPropertiesList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@apl).toBeDefined()
		describe "when loaded from passed in attributes", ->
			beforeEach ->
				@apl = new AssignedPropertiesList window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['bulkloadProperties']
			describe "Existence", ->
				it "should be defined", ->
					expect(@apl).toBeDefined()
				it "should have 2 properties", ->
					expect(@apl.length).toEqual 2
				it "should have the correct values for each attribute in the models", ->
					prop1 = @apl.at(0)
					expect(prop1.get('dbProperty')).toEqual "db1"
					expect(prop1.get('sdfProperty')).toEqual "prop1"
					expect(prop1.get('required')).toEqual true
			describe "features", ->
				it "should return an array of models with the same dbProperty", ->
					@apl.at(0).set 'dbProperty': "db2"
					expect(@apl.checkDuplicates().length).toEqual 2
					filtErrors = _.filter @apl.checkDuplicates(), (err) ->
						err.attribute=='dbProperty:eq(0)'
					expect(filtErrors.length).toEqual 1
					filtErrors = _.filter @apl.checkDuplicates(), (err) ->
						err.attribute=='dbProperty:eq(1)'
					expect(filtErrors.length).toEqual 1

	describe "DetectSdfPropertiesController testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@dspc= new DetectSdfPropertiesController
					el: $('#fixture')
				@dspc.render()
			describe "basic existence and set up tests", ->
				it "should exist", ->
					expect(@dspc).toBeDefined()
				it "should load a template", ->
					expect(@dspc.$('.bv_detectedSdfPropertiesList').length).toEqual 1
				it "should have numRecords set to 100", ->
					expect(@dspc.numRecords).toEqual 100
				it "should have use template set to none", ->
					expect(@dspc.temp).toEqual "none"
				it "should have records read show 0", ->
					expect(@dspc.$('.bv_recordsRead').html()).toEqual '0'
				it "should have the read more button disabled", ->
					expect(@dspc.$('.bv_readMore').attr('disabled')).toEqual "disabled"
				it "should have the read all button disabled", ->
					expect(@dspc.$('.bv_readAll').attr('disabled')).toEqual "disabled"
			describe "browse file controller testing", ->
				it "should set up the browse file controller", ->
					expect(@dspc.browseFileController).toBeDefined()
				it "should set the fileName property when a file is uploaded", ->
					@dspc.handleFileUploaded("testFile")
					expect(@dspc.fileName).toEqual "testFile"
			describe "behavior", ->
				it "should read more records when button is clicked", ->
					@dspc.$('.bv_readMore').click()
					waits(1000)
					expect(@dspc.numRecords).toEqual 100
					expect(@dspc.$('.bv_recordsRead').html()).toEqual '100'
			describe "other features", ->
				it "should show sdf properties", ->
					sdfPropsList = new SdfPropertiesList window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['sdfProperties']
					@dspc.showSdfProperties(sdfPropsList)
					expect(@dspc.$('.bv_recordsRead').html()).toEqual '100'
					expect(@dspc.$('.bv_detectedSdfPropertiesList').val().indexOf('prop1')).toBeGreaterThan -1
#					expect(@dspc.$('.bv_detectedSdfPropertiesList').html()).toEqual "prop1&#13;&#10;prop2&#13;&#10;prop3&#13;&#10;prop4&#13;&#10;prop5"
					expect(@dspc.$('.bv_recordsMore').attr('disabled')).toBeUndefined()
					expect(@dspc.$('.bv_recordsAll').attr('disabled')).toBeUndefined()
				it "should update the temp attr when the template is changed", ->
					@dspc.handleTemplateChanged('Template 1')
					expect(@dspc.temp).toEqual "Template 1"


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
					expect(@apc.$('.bv_sdfProperty').html()).toEqual ""
				it "should show the database property", ->
					waitsFor ->
						@apc.$('.bv_dbProperty option').length > 0
					, 1000
					runs ->
						expect(@apc.$('.bv_dbProperty').val()).toEqual "none"
				it "should show the default value", ->
					expect(@apc.$('.bv_defaultVal').val()).toEqual ""
		describe "when instantiated with data", ->
			beforeEach ->
				@apc= new AssignedPropertyController
					el: $('#fixture')
					model: new AssignedProperty window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['bulkloadProperties'][0]
					dbPropertiesList: new DbPropertiesList window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['dbProperties']
				@apc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@apc).toBeDefined()
				it "should load a template", ->
					expect(@apc.$('.bv_sdfProperty').length).toEqual 1
			describe "rendering", ->
				it "should show the sdf property", ->
					expect(@apc.$('.bv_sdfProperty').html()).toEqual "prop1"
				it "should show the database property", ->
					waitsFor ->
						@apc.$('.bv_dbProperty option').length > 0
					, 1000
					runs ->
						expect(@apc.$('.bv_dbProperty').val()).toEqual "db1"
				it "should show the default value", ->
					expect(@apc.$('.bv_defaultVal').val()).toEqual ""
			describe "model updates", ->
				it "should update the dbProperty", ->
					waitsFor ->
						@apc.$('.bv_dbProperty option').length > 0
					, 1000
					runs ->
						@apc.$('.bv_dbProperty').val('db5')
						@apc.$('.bv_dbProperty').change()
						expect(@apc.model.get('dbProperty')).toEqual 'db5'
						expect(@apc.model.get('required')).toEqual true
				it "should update the default val", ->
					@apc.$('.bv_defaultVal').val "  testVal    "
					@apc.$('.bv_defaultVal').change()
					expect(@apc.model.get('defaultVal')).toEqual "testVal"

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

	describe "AssignSdfPropertiesController", ->
		beforeEach ->
			@aspc= new AssignSdfPropertiesController
				el: $('#fixture')
			@aspc.render()
		describe "basic existence tests", ->
			it "should exist", ->
				expect(@aspc).toBeDefined()
			it "should load a template", ->
				expect(@aspc.$('.bv_useTemplate').length).toEqual 1
			it "should have an assigned properties list controller", ->
				expect(@aspc.templateListController).toBeDefined()
		describe "rendering", ->
			it "should show a template select", ->
				waitsFor ->
					@aspc.$('.bv_useTemplate option').length > 0
				, 1000
				runs ->
					expect(@aspc.$('.bv_useTemplate').val()).toEqual "none"
		describe "behavior and validation", ->
			beforeEach ->
				@aspc.createPropertyCollections(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList)
			it "should trigger template changed when template is changed", ->
				triggered = false
				@aspc.on 'templateChanged', =>
					triggered = true
				@aspc.$('.bv_useTemplate').val "Template 2"
				@aspc.$('.bv_useTemplate').change()
				expect(triggered).toEqual true
			#error notification tested here
			it "should show error if a project is not selected", ->
				waitsFor ->
					@aspc.$('.bv_dbProject option').length > 0
				, 1000
				runs ->
					@aspc.$('.bv_dbProject').val "unassigned"
					@aspc.$('.bv_dbProject').change()
					expect(@aspc.$('.bv_group_dbProject').hasClass('error')).toBeTruthy()
					expect(@aspc.$('.bv_regCmpds').attr('disabled')).toEqual 'disabled'
			it "should show error if a default value isn't given for a required dbProperty", ->
				waitsFor ->
					@aspc.$('.bv_dbProperty option').length > 0
				, 1000
				runs ->
					@aspc.$('.bv_dbProperty:eq(2)').val "db3"
					@aspc.$('.bv_dbProperty:eq(2)').change()
					expect(@aspc.$('.bv_group_defaultVal:eq(2)').hasClass("error")).toBeTruthy()
					expect(@aspc.$('.bv_regCmpds').attr('disabled')).toEqual 'disabled'
			it "should show error if a db property is chosen more than once", ->
				waitsFor ->
					@aspc.$('.bv_dbProperty option').length > 0
				, 1000
				runs ->
					@aspc.$('.bv_dbProperty:eq(1)').val "db5"
					@aspc.$('.bv_dbProperty:eq(1)').change()
					@aspc.$('.bv_dbProperty:eq(2)').val "db5"
					@aspc.$('.bv_dbProperty:eq(2)').change()
					expect(@aspc.$('.bv_group_dbProperty:eq(1)').hasClass("error")).toBeTruthy()
					expect(@aspc.$('.bv_group_dbProperty:eq(2)').hasClass("error")).toBeTruthy()
					expect(@aspc.$('.bv_regCmpds').attr('disabled')).toEqual 'disabled'
			it "should show error if save template is checked and the template name is already used and overwrite is set to no", ->
				#should default to no overwrite
				waitsFor ->
					@aspc.$('.bv_useTemplate option').length > 0
				, 1000
				runs ->
					@aspc.$('.bv_useTemplate').val("Template 1")
					@aspc.$('.bv_useTemplate').change()
					waits(1000)
					@aspc.$('.bv_saveTemplate').click()
					expect(@aspc.$('.bv_saveTemplate').attr("checked")).toEqual "checked"
					expect(@aspc.$('.bv_group_templateName').hasClass("error")).toBeTruthy()
					expect(@aspc.$('.bv_regCmpds').attr('disabled')).toEqual 'disabled'
			it "should not show error if save template is checked and the template name is already used and overwrite is set to yes", ->
				waitsFor ->
					@aspc.$('.bv_useTemplate option').length > 0
				, 1000
				runs ->
					@aspc.$('.bv_useTemplate').val("Template 1")
					@aspc.$('.bv_useTemplate').change()
					@aspc.$('.bv_saveTemplate').change()
					@aspc.$('.bv_overwrite').change()
					expect(@aspc.$('.bv_saveTemplate').attr("checked")).toEqual "checked"
					expect(@aspc.$('.bv_group_templateName').hasClass("error")).toBeFalsy()
					expect(@aspc.$('.bv_regCmpds').attr('disabled')).toBeUndefined()
			it "should have the Register Compounds button be enabled when the form is valid", ->
				waitsFor ->
					@aspc.$('.bv_useTemplate option').length > 0
				, 1000
				runs ->
					@aspc.$('.bv_useTemplate').val "Template 1"
					@aspc.$('.bv_useTemplate').change()
					@aspc.$('.bv_dbProperty:eq(0)').val("db1*")
					@aspc.$('.bv_dbProperty:eq(1)').val("db2*")
					@aspc.$('.bv_dbProperty:eq(2)').val("db3*")
					@aspc.$('.bv_dbProperty:eq(3)').val("db4*")
					@aspc.$('.bv_dbProperty:eq(4)').val("db5")
					expect(@aspc.$('.bv_regCmpds').attr('disabled')).toBeUndefined()

	describe "BulkRegCmpdsController testing" , ->
		beforeEach ->
			@brcc = new BulkRegCmpdsController()
			@brcc.render()
		describe "basic loading", ->
			it "should exist", ->
				expect(@brcc).toBeDefined()
			it "Should load the template", ->
				expect(@brcc.$('.bv_detectSdfProperties').length).toEqual 1
			it "Should load a detectSdfPropertiesController", ->
				expect(@brcc.detectSdfPropertiesController).toBeDefined()
			it "Should load a assignSdfPropertiesController ", ->
				expect(@brcc.assignSdfPropertiesController ).toBeDefined()

	describe "BulkRegCmpdsSummaryController testing", ->
		beforeEach ->
			@brcsc = new BulkRegCmpdsSummaryController()
			@brcsc.render()
		describe "basic loading", ->
			it "should exist", ->
				expect(@brcsc).toBeDefined()
			it "Should load the template", ->
				expect(@brcsc.$('.bv_regSummaryHTML').length).toEqual 1
		describe "features", ->
			it "should trigger loadAnother when loadAnother is clicked", ->
				triggered = false
				@brcsc.on 'loadAnother', =>
					triggered = true
				@brcsc.$('.bv_loadAnother').click()
				expect(triggered).toBeTruthy()

	describe "Cmpd Reg Bulk Loader App Controller testing", ->
		beforeEach ->
			@crblap = new CmpdRegBulkLoaderAppController()
			@crblap.render()
		describe "basic loading", ->
			it "should exist", ->
				expect(@crblap).toBeDefined()
			it "Should load the template", ->
				expect(@crblap.$('.bv_headerName').length).toEqual 1
