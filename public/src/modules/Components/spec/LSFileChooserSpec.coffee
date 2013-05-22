###
  This module is our MVC wrapper for the Blueimp jQuery fileupload() widget.
  Here are the docs: https://github.com/blueimp/jQuery-File-Upload/wiki/Options
  Much FM occurs in fileupload. This controller is designed to hide that and send events etc
  that match our general architecture
###


describe 'LS File Chooser Behavior Testing', ->
	beforeEach ->
		@fixture = $.clone($('#fixture').get(0));
		
	afterEach ->
		$('#fixture').remove();
		$('body').append($(@fixture));
		
	describe 'LSFileChooser Model', ->
		describe 'when instantiated', ->
			beforeEach ->
				@fc = new LSFileChooserModel()
			
			it 'should have defaults', ->
				(expect @fc.get('fileName')).toEqual ''
				(expect @fc.get('fileNameOnServer')).toEqual ''
				(expect @fc.get('fileType')).toEqual ''
			
			it 'should return fileName', ->
				@fc.set({'fileName' : "testFile"})
				(expect @fc.get('fileName'))
			
			it 'should be marked as dirty', ->
				(expect @fc.isDirty()).toBeTruthy()
			
		describe 'when a file has been uploaded', ->
			beforeEach ->
				@fc = new LSFileChooserModel()
			
			it 'the fileNameOnServer field should be set', ->
				@fc.set({fileNameOnServer: 'testFileName.foo'})
				(expect @fc.get('fileNameOnServer')).toEqual 'testFileName.foo'
			
			it 'the isDirty field should be false', ->
				@fc.set({fileNameOnServer: 'testFileName.foo'})
				(expect @fc.isDirty()).toBeFalsy()
		
		describe 'when a file has been uploaded and then removed', ->
			beforeEach ->
				@fc = new LSFileChooserModel()
			
			it 'the fileNameOnServer field should be set back to default', ->
				@fc.set({fileNameOnServer: 'testFileName.foo'})
				(expect @fc.get('fileNameOnServer')).toEqual 'testFileName.foo'
				@fc.set({fileNameOnServer: ''})
				(expect @fc.get('fileNameOnServer')).toEqual ''
			
			it 'the isDirty field should be true', ->
				@fc.set({fileNameOnServer: 'testFileName.foo'})
				(expect @fc.isDirty()).toBeFalsy()
				@fc.set({fileNameOnServer: ''})
				(expect @fc.isDirty()).toBeTruthy()
	
	describe 'LSFileModelCollection', ->
		describe 'when instantiated', ->
			beforeEach ->
				@fmc = new LSFileModelCollection()
		
			it 'should be empty', ->
				(expect @fmc.size()).toEqual(0)
	
	describe 'LSFileChooserController', ->
		describe 'when instantiated', ->
			beforeEach ->
				@fc = new LSFileChooserController
					el: '#fixture'
					dropZoneClassId: 'field1'
					autoUpload: false
					maxNumberOfFiles: 1
					url: SeuratAddOns.configuration.fileServiceURL
				@fc.render()
				
			it 'should have upload url', ->
				(expect @fc.url).toContain 'http://'
			
			it 'drop field should initially be hidden', ->
				(expect $('.field1').is(':visible')).toBeFalsy();
			
			it 'should start with 0 files', ->
				(expect @fc.currentNumberOfFiles).toEqual(0)
			
			it 'should have 1 file after adding a file', ->
				@fc.handleFileAddedEvent({}, {})
				(expect @fc.currentNumberOfFiles).toEqual(1)
			
			it 'should have 2 files after adding 2 files', ->
				@fc.handleFileAddedEvent({}, {})
				@fc.handleFileAddedEvent({}, {})
				(expect @fc.currentNumberOfFiles).toEqual(2)
				
			it 'should have 1 files after adding 2 files and removing 1', ->
				@fc.handleFileAddedEvent({}, {})
				@fc.handleFileAddedEvent({}, {})
				(expect @fc.currentNumberOfFiles).toEqual(2)
				@fc.handleDeleteFileUIChanges({}, {})
				(expect @fc.currentNumberOfFiles).toEqual(1)
			
			it 'should not allow additional files to be added once the maxNumberOfFiles has been reached', ->
				@fc.maxNumberOfFiles = 1
				@fc.handleFileAddedEvent({}, {})
				(expect @fc.currentNumberOfFiles).toEqual(1)
				(expect @fc.canAcceptAnotherFile()).toBeFalsy()
			
			it 'should allow additional files to be added if the maxNumberOfFiles has not been reached', ->
				@fc.maxNumberOfFiles = 1
				(expect @fc.currentNumberOfFiles).toEqual(0)
				(expect @fc.canAcceptAnotherFile()).toBeTruthy()
				
		xdescribe 'drop field', ->
			beforeEach ->
				@fc = new LSFileChooserController({el: '#fixture', dropZoneClassId: 'field1', autoUpload: false})
				@fc.render()
				
			it 'should be displayed when dragging a file over the document', ->
				@fc.handleDragOverDocument()
				(expect $('.field1').is(':visible')).toBeTruthy();
			
			it 'should display info text when dragging a file over', ->
				@fc.handleDragOverDocument()
				(expect $('.bv_dragOverMessage').html()).toEqual 'Drop the file here to upload it'
			
			it 'should be hidden when mouseout', ->
				@fc.handleDragOverDocument()
				(expect $('.field1').is(':visible')).toBeTruthy();
				@fc.handleDragLeaveDocument()
				(expect $('.field1').is(':visible')).toBeFalsy();
				
		describe 'upload button', ->
			beforeEach ->
				@fc = new LSFileChooserController({el: '#fixture', dropZoneClassId: 'field1', autoUpload: false, maxNumberOfFiles: 1})
				@fc.render()

