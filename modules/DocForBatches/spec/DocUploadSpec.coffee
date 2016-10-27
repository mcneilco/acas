describe 'Doc Upload Behavior Testing', ->

	beforeEach ->
		@.fixture = $.clone($('#fixture').get(0))

	afterEach ->
		$('#fixture').remove()
		$('body').append $(this.fixture)


	describe 'DocUpload Model', ->
		describe 'when instantiated', ->
			beforeEach ->
				@docUpload = new DocUpload()
			it  'should have defaults', ->
				expect(@docUpload.get 'url').toEqual ''
				expect(@docUpload.get 'currentFileName').toEqual ''
				expect(@docUpload.get 'description').toEqual ''
				expect(@docUpload.get 'docType').toEqual ''
				expect(@docUpload.get 'documentKind').toEqual 'experiment'
			it 'should accept "url" for docType', ->
				@docUpload.set
					docType: 'url'
					url: 'http://fred'
				expect(@docUpload.isValid()).toBeTruthy()
			it 'should accept "file" for docType', ->
				@docUpload.set
					docType: 'file'
					currentFileName: 'myFile'
				expect(@docUpload.isValid()).toBeTruthy()
			it 'should not accept something besides "file" or "url" for docType', ->
				@docUpload.set
					docType: 'fred'
					currentFileName: 'myFile'
				expect(@docUpload.isValid()).toBeFalsy()
				filtErrors = _.filter(@docUpload.validationError, (err) ->
					err.attribute=='docType'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it 'should require currentFileName not "" when docType=file', ->
				@docUpload.set
					docType: 'file'
					currentFileName: ''
				expect(@docUpload.isValid()).toBeFalsy()
				filtErrors = _.filter(@docUpload.validationError, (err) ->
					err.attribute=='currentFileName'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it 'should require url not "" when docType=url', ->
				@docUpload.set
					docType: 'url'
					url: ''
				expect(@docUpload.isValid()).toBeFalsy()
				filtErrors = _.filter(@docUpload.validationError, (err) ->
					err.attribute=='url'
				)
				expect(filtErrors.length).toBeGreaterThan 0


	describe 'DocUpload Controller', ->
		describe 'when created with new model', ->
			beforeEach ->
				@docUploadController = new DocUploadController
												model: new DocUpload()
												el: $('#fixture')
				@docUploadController.render()
			describe 'after initial render', ->
				it 'should have a description field', ->
					expect(@docUploadController.$(".bv_description").prop('tagName')).toEqual "INPUT"
				it 'should url field hidden', ->
					expect(@docUploadController.$('.bv_urlInputWrapper')).toBeHidden()
				it 'should have new file radio selected', ->
					expect(@docUploadController.$('.bv_newFileRadio').is(":checked")).toBeTruthy()
				describe 'since this is a new file', ->
					it 'should hide the current file radio option', ->
						expect(@docUploadController.$('.bv_currentDocContainer')).toBeHidden()
				describe 'form events', ->
					it 'should hide URL field when radio is not selected', ->
						@docUploadController.$('bv_newFileRadio').click()
						expect(@docUploadController.$('.bv_urlInputWrapper')).toBeHidden()
					it 'should show URL field when radio is selected', ->
						@docUploadController.$('.bv_urlRadio').click()
						expect(@docUploadController.$('.bv_urlInputWrapper')).toBeVisible()
					it 'should show file control when radio is selected', ->
						@docUploadController.$('.bv_newFileRadio').click()
						expect(@docUploadController.$('.bv_fileInput')).toBeVisible()
					it 'should hide file control when radio is selected', ->
						@docUploadController.$('.bv_urlRadio').click()
						waits(500) # for slide effect
						runs ->
							expect(@docUploadController.$('.bv_fileInput')).toBeHidden()
				describe 'form validataion', ->
					it 'should show error if URL field is empty and URL radio is selected', ->
						@docUploadController.$(".bv_url").val("")
						@docUploadController.$(".bv_urlRadio").click()
						expect(@docUploadController.$(".bv_urlDocContainer").hasClass("error")).toBeTruthy()
					it 'should clear error if URL field is not empty and URL radio is selected', ->
						@docUploadController.$(".bv_url").val("")
						@docUploadController.$(".bv_urlRadio").click()
						expect(@docUploadController.$(".bv_urlDocContainer").hasClass("error")).toBeTruthy()
						@docUploadController.$(".bv_url").val("fred")
						@docUploadController.$(".bv_url").change()
						expect(@docUploadController.$(".bv_urlDocContainer").hasClass("error")).toBeFalsy()
					it 'should show error if file controller is empty and file radio is selected', ->
						@docUploadController.$(".bv_newFileRadio").click()
						@docUploadController.clearNewFileName()
						expect(@docUploadController.$(".bv_newDocContainer").hasClass("error")).toBeTruthy()
					it 'should clear error if file controller not empty and file radio is selected', ->
						@docUploadController.clearNewFileName() #usually triggered from fileInput
						@docUploadController.$(".bv_newFileRadio").click()
						expect(@docUploadController.$(".bv_newDocContainer").hasClass("error")).toBeTruthy()
						@docUploadController.setNewFileName("fredFile") #usually triggered from fileInput
						@docUploadController.$(".bv_newFileRadio").click()
						expect(@docUploadController.$(".bv_newDocContainer").hasClass("error")).toBeFalsy()

					#No tests to ensure binding and triggering of file upload and delete work, it was too hard


		describe 'when created with existing model with docType File', ->
			beforeEach ->
				@docUploadController = new DocUploadController
					model: new DocUpload(window.testJSON.docUploadWithFile)
					el: $('#fixture')
				@docUploadController.render()

			describe 'after initial render with docType = file', ->
					it 'should show current file container', ->
						expect(@docUploadController.$('.bv_currentDocContainer')).toBeVisible()
					it 'should show current file name if docType is file', ->
						expect(@docUploadController.$('.bv_currentFileName').html()).toEqual("exampleUploadedFile.txt")
					it 'should have current file name radio checked docType is file', ->
						expect(@docUploadController.$('.bv_currentFileRadio').is(":checked")).toBeTruthy()
					it 'should hide new file input', ->
						expect(@docUploadController.$('.bv_fileInput')).toBeHidden()

		describe 'when created with existing model with docType url', ->
			beforeEach ->
				@docUploadController = new DocUploadController
					model: new DocUpload(window.testJSON.docForBatchesWithURl)
					el: $('#fixture')
				@docUploadController.render()

			describe 'after initial render with docType = url', ->
				it 'should hide current file container', ->
					expect(@docUploadController.$('.bv_currentDocContainer')).toBeHidden()
				xit 'should show current url name ', ->
					#TODO fix this spec
					expect(@docUploadController.$('.bv_url').val()).toEqual("testURL")
				it 'should have  url  radio checked ', ->
					expect(@docUploadController.$('.bv_urlRadio').is(":checked")).toBeTruthy()
				it 'should hide new file input', ->
					expect(@docUploadController.$('.bv_fileInput')).toBeHidden()

