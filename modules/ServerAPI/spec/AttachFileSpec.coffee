beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)


describe "Attach File testing", ->
	describe "Attach file model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@afm = new AttachFile()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@afm).toBeDefined()
				it "should have the file type be unassigned", ->
					expect(@afm.get('fileType')).toEqual "unassigned"
				it "should have the fileValue be empty", ->
					expect(@afm.get('fileValue')).toEqual ""
		describe "model validation tests", ->
			beforeEach ->
				@afm = new AttachFile window.attachFileTestJSON.attachFileInfo[0]
			it "should be valid as initialized", ->
				expect(@afm.isValid()).toBeTruthy()
			it "should be invalid when file type is unassigned AND a file is uploaded", ->
#				right now only checks for unassigned file type
				@afm.set fileType: "unassigned"
				expect(@afm.isValid()).toBeFalsy()
				filtErrors = _.filter(@afm.validationError, (err) ->
					err.attribute=='fileType'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Attach File List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@afl = new AttachFileList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@afl).toBeDefined()

	describe "AttachFileController testing", ->
		describe "when instantiated", ->
			beforeEach ->
				@afc = new AttachFileController
					model: new AttachFile window.attachFileTestJSON.attachFileInfo[0]
					el: $('#fixture')
				@afc.render()
			describe "basic existance tests", ->
				it "should exist", ->
					expect(@afc).toBeDefined()
				it "should load a template", ->
					expect(@afc.$('.bv_fileType').length).toEqual 1
			describe "render existing parameters", ->
				it "should show file type", ->
					waitsFor ->
						@afc.$('.bv_fileType option').length > 0
					, 1000
					runs ->
						expect(@afc.$('.bv_fileType').val()).toEqual "hplc"
#				it "should show file name", ->
#					expect(@afc.$('.bv_fileType').val()).toEqual "example experiment file"
			describe "model updates", ->
				it "should update the fileType", ->
					waitsFor ->
						@afc.$('.bv_fileType option').length > 0
					, 1000
					runs ->
						@afc.$('.bv_fileType').val('unassigned')
						@afc.$('.bv_fileType').change()
						expect(@afc.model.get('fileType')).toEqual "unassigned"


	describe "AttachFileListController testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@aflc= new AttachFileListController
					el: $('#fixture')
					collection: new AttachFileList()
				@aflc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@aflc).toBeDefined()
				it "should load a template", ->
					expect(@aflc.$('.bv_attachFileInfo').length).toEqual 1
			describe "rendering", ->
				it "should show one attachFileModel", ->
					expect(@aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual 1
					expect(@aflc.collection.length).toEqual 1
			describe "adding and removing", ->
				it "should be able to delete a file", ->
					@aflc.uploadNewAttachFile()
					expect(@aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual 2
					@aflc.$('.bv_delete:eq(0)').click()
					expect(@aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual 1
				it "should always have at least one attachFileModel", ->
					@aflc.$('.bv_delete:eq(0)').click()
					expect(@aflc.$('.bv_attachFileInfo .bv_fileType').length).toEqual 1

